# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform identification flags
set(CAFEOS TRUE)
set(NINTENDO_WIIU TRUE)
set(WIIU TRUE)
set(WUT TRUE)

# Platform settings
set(WUT_ARCH_SETTINGS "-mcpu=750 -meabi -mhard-float")
set(WUT_COMMON_FLAGS  "-ffunction-sections -fdata-sections -DESPRESSO -D__WIIU__ -D__WUT__")
set(WUT_LINKER_FLAGS  "-L${WUT_ROOT}/lib -L${DEVKITPRO}/portlibs/wiiu/lib -L${DEVKITPRO}/portlibs/ppc/lib -specs=${WUT_ROOT}/share/wut.specs")
set(WUT_STANDARD_LIBRARIES "-lwut -lm")
set(WUT_STANDARD_INCLUDE_DIRECTORIES "${WUT_ROOT}/include")

__dkp_init_platform_settings(WUT)

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

function(wut_create_rpl target)
	cmake_parse_arguments(PARSE_ARGV 1 ELF2RPL "IS_RPX" "" "")

	set(ELF2RPL_FLAGS "")
	if(ELF2RPL_IS_RPX)
		# Do nothing - the defaults are good for RPX
		set(RPL_SUFFIX ".rpx")
	else()
		set(RPL_SUFFIX ".rpl")
		list(APPEND ELF2RPL_FLAGS "--rpl")
		target_link_options(${target} PRIVATE "-specs=${WUT_ROOT}/share/rpl.specs")
	endif()

	__dkp_target_derive_name(RPL_OUTPUT ${target} "${RPL_SUFFIX}")
	add_custom_command(TARGET ${target} POST_BUILD
		COMMAND ${WUT_ELF2RPL_EXE} ${ELF2RPL_FLAGS} "$<TARGET_FILE:${target}>" "${RPL_OUTPUT}"
		BYPRODUCTS "${RPL_OUTPUT}"
		COMMENT "Converting ${target} to ${RPL_SUFFIX} format"
		VERBATIM
	)

	set_target_properties(${target} PROPERTIES WUT_RPL "${RPL_OUTPUT}")
	if(ELF2RPL_IS_RPX)
		set_target_properties(${target} PROPERTIES WUT_IS_RPX TRUE)
	endif()
endfunction()

function(wut_create_rpx)
	wut_create_rpl(${ARGV} IS_RPX)
endfunction()

