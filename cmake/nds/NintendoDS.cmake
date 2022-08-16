# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform identification flags
set(NINTENDO_DS TRUE)

# Platform settings
set(NDS_STANDARD_INCLUDE_DIRECTORIES "${NDS_ROOT}/include")
if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv5te")
	set(NDS_ARCH_SETTINGS "-march=armv5te -mtune=arm946e-s")
	set(NDS_COMMON_FLAGS  "-ffunction-sections -fdata-sections -D__NDS__ -DARM9")
	set(NDS_LINKER_FLAGS  "-L${NDS_ROOT}/lib -L${DEVKITPRO}/portlibs/nds/lib -specs=ds_arm9.specs")
	set(NDS_STANDARD_LIBRARIES "-lnds9")
elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv4t")
	set(NDS_ARCH_SETTINGS "-march=armv4t -mtune=arm7tdmi -mthumb -mthumb-interwork")
	set(NDS_COMMON_FLAGS  "-ffunction-sections -fdata-sections -D__NDS__ -DARM7")
	set(NDS_LINKER_FLAGS  "-L${NDS_ROOT}/lib -specs=ds_arm7.specs")
	set(NDS_STANDARD_LIBRARIES "-lnds7")
else()
	message(FATAL_ERROR "Unknown value for CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

__dkp_init_platform_settings(NDS)

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv5te")

function(nds_create_rom target)
	cmake_parse_arguments(PARSE_ARGV 1 NDSTOOL "" "ARM7;NAME;SUBTITLE1;SUBTITLE2;ICON;NITROFS" "")

	if (TARGET "${target}")
		get_target_property(TARGET_OUTPUT_NAME ${target} OUTPUT_NAME)
		if(NOT TARGET_OUTPUT_NAME)
			set(TARGET_OUTPUT_NAME "${target}")
		endif()
	else ()
		set(TARGET_OUTPUT_NAME "${target}")
	endif ()

	set(NDSTOOL_ARGS -c "${TARGET_OUTPUT_NAME}.nds" -9 "$<TARGET_FILE:${target}>")
	set(NDSTOOL_DEPS ${target})

	if (DEFINED NDSTOOL_ARM7)
		if (TARGET "${NDSTOOL_ARM7}")
			list(APPEND NDSTOOL_ARGS -7 "$<TARGET_FILE:${NDSTOOL_ARM7}>")
		else()
			list(APPEND NDSTOOL_ARGS -7 "${NDSTOOL_ARM7}")
		endif()
		list(APPEND NDSTOOL_DEPS "${NDSTOOL_ARM7}")
	endif()

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

endif()
