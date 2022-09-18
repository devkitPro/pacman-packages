# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform identification flags
set(NINTENDO_SWITCH TRUE)

# Platform settings
set(NX_ARCH_SETTINGS "-march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -ftls-model=local-exec")
set(NX_COMMON_FLAGS  "-ffunction-sections -fdata-sections -D__SWITCH__")
set(NX_LINKER_FLAGS  "-L${NX_ROOT}/lib -L${DEVKITPRO}/portlibs/switch/lib -fPIE -specs=${NX_ROOT}/switch.specs")
set(NX_STANDARD_LIBRARIES "-lnx -lm")
set(NX_STANDARD_INCLUDE_DIRECTORIES "${NX_ROOT}/include")

# Enable position-independent code
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

__dkp_init_platform_settings(NX)

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

function(nx_generate_nacp)
	cmake_parse_arguments(PARSE_ARGV 0 NACP "" "OUTPUT;NAME;AUTHOR;VERSION" "")
	if (NOT DEFINED NACP_OUTPUT)
		if(DEFINED NACP_UNPARSED_ARGUMENTS)
			list(GET NACP_UNPARSED_ARGUMENTS 0 NACP_OUTPUT)
		else()
			message(FATAL_ERROR "nx_generate_nacp: missing OUTPUT argument")
		endif()
	endif()
	if (NOT DEFINED NACP_NAME)
		set(NACP_NAME "${CMAKE_PROJECT_NAME}")
	endif()
	if (NOT DEFINED NACP_AUTHOR)
		set(NACP_AUTHOR "Unspecified Author")
	endif()
	if (NOT DEFINED NACP_VERSION)
		if (PROJECT_VERSION)
			set(NACP_VERSION "${PROJECT_VERSION}")
		else()
			set(NACP_VERSION "1.0.0")
		endif()
	endif()

	get_filename_component(NACP_OUTPUT "${NACP_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	add_custom_command(
		OUTPUT "${NACP_OUTPUT}"
		COMMAND "${NX_NACPTOOL_EXE}" --create "${NACP_NAME}" "${NACP_AUTHOR}" "${NACP_VERSION}" "${NACP_OUTPUT}"
		VERBATIM
	)
endfunction()

function(nx_create_nro target)
	cmake_parse_arguments(PARSE_ARGV 1 ELF2NRO "NOICON;NONACP" "TARGET;OUTPUT;ICON;NACP;ROMFS" "")

	if(DEFINED ELF2NRO_TARGET)
		set(intarget "${ELF2NRO_TARGET}")
		set(outtarget "${target}")
	else()
		set(intarget "${target}")
		set(outtarget "${target}_nro")
	endif()

	if(NOT TARGET "${intarget}")
		message(FATAL_ERROR "nx_create_nro: target '${intarget}' not defined")
	endif()

	if(DEFINED ELF2NRO_OUTPUT)
		get_filename_component(ELF2NRO_OUTPUT "${ELF2NRO_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	elseif(DEFINED ELF2NRO_TARGET)
		set(ELF2NRO_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.nro")
	else()
		__dkp_target_derive_name(ELF2NRO_OUTPUT ${intarget} ".nro")
	endif()

	set(ELF2NRO_ARGS "$<TARGET_FILE:${intarget}>" "${ELF2NRO_OUTPUT}")
	set(ELF2NRO_DEPS ${intarget})

	if (DEFINED ELF2NRO_ICON AND ELF2NRO_NOICON)
		message(FATAL_ERROR "nx_create_nro: cannot specify ICON and NOICON at the same time")
	endif()

	if (DEFINED ELF2NRO_NACP AND ELF2NRO_NONACP)
		message(FATAL_ERROR "nx_create_nro: cannot specify NACP and NONACP at the same time")
	endif()

	if (NOT DEFINED ELF2NRO_ICON AND NOT ELF2NRO_NOICON)
		set(ELF2NRO_ICON "${NX_DEFAULT_ICON}")
	endif()

	if (NOT DEFINED ELF2NRO_NACP AND NOT ELF2NRO_NONACP)
		set(ELF2NRO_NACP "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.default.nacp")
		nx_generate_nacp(OUTPUT "${ELF2NRO_NACP}")
	endif()

	if (DEFINED ELF2NRO_ICON)
		get_filename_component(ELF2NRO_ICON "${ELF2NRO_ICON}" ABSOLUTE)
		list(APPEND ELF2NRO_ARGS "--icon=${ELF2NRO_ICON}")
		list(APPEND ELF2NRO_DEPS "${ELF2NRO_ICON}")
	endif()

	if (DEFINED ELF2NRO_NACP)
		get_filename_component(ELF2NRO_NACP "${ELF2NRO_NACP}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
		list(APPEND ELF2NRO_ARGS "--nacp=${ELF2NRO_NACP}")
		list(APPEND ELF2NRO_DEPS "${ELF2NRO_NACP}")
	endif()

	if (DEFINED ELF2NRO_ROMFS)
		if (TARGET "${ELF2NRO_ROMFS}")
			get_target_property(_folder "${ELF2NRO_ROMFS}" DKP_ASSET_FOLDER)
			if (NOT _folder)
				message(FATAL_ERROR "nx_create_nro: not a valid asset target")
			endif()
			list(APPEND ELF2NRO_ARGS "--romfsdir=${_folder}")
			list(APPEND ELF2NRO_DEPS ${ELF2NRO_ROMFS} $<TARGET_PROPERTY:${ELF2NRO_ROMFS},DKP_ASSET_FILES>)
		else()
			get_filename_component(ELF2NRO_ROMFS "${ELF2NRO_ROMFS}" ABSOLUTE)
			if (NOT IS_DIRECTORY "${ELF2NRO_ROMFS}")
				message(FATAL_ERROR "nx_create_nro: cannot find romfs dir: ${ELF2NRO_ROMFS}")
			endif()
			list(APPEND ELF2NRO_ARGS "--romfsdir=${ELF2NRO_ROMFS}")
		endif()
	endif()

	add_custom_command(
		OUTPUT "${ELF2NRO_OUTPUT}"
		COMMAND "${NX_ELF2NRO_EXE}" ${ELF2NRO_ARGS}
		DEPENDS ${ELF2NRO_DEPS}
		COMMENT "Building NRO executable target ${outtarget}"
		VERBATIM
	)

	add_custom_target(${outtarget} ALL DEPENDS "${ELF2NRO_OUTPUT}")
	dkp_set_target_file(${outtarget} "${ELF2NRO_OUTPUT}")
endfunction()

function(nx_add_shader_program target source type)
	set(outfile "${CMAKE_CURRENT_BINARY_DIR}/${target}.dksh")
	add_custom_command(
		OUTPUT "${outfile}"
		COMMAND "${NX_UAM_EXE}" -o "${outfile}" -s ${type} "${source}"
		DEPENDS "${source}"
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMENT "Building shader program ${target}"
		VERBATIM
	)

	add_custom_target(${target} DEPENDS "${outfile}")
	dkp_set_target_file(${target} "${outfile}")
endfunction()