function(wut_create_wuhb target)
	cmake_parse_arguments(PARSE_ARGV 1 WUHBTOOL "" "TARGET;OUTPUT;CONTENT;NAME;SHORTNAME;AUTHOR;ICON;TVSPLASH;DRCSPLASH" "")

	if(DEFINED WUHBTOOL_TARGET)
		set(intarget "${WUHBTOOL_TARGET}")
		set(outtarget "${target}")
	else()
		set(intarget "${target}")
		set(outtarget "${target}_wuhb")
	endif()

	if(NOT TARGET "${intarget}")
		message(FATAL_ERROR "wut_create_wuhb: target '${intarget}' not defined")
	endif()

	get_target_property(RPL_PATH   ${intarget} WUT_RPL)
	get_target_property(RPL_IS_RPX ${intarget} WUT_IS_RPX)
	if(NOT RPL_IS_RPX OR NOT RPL_PATH)
		message(FATAL_ERROR "wut_create_wuhb: target must be a valid .rpx (use wut_create_rpx)")
	endif()

	if(DEFINED WUHBTOOL_OUTPUT)
		get_filename_component(WUHBTOOL_OUTPUT "${WUHBTOOL_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	elseif(DEFINED WUHBTOOL_TARGET)
		set(WUHBTOOL_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.wuhb")
	else()
		__dkp_target_derive_name(WUHBTOOL_OUTPUT ${intarget} ".wuhb")
	endif()

	set(WUHBTOOL_ARGS "${RPL_PATH}" "${WUHBTOOL_OUTPUT}")
	set(WUHBTOOL_DEPS ${intarget})

	if(DEFINED WUHBTOOL_CONTENT)
		if (TARGET "${WUHBTOOL_CONTENT}")
			get_target_property(_folder "${WUHBTOOL_CONTENT}" DKP_ASSET_FOLDER)
			if (NOT _folder)
				message(FATAL_ERROR "wut_create_wuhb: not a valid asset target")
			endif()
			list(APPEND WUHBTOOL_ARGS "--content=${_folder}")
			list(APPEND WUHBTOOL_DEPS ${WUHBTOOL_CONTENT} $<TARGET_PROPERTY:${WUHBTOOL_CONTENT},DKP_ASSET_FILES>)
		else()
			get_filename_component(WUHBTOOL_CONTENT "${WUHBTOOL_CONTENT}" ABSOLUTE)
			if (NOT IS_DIRECTORY "${WUHBTOOL_CONTENT}")
				message(FATAL_ERROR "wut_create_wuhb: cannot find content dir: ${WUHBTOOL_CONTENT}")
			endif()
			list(APPEND WUHBTOOL_ARGS "--content=${WUHBTOOL_CONTENT}")
		endif()
	endif()

	if(DEFINED WUHBTOOL_NAME)
		list(APPEND WUHBTOOL_ARGS "--name" "${WUHBTOOL_NAME}")
	endif()

	if(DEFINED WUHBTOOL_SHORTNAME)
		list(APPEND WUHBTOOL_ARGS "--short-name" "${WUHBTOOL_SHORTNAME}")
	endif()

	if(DEFINED WUHBTOOL_AUTHOR)
		list(APPEND WUHBTOOL_ARGS "--author" "${WUHBTOOL_AUTHOR}")
	endif()

	if(DEFINED WUHBTOOL_ICON)
		get_filename_component(WUHBTOOL_ICON "${WUHBTOOL_ICON}" ABSOLUTE)
		list(APPEND WUHBTOOL_ARGS "--icon=${WUHBTOOL_ICON}")
		list(APPEND WUHBTOOL_DEPS "${WUHBTOOL_ICON}")
	endif()

	if(DEFINED WUHBTOOL_TVSPLASH)
		get_filename_component(WUHBTOOL_TVSPLASH "${WUHBTOOL_TVSPLASH}" ABSOLUTE)
		list(APPEND WUHBTOOL_ARGS "--tv-image=${WUHBTOOL_TVSPLASH}")
		list(APPEND WUHBTOOL_DEPS "${WUHBTOOL_TVSPLASH}")
	endif()

	if(DEFINED WUHBTOOL_DRCSPLASH)
		get_filename_component(WUHBTOOL_DRCSPLASH "${WUHBTOOL_DRCSPLASH}" ABSOLUTE)
		list(APPEND WUHBTOOL_ARGS "--drc-image=${WUHBTOOL_DRCSPLASH}")
		list(APPEND WUHBTOOL_DEPS "${WUHBTOOL_DRCSPLASH}")
	endif()

	add_custom_command(
		OUTPUT "${WUHBTOOL_OUTPUT}"
		COMMAND "${WUT_WUHBTOOL_EXE}" ${WUHBTOOL_ARGS}
		DEPENDS ${WUHBTOOL_DEPS}
		COMMENT "Building WUHB bundle target ${outtarget}"
		VERBATIM
	)

	add_custom_target(${outtarget} ALL DEPENDS "${WUHBTOOL_OUTPUT}")
	dkp_set_target_file(${outtarget} "${WUHBTOOL_OUTPUT}")
endfunction()

function(wut_add_exports target exports_file)
	get_filename_component(exports_file "${exports_file}" ABSOLUTE)
	get_target_property(RPL_BINARY_DIR ${target} BINARY_DIR)

	__dkp_asm_lang(lang wut_add_exports)
	set(genfolder "${RPL_BINARY_DIR}/.dkp-generated")
	set(genbase "${genfolder}/${target}")
	add_custom_command(
		OUTPUT "${genbase}_exports.s" "${genbase}_imports.s" "${genbase}_imports.ld"
		COMMAND ${CMAKE_COMMAND} -E make_directory "${genfolder}"
		COMMAND ${WUT_RPLEXPORTGEN_EXE} "${exports_file}" "${genbase}_exports.s"
		COMMAND ${WUT_RPLIMPORTGEN_EXE} "${exports_file}" "${genbase}_imports.s" "${genbase}_imports.ld"
		DEPENDS "${exports_file}"
		COMMENT "Generating import/export stubs for ${target}"
		VERBATIM
	)

	target_sources(${target} PRIVATE "${genbase}_exports.s")
	set_source_files_properties("${genbase}_exports.s" PROPERTIES LANGUAGE "${lang}")

	add_library(${target}_imports OBJECT "${genbase}_imports.s")
	set_source_files_properties("${genbase}_imports.s" PROPERTIES LANGUAGE "${lang}")
	target_link_options(${target}_imports INTERFACE "-T${genbase}_imports.ld")
endfunction()

function(wut_link_rpl target)
	if(NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "wut_link_rpl: must provide at least one input RPL")
	endif()

	foreach(libname IN LISTS ARGN)
		if(NOT TARGET ${libname}_imports)
			message(FATAL_ERROR "wut_link_rpl: library ${libname} is not a valid target")
		endif()

		target_link_libraries(${target} PRIVATE ${libname}_imports)
	endforeach()
endfunction()
