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

function(ctr_generate_smdh outfile)
	cmake_parse_arguments(SMDH "" "NAME;DESCRIPTION;AUTHOR;ICON" "" ${ARGN})
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
		set(SMDH_ICON "${CTR_DEFAULT_ICON}")
	endif()

	add_custom_command(
		OUTPUT "${outfile}"
		COMMAND ${CTR_SMDHTOOL_EXE} --create "${SMDH_NAME}" "${SMDH_DESCRIPTION}" "${SMDH_AUTHOR}" "${SMDH_ICON}" "${outfile}"
		VERBATIM
	)
endfunction()

function(ctr_create_3dsx target)
	cmake_parse_arguments(CTR_3DSXTOOL "NOSMDH" "SMDH;ROMFS" "" ${ARGN})

	get_target_property(TARGET_OUTPUT_NAME ${target} OUTPUT_NAME)
	if(NOT TARGET_OUTPUT_NAME)
		set(TARGET_OUTPUT_NAME "${target}")
	endif()

	set(CTR_3DSXTOOL_ARGS "$<TARGET_FILE:${target}>" "${TARGET_OUTPUT_NAME}.3dsx")
	set(CTR_3DSXTOOL_DEPS ${target})

	if (DEFINED CTR_3DSXTOOL_SMDH AND CTR_3DSXTOOL_NOSMDH)
		message(FATAL_ERROR "ctr_create_3dsx: cannot specify SMDH and NOSMDH at the same time")
	endif()

	if (NOT DEFINED CTR_3DSXTOOL_SMDH AND NOT CTR_3DSXTOOL_NOSMDH)
		set(CTR_3DSXTOOL_SMDH "${target}.default.smdh")
		ctr_generate_smdh(${CTR_3DSXTOOL_SMDH})
	endif()

	if (DEFINED CTR_3DSXTOOL_SMDH)
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
			if (NOT IS_ABSOLUTE "${CTR_3DSXTOOL_ROMFS}")
				set(CTR_3DSXTOOL_ROMFS "${CMAKE_CURRENT_LIST_DIR}/${CTR_3DSXTOOL_ROMFS}")
			endif()
			if (NOT IS_DIRECTORY "${CTR_3DSXTOOL_ROMFS}")
				message(FATAL_ERROR "ctr_create_3dsx: cannot find romfs dir: ${CTR_3DSXTOOL_ROMFS}")
			endif()
			list(APPEND CTR_3DSXTOOL_ARGS "--romfs=${CTR_3DSXTOOL_ROMFS}")
		endif()
	endif()

	add_custom_command(
		OUTPUT "${TARGET_OUTPUT_NAME}.3dsx"
		COMMAND "${CTR_3DSXTOOL_EXE}" ${CTR_3DSXTOOL_ARGS}
		DEPENDS ${CTR_3DSXTOOL_DEPS}
		VERBATIM
	)

	add_custom_target(
		"${target}_3dsx" ALL
		DEPENDS "${TARGET_OUTPUT_NAME}.3dsx"
	)
endfunction()

function(ctr_add_shader_library target)
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "ctr_add_shader_library: must provide at least one input file")
	endif()

	add_custom_command(
		OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.shbin"
		COMMAND "${CTR_PICASSO_EXE}" -o "${CMAKE_CURRENT_BINARY_DIR}/${target}.shbin" ${ARGN}
		DEPENDS ${ARGN}
		WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
		COMMENT "Building shader library ${target}"
	)

	add_custom_target(${target}
		DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${target}.shbin"
	)

	dkp_set_target_file(${target}
		"${CMAKE_CURRENT_BINARY_DIR}/${target}.shbin"
	)
endfunction()

function(ctr_add_graphics_target target kind)
	cmake_parse_arguments(CTR_TEX3DS "" "" "INPUTS;OPTIONS" ${ARGN})

	set(CTR_TEX3DS_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.t3x")
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
	foreach(input ${CTR_TEX3DS_INPUTS})
		if (NOT TARGET "${input}" AND NOT IS_ABSOLUTE "${input}")
			set(input "${CMAKE_CURRENT_LIST_DIR}/${input}")
		endif()

		dkp_resolve_file(infile ${input})
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
		DEPENDS ${CTR_3DSXTOOL_DEPS}
		WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
		COMMENT "Converting graphics target ${target}"
	)

	add_custom_target(${target} DEPENDS "${CTR_TEX3DS_OUTPUT}")
	dkp_set_target_file(${target} "${CTR_TEX3DS_OUTPUT}")
endfunction()
