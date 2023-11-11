# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform identification flags
set(NINTENDO_3DS TRUE)

# Platform settings
set(CTR_ARCH_SETTINGS "-march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft")
set(CTR_COMMON_FLAGS  "-mword-relocations -ffunction-sections -D__3DS__")
set(CTR_LINKER_FLAGS  "-L${CTR_ROOT}/lib -L${DEVKITPRO}/portlibs/3ds/lib -specs=3dsx.specs")
set(CTR_STANDARD_LIBRARIES "-lctru -lm")
set(CTR_STANDARD_INCLUDE_DIRECTORIES "${CTR_ROOT}/include")

__dkp_init_platform_settings(CTR)

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

function(ctr_generate_smdh)
	cmake_parse_arguments(PARSE_ARGV 0 SMDH "" "OUTPUT;NAME;DESCRIPTION;AUTHOR;ICON" "")
	if (NOT CTR_SMDHTOOL_EXE)
		message(FATAL_ERROR "Could not find smdhtool: try installing 3ds-tools")
	endif()
	if (NOT DEFINED SMDH_OUTPUT)
		if(DEFINED SMDH_UNPARSED_ARGUMENTS)
			list(GET SMDH_UNPARSED_ARGUMENTS 0 SMDH_OUTPUT)
		else()
			message(FATAL_ERROR "ctr_generate_smdh: missing OUTPUT argument")
		endif()
	endif()
	if (NOT DEFINED SMDH_NAME)
		set(SMDH_NAME "${CMAKE_PROJECT_NAME}")
	endif()
	if (NOT DEFINED SMDH_DESCRIPTION)
		set(SMDH_DESCRIPTION "Built with devkitARM & libctru")
	endif()
	if (NOT DEFINED SMDH_AUTHOR)
		set(SMDH_AUTHOR "Unspecified Author")
	endif()
	if (NOT DEFINED SMDH_ICON)
		if(NOT CTR_DEFAULT_ICON)
			message(FATAL_ERROR "ctr_generate_smdh: could not find default icon, try installing libctru")
		endif()
		set(SMDH_ICON "${CTR_DEFAULT_ICON}")
	else()
		get_filename_component(SMDH_ICON "${SMDH_ICON}" ABSOLUTE)
	endif()

	get_filename_component(SMDH_OUTPUT "${SMDH_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	add_custom_command(
		OUTPUT "${SMDH_OUTPUT}"
		COMMAND ${CTR_SMDHTOOL_EXE} --create "${SMDH_NAME}" "${SMDH_DESCRIPTION}" "${SMDH_AUTHOR}" "${SMDH_ICON}" "${SMDH_OUTPUT}"
		DEPENDS "${SMDH_ICON}"
		VERBATIM
	)
endfunction()

