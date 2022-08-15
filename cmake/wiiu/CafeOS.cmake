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
	cmake_parse_arguments(ELF2RPL "IS_RPX" "" "" ${ARGN})

	set(ELF2RPL_FLAGS "")
	if(ELF2RPL_IS_RPX)
		# Do nothing - the defaults are good for RPX
		set(RPL_SUFFIX ".rpx")
	else()
		set(RPL_SUFFIX ".rpl")
		list(APPEND ELF2RPL_FLAGS "--rpl")
		target_link_options(${target} PRIVATE "-specs=${WUT_ROOT}/share/rpl.specs")
	endif()

	get_target_property(RPL_OUTPUT ${target} OUTPUT_NAME)
	if(NOT RPL_OUTPUT)
		set(RPL_OUTPUT "${target}")
	endif()
	set(RPL_OUTPUT "${RPL_OUTPUT}${RPL_SUFFIX}")

	add_custom_command(TARGET ${target} POST_BUILD
		COMMAND ${WUT_ELF2RPL_EXE} ${ELF2RPL_FLAGS} $<TARGET_FILE:${target}> ${RPL_OUTPUT}
		BYPRODUCTS ${RPL_OUTPUT}
		COMMENT "Creating ${RPL_OUTPUT}"
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
	cmake_parse_arguments(WUHBTOOL "" "CONTENT;NAME;SHORTNAME;AUTHOR;ICON;TVSPLASH;DRCSPLASH" "" ${ARGN})

	get_target_property(RPL_PATH   ${target} WUT_RPL)
	get_target_property(RPL_IS_RPX ${target} WUT_IS_RPX)
	if(NOT RPL_IS_RPX OR NOT RPL_PATH)
		message(FATAL_ERROR "wut_create_wuhb: target must be a valid .rpx (use wut_create_rpx)")
	endif()

	get_target_property(RPL_OUTPUT_NAME ${target} OUTPUT_NAME)
	if(NOT RPL_OUTPUT_NAME)
		set(RPL_OUTPUT_NAME "${target}")
	endif()

	set(WUHBTOOL_ARGS "${RPL_PATH}" "${RPL_OUTPUT_NAME}.wuhb")
	set(WUHBTOOL_DEPS ${target})

	if(DEFINED WUHBTOOL_CONTENT)
		if (TARGET "${WUHBTOOL_CONTENT}")
			get_target_property(_folder "${WUHBTOOL_CONTENT}" DKP_ASSET_FOLDER)
			if (NOT _folder)
				message(FATAL_ERROR "wut_create_wuhb: not a valid asset target")
			endif()
			list(APPEND WUHBTOOL_ARGS "--content=${_folder}")
			list(APPEND WUHBTOOL_DEPS ${WUHBTOOL_CONTENT} $<TARGET_PROPERTY:${WUHBTOOL_CONTENT},DKP_ASSET_FILES>)
		else()
			if (NOT IS_ABSOLUTE "${WUHBTOOL_CONTENT}")
				set(WUHBTOOL_CONTENT "${CMAKE_CURRENT_LIST_DIR}/${WUHBTOOL_CONTENT}")
			endif()
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
		list(APPEND WUHBTOOL_ARGS "--icon=${WUHBTOOL_ICON}")
		list(APPEND WUHBTOOL_DEPS "${WUHBTOOL_ICON}")
	endif()

	if(DEFINED WUHBTOOL_TVSPLASH)
		list(APPEND WUHBTOOL_ARGS "--tv-image=${WUHBTOOL_TVSPLASH}")
		list(APPEND WUHBTOOL_DEPS "${WUHBTOOL_TVSPLASH}")
	endif()

	if(DEFINED WUHBTOOL_DRCSPLASH)
		list(APPEND WUHBTOOL_ARGS "--drc-image=${WUHBTOOL_DRCSPLASH}")
		list(APPEND WUHBTOOL_DEPS "${WUHBTOOL_DRCSPLASH}")
	endif()

	add_custom_command(
		OUTPUT "${RPL_OUTPUT_NAME}.wuhb"
		COMMAND "${WUT_WUHBTOOL_EXE}" ${WUHBTOOL_ARGS}
		DEPENDS ${WUHBTOOL_DEPS}
		VERBATIM
	)

	add_custom_target(
		"${target}_wuhb" ALL
		DEPENDS "${RPL_OUTPUT_NAME}.wuhb"
	)
endfunction()

function(wut_add_exports target exports_file)
	if(NOT IS_ABSOLUTE ${exports_file})
		set(exports_file "${CMAKE_CURRENT_SOURCE_DIR}/${exports_file}")
	endif()

	get_target_property(RPL_NAME ${target} OUTPUT_NAME)
	if(NOT RPL_NAME)
		set(RPL_NAME "${target}")
	endif()

	add_custom_command(
		OUTPUT ${RPL_NAME}_exports.s
		COMMAND ${WUT_RPLEXPORTGEN_EXE} ${exports_file} ${RPL_NAME}_exports.s
		DEPENDS ${exports_file}
	)
	target_sources(${target} PRIVATE ${RPL_NAME}_exports.s)
	set_source_files_properties(${RPL_NAME}_exports.s PROPERTIES LANGUAGE C)

	get_filename_component(RPL_IMPORT_LD ${target}_imports.ld ABSOLUTE BASE_DIR ${CMAKE_CURRENT_BINARY_DIR})
	add_custom_command(
		OUTPUT ${RPL_NAME}_imports.s ${RPL_NAME}_imports.ld
		COMMAND ${WUT_RPLIMPORTGEN_EXE} ${exports_file} ${RPL_NAME}_imports.s ${RPL_NAME}_imports.ld
		DEPENDS ${exports_file}
	)
	add_library(${target}_imports OBJECT ${RPL_NAME}_imports.s)
	set_source_files_properties(${RPL_NAME}_imports.s PROPERTIES LANGUAGE C)
	set_target_properties(${target}_imports PROPERTIES WUT_RPL_IMPORT_LD "${RPL_IMPORT_LD}")
endfunction()

function(wut_link_rpl target)
	if(NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "wut_link_rpl: must provide at least one input RPL")
	endif()

	foreach(libname ${ARGN})
		if(NOT TARGET ${libname}_imports)
			message(FATAL_ERROR "wut_link_rpl: library ${libname} is not a valid target")
		endif()

		get_target_property(RPL_IMPORT_LD ${libname}_imports WUT_RPL_IMPORT_LD)
		if(NOT RPL_IMPORT_LD)
			message(FATAL_ERROR "wut_link_rpl: library ${libname} does not contain RPL exports")
		endif()

		target_sources(${target} PRIVATE $<TARGET_OBJECTS:${libname}_imports>)
		target_link_options(${target} PRIVATE "-T${RPL_IMPORT_LD}")
	endforeach()
endfunction()
