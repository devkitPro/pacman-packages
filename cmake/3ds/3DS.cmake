cmake_minimum_required(VERSION 3.7)
include(${CMAKE_CURRENT_LIST_DIR}/devkitARM.cmake)
include(dkp-custom-target)
include(dkp-embedded-binary)
include(dkp-asset-folder)

set(CMAKE_SYSTEM_PROCESSOR "armv6k")

set(CTR_ARCH_SETTINGS "-march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft")
set(CTR_COMMON_FLAGS  "${CTR_ARCH_SETTINGS} -mword-relocations -ffunction-sections -D__3DS__")
set(CTR_LIB_DIRS      "-L${DEVKITPRO}/libctru/lib -L${DEVKITPRO}/portlibs/3ds/lib")

set(CMAKE_C_FLAGS_INIT   "${CTR_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${CTR_COMMON_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT "${CTR_COMMON_FLAGS}")

set(CMAKE_EXE_LINKER_FLAGS_INIT "${CTR_ARCH_SETTINGS} ${CTR_LIB_DIRS} -specs=3dsx.specs")

set(CMAKE_FIND_ROOT_PATH
	${CMAKE_FIND_ROOT_PATH}
	${DEVKITPRO}/portlibs/3ds
	${DEVKITPRO}/libctru
)

# Set pkg-config for the same
find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/3ds/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(WARNING "Could not find arm-none-eabi-pkg-config: try installing 3ds-pkg-config")
endif()

find_program(CTR_SMDHTOOL_EXE NAMES smdhtool HINTS "${DEVKITPRO}/tools/bin")
if (NOT CTR_SMDHTOOL_EXE)
	message(WARNING "Could not find smdhtool: try installing 3ds-tools")
endif()

find_program(CTR_3DSXTOOL_EXE NAMES 3dsxtool HINTS "${DEVKITPRO}/tools/bin")
if (NOT CTR_3DSXTOOL_EXE)
	message(WARNING "Could not find 3dsxtool: try installing 3ds-tools")
endif()

find_program(CTR_PICASSO_EXE NAMES picasso HINTS "${DEVKITPRO}/tools/bin")
if (NOT CTR_PICASSO_EXE)
	message(WARNING "Could not find picasso: try installing picasso")
endif()

find_file(CTR_DEFAULT_ICON NAMES default_icon.png HINTS "${DEVKITPRO}/libctru" NO_CMAKE_FIND_ROOT_PATH)
if (NOT CTR_DEFAULT_ICON)
	message(WARNING "Could not find default icon: try installing libctru")
endif()

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
		"${TARGET_OUTPUT_NAME}_3dsx" ALL
		DEPENDS "${target}.3dsx"
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

set(NINTENDO_3DS TRUE)

set(CTR_ROOT ${DEVKITPRO}/libctru)

set(CTR_STANDARD_LIBRARIES "-lctru -lm")
set(CMAKE_C_STANDARD_LIBRARIES "${CTR_STANDARD_LIBRARIES}" CACHE STRING "" FORCE)
set(CMAKE_CXX_STANDARD_LIBRARIES "${CTR_STANDARD_LIBRARIES}" CACHE STRING "" FORCE)
set(CMAKE_ASM_STANDARD_LIBRARIES "${CTR_STANDARD_LIBRARIES}" CACHE STRING "" FORCE)

#for some reason cmake (3.14.3) doesn't appreciate having \" here
set(CTR_STANDARD_INCLUDE_DIRECTORIES "${CTR_ROOT}/include")
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "${CTR_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "${CTR_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_INCLUDE_DIRECTORIES "${CTR_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