function(ctr_create_3dsx target)
	cmake_parse_arguments(PARSE_ARGV 1 CTR_3DSXTOOL "NOSMDH" "TARGET;OUTPUT;SMDH;ROMFS" "")

	if (NOT CTR_3DSXTOOL_EXE)
		message(FATAL_ERROR "Could not find 3dsxtool: try installing 3ds-tools")
	endif()

	if(DEFINED CTR_3DSXTOOL_TARGET)
		set(intarget "${CTR_3DSXTOOL_TARGET}")
		set(outtarget "${target}")
	else()
		set(intarget "${target}")
		set(outtarget "${target}_3dsx")
	endif()

	if(NOT TARGET "${intarget}")
		message(FATAL_ERROR "ctr_create_3dsx: target '${intarget}' not defined")
	endif()

	if(DEFINED CTR_3DSXTOOL_OUTPUT)
		get_filename_component(CTR_3DSXTOOL_OUTPUT "${CTR_3DSXTOOL_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	elseif(DEFINED CTR_3DSXTOOL_TARGET)
		set(CTR_3DSXTOOL_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.3dsx")
	else()
		__dkp_target_derive_name(CTR_3DSXTOOL_OUTPUT ${intarget} ".3dsx")
	endif()

	set(CTR_3DSXTOOL_ARGS "$<TARGET_FILE:${intarget}>" "${CTR_3DSXTOOL_OUTPUT}")
	set(CTR_3DSXTOOL_DEPS ${intarget})

	if (DEFINED CTR_3DSXTOOL_SMDH AND CTR_3DSXTOOL_NOSMDH)
		message(FATAL_ERROR "ctr_create_3dsx: cannot specify SMDH and NOSMDH at the same time")
	endif()

	if (NOT DEFINED CTR_3DSXTOOL_SMDH AND NOT CTR_3DSXTOOL_NOSMDH)
		set(CTR_3DSXTOOL_SMDH "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.default.smdh")
		ctr_generate_smdh(OUTPUT "${CTR_3DSXTOOL_SMDH}")
	endif()

	if (DEFINED CTR_3DSXTOOL_SMDH)
		get_filename_component(CTR_3DSXTOOL_SMDH "${CTR_3DSXTOOL_SMDH}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
		list(APPEND CTR_3DSXTOOL_ARGS "--smdh=${CTR_3DSXTOOL_SMDH}")
		list(APPEND CTR_3DSXTOOL_DEPS "${CTR_3DSXTOOL_SMDH}")
	endif()

	if (DEFINED CTR_3DSXTOOL_ROMFS)
		if (TARGET "${CTR_3DSXTOOL_ROMFS}")
			get_target_property(_folder "${CTR_3DSXTOOL_ROMFS}" DKP_ASSET_FOLDER)
			if (NOT _folder)
				message(FATAL_ERROR "ctr_create_3dsx: not a valid asset target")
			endif()
			list(APPEND CTR_3DSXTOOL_ARGS "--romfs=${_folder}")
			list(APPEND CTR_3DSXTOOL_DEPS ${CTR_3DSXTOOL_ROMFS} $<TARGET_PROPERTY:${CTR_3DSXTOOL_ROMFS},DKP_ASSET_FILES>)
		else()
			get_filename_component(CTR_3DSXTOOL_ROMFS "${CTR_3DSXTOOL_ROMFS}" ABSOLUTE)
			if (NOT IS_DIRECTORY "${CTR_3DSXTOOL_ROMFS}")
				message(FATAL_ERROR "ctr_create_3dsx: cannot find romfs dir: ${CTR_3DSXTOOL_ROMFS}")
			endif()
			list(APPEND CTR_3DSXTOOL_ARGS "--romfs=${CTR_3DSXTOOL_ROMFS}")
		endif()
	endif()

	add_custom_command(
		OUTPUT "${CTR_3DSXTOOL_OUTPUT}"
		COMMAND "${CTR_3DSXTOOL_EXE}" ${CTR_3DSXTOOL_ARGS}
		DEPENDS ${CTR_3DSXTOOL_DEPS}
		COMMENT "Building 3DSX executable target ${outtarget}"
		VERBATIM
	)

	add_custom_target(${outtarget} ALL DEPENDS "${CTR_3DSXTOOL_OUTPUT}")
	dkp_set_target_file(${outtarget} "${CTR_3DSXTOOL_OUTPUT}")
endfunction()

function(ctr_add_shader_library target)
	cmake_parse_arguments(PARSE_ARGV 1 CTR_PICASSO "" "OUTPUT" "SOURCES")

	if (NOT CTR_PICASSO_EXE)
		message(FATAL_ERROR "Could not find picasso: try installing picasso")
	endif()

	if(DEFINED CTR_PICASSO_OUTPUT)
		get_filename_component(CTR_PICASSO_OUTPUT "${CTR_PICASSO_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	else()
		set(CTR_PICASSO_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.shbin")
	endif()

	if(NOT DEFINED CTR_PICASSO_SOURCES AND DEFINED CTR_PICASSO_UNPARSED_ARGUMENTS)
		set(CTR_PICASSO_SOURCES "${CTR_PICASSO_UNPARSED_ARGUMENTS}")
	else()
		message(FATAL_ERROR "ctr_add_shader_library: must provide at least one source code file")
	endif()

	add_custom_command(
		OUTPUT "${CTR_PICASSO_OUTPUT}"
		COMMAND "${CTR_PICASSO_EXE}" -o "${CTR_PICASSO_OUTPUT}" ${CTR_PICASSO_SOURCES}
		DEPENDS ${CTR_PICASSO_SOURCES}
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMENT "Building shader library ${target}"
		VERBATIM
	)

	add_custom_target(${target} DEPENDS "${CTR_PICASSO_OUTPUT}")
	dkp_set_target_file(${target} "${CTR_PICASSO_OUTPUT}")
endfunction()

function(ctr_add_graphics_target target kind)
	cmake_parse_arguments(PARSE_ARGV 2 CTR_TEX3DS "" "OUTPUT" "INPUTS;OPTIONS")

	if (NOT CTR_TEX3DS_EXE)
		message(FATAL_ERROR "Could not find tex3ds: try installing tex3ds")
	endif()

	if(DEFINED CTR_TEX3DS_OUTPUT)
		get_filename_component(CTR_TEX3DS_OUTPUT "${CTR_TEX3DS_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	else()
		set(CTR_TEX3DS_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.t3x")
	endif()

	set(CTR_TEX3DS_ARGS -o "${CTR_TEX3DS_OUTPUT}")
	set(CTR_TEX3DS_DEPS "")

	string(TOUPPER "${kind}" kind)
	if(kind STREQUAL "IMAGE")
		# Nothing on purpose
	elseif(kind STREQUAL "CUBEMAP")
		list(APPEND CTR_TEX3DS_ARGS "--cubemap")
	elseif(kind STREQUAL "SKYBOX")
		list(APPEND CTR_TEX3DS_ARGS "--skybox")
	elseif(kind STREQUAL "ATLAS")
		list(APPEND CTR_TEX3DS_ARGS "--atlas")
	else()
		message(FATAL_ERROR "ctr_add_graphics_target: invalid mode: ${kind}")
	endif()

	list(LENGTH CTR_TEX3DS_INPUTS numinputs)
	if(numinputs LESS 1)
		message(FATAL_ERROR "ctr_add_graphics_target: must provide at least one input")
	endif()
	if(NOT kind STREQUAL "ATLAS" AND numinputs GREATER 1)
		message(FATAL_ERROR "ctr_add_graphics_target: multiple inputs only supported with atlas mode")
	endif()

	list(APPEND CTR_TEX3DS_ARGS ${CTR_TEX3DS_OPTIONS})
	foreach(input IN LISTS CTR_TEX3DS_INPUTS)
		dkp_resolve_file(infile "${input}")
		list(APPEND CTR_TEX3DS_ARGS "${infile}")

		if (TARGET "${input}")
			list(APPEND CTR_TEX3DS_DEPS ${input} "${infile}")
		else()
			list(APPEND CTR_TEX3DS_DEPS "${infile}")
		endif()
	endforeach()

	add_custom_command(
		OUTPUT "${CTR_TEX3DS_OUTPUT}"
		COMMAND "${CTR_TEX3DS_EXE}" ${CTR_TEX3DS_ARGS}
		DEPENDS ${CTR_TEX3DS_DEPS}
		COMMENT "Converting graphics target ${target}"
		VERBATIM
	)

	add_custom_target(${target} DEPENDS "${CTR_TEX3DS_OUTPUT}")
	dkp_set_target_file(${target} "${CTR_TEX3DS_OUTPUT}")
endfunction()
