# -----------------------------------------------------------------------------
# Platform configuration

# Include guard
if(NINTENDO_DS)
	return()
endif()

# Inherit settings from CMake's built-in Generic platform
include(Platform/Generic)

set(NINTENDO_DS TRUE)
set(NDS_ROOT ${DEVKITPRO}/libnds)

if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv5te")
	set(NDS_ARCH_SETTINGS "-march=armv5te -mtune=arm946e-s")
	set(NDS_COMMON_FLAGS  "${NDS_ARCH_SETTINGS} -ffunction-sections -fdata-sections -D__NDS__ -DARM9")
	set(NDS_LIB_DIRS      "-L${DEVKITPRO}/libnds/lib -L${DEVKITPRO}/portlibs/nds/lib")

	set(NDS_STANDARD_LIBRARIES "-lnds9")
	set(NDS_LINKER_FLAGS "-specs=ds_arm9.specs")
elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv4t")
	set(NDS_ARCH_SETTINGS "-march=armv4t -mthumb -mthumb-interwork")
	set(NDS_COMMON_FLAGS  "${NDS_ARCH_SETTINGS} -ffunction-sections -fdata-sections -D__NDS__ -DARM7")
	set(NDS_LIB_DIRS      "-L${DEVKITPRO}/libnds/lib")

	set(NDS_STANDARD_LIBRARIES "-lnds7")
	set(NDS_LINKER_FLAGS "-specs=ds_arm7.specs")
else()
	message(FATAL_ERROR "Unknown value for CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

set(NDS_STANDARD_INCLUDE_DIRECTORIES "${NDS_ROOT}/include")

set(CMAKE_EXECUTABLE_SUFFIX .elf)

set(CMAKE_C_FLAGS_INIT   "${NDS_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS_INIT "${NDS_COMMON_FLAGS}")
set(CMAKE_ASM_FLAGS_INIT "${NDS_COMMON_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${NDS_ARCH_SETTINGS} ${NDS_LIB_DIRS} ${NDS_LINKER_FLAGS}")

set(CMAKE_C_STANDARD_LIBRARIES "${NDS_STANDARD_LIBRARIES}" CACHE STRING "" FORCE)
set(CMAKE_CXX_STANDARD_LIBRARIES "${NDS_STANDARD_LIBRARIES}" CACHE STRING "" FORCE)
set(CMAKE_ASM_STANDARD_LIBRARIES "${NDS_STANDARD_LIBRARIES}" CACHE STRING "" FORCE)

set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "${NDS_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "${NDS_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_INCLUDE_DIRECTORIES "${NDS_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

# Include common devkitPro bits and pieces
include(dkp-linker-utils)
include(dkp-custom-target)
include(dkp-embedded-binary)
include(dkp-asset-folder)

function(nds_create_rom target)
	cmake_parse_arguments(NDSTOOL "" "NAME;SUBTITLE1;SUBTITLE2;ICON;NITROFS" "" ${ARGN})

	if (TARGET "${target}")
		get_target_property(TARGET_OUTPUT_NAME ${target} OUTPUT_NAME)
		if(NOT TARGET_OUTPUT_NAME)
			set(TARGET_OUTPUT_NAME "${target}")
		endif()
	else ()
		set(TARGET_OUTPUT_NAME "${target}")
	endif ()

	set(NDSTOOL_ARGS -c "${TARGET_OUTPUT_NAME}.nds")
	set(NDSTOOL_DEPS)

	if ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv5te")
		list(APPEND NDSTOOL_ARGS -9 "$<TARGET_FILE:${target}>")
		list(APPEND NDSTOOL_DEPS ${target})
	elseif ("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv4t")
		list(APPEND NDSTOOL_ARGS -7 "$<TARGET_FILE:${target}>")
		list(APPEND NDSTOOL_DEPS ${target})
	endif ()

	if (NOT DEFINED NDSTOOL_NAME)
		set(NDSTOOL_NAME "${CMAKE_PROJECT_NAME}")
	endif()
	if (NOT DEFINED NDSTOOL_SUBTITLE1)
		set(NDSTOOL_SUBTITLE1 "Built with devkitARM")
	endif()
	if (NOT DEFINED NDSTOOL_SUBTITLE2)
		set(NDSTOOL_SUBTITLE2 "http://devkitpro.org")
	endif()
	if (NOT DEFINED NDSTOOL_ICON)
		set(NDSTOOL_ICON "${NDS_DEFAULT_ICON}")
	endif()
	list(APPEND NDSTOOL_ARGS -b "${NDSTOOL_ICON}" "${NDSTOOL_NAME}\;${NDSTOOL_SUBTITLE1}\;${NDSTOOL_SUBTITLE2}")
	list(APPEND NDSTOOL_DEPS "${NDSTOOL_ICON}")

	if (DEFINED NDSTOOL_NITROFS)
		if (TARGET "${NDSTOOL_NITROFS}")
			get_target_property(_folder "${NDSTOOL_NITROFS}" DKP_ASSET_FOLDER)
			if (NOT _folder)
				message(FATAL_ERROR "nds_create_rom: not a valid asset target")
			endif()
			list(APPEND NDSTOOL_ARGS -d "${_folder}")
			list(APPEND NDSTOOL_DEPS ${NDSTOOL_NITROFS} $<TARGET_PROPERTY:${NDSTOOL_NITROFS},DKP_ASSET_FILES>)
		else()
			if (NOT IS_ABSOLUTE "${NDSTOOL_NITROFS}")
				set(NDSTOOL_NITROFS "${CMAKE_CURRENT_LIST_DIR}/${NDSTOOL_NITROFS}")
			endif()
			if (NOT IS_DIRECTORY "${NDSTOOL_NITROFS}")
				message(FATAL_ERROR "nds_create_rom: cannot find romfs dir: ${NDSTOOL_NITROFS}")
			endif()
			list(APPEND NDSTOOL_ARGS -d "${NDSTOOL_NITROFS}")
		endif()
	endif()

	add_custom_command(
		OUTPUT "${TARGET_OUTPUT_NAME}.nds"
		COMMAND "${NDS_NDSTOOL_EXE}" ${NDSTOOL_ARGS}
		DEPENDS ${NDSTOOL_DEPS}
		VERBATIM
	)

	add_custom_target(
		"${target}_nds" ALL
		DEPENDS "${TARGET_OUTPUT_NAME}.nds"
	)
endfunction()
