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
	cmake_parse_arguments(PARSE_ARGV 1 NDSTOOL "" "OUTPUT;ARM9;ARM7;NAME;SUBTITLE1;SUBTITLE2;ICON;NITROFS" "FLAGS")

	if (NOT NDS_NDSTOOL_EXE)
		message(FATAL_ERROR "Could not find ndstool: try installing ndstool")
	endif()

	if(DEFINED NDSTOOL_ARM9)
		set(intarget "${NDSTOOL_ARM9}")
		set(outtarget "${target}")
	else()
		set(intarget "${target}")
		set(outtarget "${target}_nds")
	endif()

	if(NOT DEFINED NDSTOOL_ARM7)
		if(NOT NDS_DEFAULT_ARM7)
			message(FATAL_ERROR "Could not find default ARM7 component: try installing default-arm7")
		endif()
		set(NDSTOOL_ARM7 "${NDS_DEFAULT_ARM7}")
	elseif(NOT TARGET "${NDSTOOL_ARM7}" AND NOT IS_ABSOLUTE "${NDSTOOL_ARM7}")
		message(FATAL_ERROR "nds_create_rom: ARM7 component must either be an imported target or an absolute path")
	endif()

	if(NOT TARGET "${intarget}")
		message(FATAL_ERROR "nds_create_rom: ARM9 target '${intarget}' not defined")
	endif()

	if(DEFINED NDSTOOL_OUTPUT)
		get_filename_component(NDSTOOL_OUTPUT "${NDSTOOL_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	elseif(DEFINED NDSTOOL_ARM9)
		set(NDSTOOL_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.nds")
	else()
		__dkp_target_derive_name(NDSTOOL_OUTPUT ${intarget} ".nds")
	endif()

	set(NDSTOOL_ARGS -c "${NDSTOOL_OUTPUT}" -9 "$<TARGET_FILE:${intarget}>")
	set(NDSTOOL_DEPS ${intarget} "${NDSTOOL_ARM7}")

	if (TARGET "${NDSTOOL_ARM7}")
		list(APPEND NDSTOOL_ARGS -7 "$<TARGET_FILE:${NDSTOOL_ARM7}>")
	else()
		list(APPEND NDSTOOL_ARGS -7 "${NDSTOOL_ARM7}")
	endif()

	if (NOT DEFINED NDSTOOL_NAME)
		set(NDSTOOL_NAME "${CMAKE_PROJECT_NAME}")
	endif()
	if (NOT DEFINED NDSTOOL_SUBTITLE1)
		set(NDSTOOL_SUBTITLE1 "Built with devkitARM")
	endif()
	if (NOT DEFINED NDSTOOL_SUBTITLE2)
		set(NDSTOOL_SUBTITLE2 "https://devkitpro.org")
	endif()
	if (NOT DEFINED NDSTOOL_ICON)
		set(NDSTOOL_ICON "${NDS_DEFAULT_ICON}")
	else()
		if(TARGET "${NDSTOOL_ICON}")
			list(APPEND NDSTOOL_DEPS ${NDSTOOL_ICON})
		endif()
		dkp_resolve_file(NDSTOOL_ICON "${NDSTOOL_ICON}")
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
			get_filename_component(NDSTOOL_NITROFS "${NDSTOOL_NITROFS}" ABSOLUTE)
			if (NOT IS_DIRECTORY "${NDSTOOL_NITROFS}")
				message(FATAL_ERROR "nds_create_rom: cannot find nitrofs dir: ${NDSTOOL_NITROFS}")
			endif()
			list(APPEND NDSTOOL_ARGS -d "${NDSTOOL_NITROFS}")
		endif()
	endif()

	if (DEFINED NDSTOOL_FLAGS)
		list(APPEND NDSTOOL_ARGS ${NDSTOOL_FLAGS})
	endif()

	add_custom_command(
		OUTPUT "${NDSTOOL_OUTPUT}"
		COMMAND "${NDS_NDSTOOL_EXE}" ${NDSTOOL_ARGS}
		DEPENDS ${NDSTOOL_DEPS}
		COMMENT "Building NDS ROM target ${outtarget}"
		VERBATIM
	)

	add_custom_target(${outtarget} ALL DEPENDS "${NDSTOOL_OUTPUT}")
	dkp_set_target_file(${outtarget} "${NDSTOOL_OUTPUT}")
endfunction()

endif()

include(dkp-gba-ds-utils)
