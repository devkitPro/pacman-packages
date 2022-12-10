# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform identification flags
set(NINTENDO_DS TRUE)

if("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv5te")
	set(ARM9 TRUE)
elseif("${CMAKE_SYSTEM_PROCESSOR}" STREQUAL "armv4t")
	set(ARM7 TRUE)
else()
	message(FATAL_ERROR "Unknown value for CMAKE_SYSTEM_PROCESSOR: ${CMAKE_SYSTEM_PROCESSOR}")
endif()

set(NDS_LINKER_FLAGS_COMMON "-L${CALICO_ROOT}/lib -L${NDS_ROOT}/lib")
set(NDS_LINKER_FLAGS_ARM9 "-specs=${CALICO_ROOT}/share/ds9.specs")
set(NDS_LINKER_FLAGS_ARM7 "-specs=${CALICO_ROOT}/share/ds7.specs")
set(NDS_STANDARD_LIBRARIES_ARM9 "-lnds9 -lcalico_ds9")
set(NDS_STANDARD_LIBRARIES_ARM7 "-lnds7 -lcalico_ds7")

# Platform settings
set(NDS_STANDARD_INCLUDE_DIRECTORIES "${CALICO_ROOT}/include" "${NDS_ROOT}/include")
if(ARM9)
	set(NDS_ARCH_SETTINGS "-march=armv5te -mtune=arm946e-s")
	set(NDS_COMMON_FLAGS  "-ffunction-sections -fdata-sections -D__NDS__ -DARM9")
	set(NDS_LINKER_FLAGS  "${NDS_LINKER_FLAGS_COMMON} -L${DEVKITPRO}/portlibs/nds/lib ${NDS_LINKER_FLAGS_ARM9}")
	set(NDS_STANDARD_LIBRARIES "${NDS_STANDARD_LIBRARIES_ARM9}")
elseif(ARM7)
	set(NDS_ARCH_SETTINGS "-march=armv4t -mtune=arm7tdmi")
	set(NDS_COMMON_FLAGS  "-ffunction-sections -fdata-sections -D__NDS__ -DARM7")
	set(NDS_LINKER_FLAGS  "${NDS_LINKER_FLAGS_COMMON} ${NDS_LINKER_FLAGS_ARM7}")
	set(NDS_STANDARD_LIBRARIES "${NDS_STANDARD_LIBRARIES_ARM7}")
endif()

if(NOT DEFINED NDS_ARCH_THUMB AND ARM7)
	set(NDS_ARCH_THUMB TRUE)
endif()

if(NDS_ARCH_THUMB)
	string(APPEND NDS_ARCH_SETTINGS " -mthumb")
endif()

__dkp_init_platform_settings(NDS)

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

if(ARM9)

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
		set(NDSTOOL_ARM7_WAS_BLANK TRUE)
		set(NDSTOOL_ARM7 "maine")
	endif()

	if(NOT TARGET "${NDSTOOL_ARM7}" AND NOT IS_ABSOLUTE "${NDSTOOL_ARM7}")
		set(NDSTOOL_ARM7 "${CALICO_ROOT}/bin/ds7_${NDSTOOL_ARM7}.elf")

		if(NOT EXISTS "${NDSTOOL_ARM7}")
			if(NOT NDSTOOL_ARM7_WAS_BLANK)
				message(FATAL_ERROR "nds_create_rom: could not find default ARM7 component")
			else()
				message(FATAL_ERROR "nds_create_rom: ARM7 component must either be a default component name, an imported target or an absolute path")
			endif()
		endif()
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
		if(NOT NDS_DEFAULT_ICON)
			message(FATAL_ERROR "nds_create_rom: could not find default icon, try installing libnds")
		endif()
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
