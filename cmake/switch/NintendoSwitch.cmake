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
	if (NOT NX_NACPTOOL_EXE)
		message(FATAL_ERROR "Could not find nacptool: try installing switch-tools")
	endif()
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

	if (NOT NX_ELF2NRO_EXE)
		message(FATAL_ERROR "Could not find elf2nro: try installing switch-tools")
	endif()

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
		if(NOT NX_DEFAULT_ICON)
			message(FATAL_ERROR "nx_create_nro: could not find default icon, try installing libnx")
		endif()
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

function(nx_create_exefs target)
	cmake_parse_arguments(PARSE_ARGV 1 NX_EXEFS "" "TARGET;OUTPUT;CONFIG" "")

	if (NOT NX_ELF2NSO_EXE)
		message(FATAL_ERROR "Could not find elf2nso: try installing switch-tools")
	endif()

	if (NOT NX_NPDMTOOL_EXE)
		message(FATAL_ERROR "Could not find npdmtool: try installing switch-tools")
	endif()

	if (NOT NX_BUILD_PFS0_EXE)
		message(FATAL_ERROR "Could not find build_pfs0: try installing switch-tools")
	endif()

	if(DEFINED NX_EXEFS_TARGET)
		set(intarget "${NX_EXEFS_TARGET}")
		set(outtarget "${target}")
	else()
		set(intarget "${target}")
		set(outtarget "${target}_nsp")
	endif()

	if(NOT TARGET "${intarget}")
		message(FATAL_ERROR "nx_create_exefs: target '${intarget}' not defined")
	endif()

	if(DEFINED NX_EXEFS_OUTPUT)
		get_filename_component(NX_EXEFS_OUTPUT "${NX_EXEFS_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	elseif(DEFINED NX_EXEFS_TARGET)
		set(NX_EXEFS_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.nsp")
	else()
		__dkp_target_derive_name(NX_EXEFS_OUTPUT ${intarget} ".nsp")
	endif()

	if(DEFINED NX_EXEFS_CONFIG)
		get_filename_component(NX_EXEFS_CONFIG "${NX_EXEFS_CONFIG}" ABSOLUTE)
	else()
		message(FATAL_ERROR "nx_create_exefs: must provide a CONFIG file in json format")
	endif()

	set(NX_EXEFS_TEMP_DIR "${CMAKE_CURRENT_BINARY_DIR}/.dkp-generated/${outtarget}")
	set(NX_EXEFS_MAIN "${NX_EXEFS_TEMP_DIR}/main")
	set(NX_EXEFS_NPDM "${NX_EXEFS_TEMP_DIR}/main.npdm")

	add_custom_command(
		OUTPUT "${NX_EXEFS_MAIN}"
		COMMAND ${CMAKE_COMMAND} -E make_directory "${NX_EXEFS_TEMP_DIR}"
		COMMAND ${NX_ELF2NSO_EXE} "$<TARGET_FILE:${intarget}>" "${NX_EXEFS_MAIN}"
		DEPENDS ${intarget}
		COMMENT "Converting ${intarget} to NSO format"
		VERBATIM
	)

	add_custom_command(
		OUTPUT "${NX_EXEFS_NPDM}"
		COMMAND ${CMAKE_COMMAND} -E make_directory "${NX_EXEFS_TEMP_DIR}"
		COMMAND ${NX_NPDMTOOL_EXE} "${NX_EXEFS_CONFIG}" "${NX_EXEFS_NPDM}"
		DEPENDS "${NX_EXEFS_CONFIG}"
		COMMENT "Generating NPDM for ${outtarget}"
		VERBATIM
	)

	add_custom_command(
		OUTPUT "${NX_EXEFS_OUTPUT}"
		COMMAND ${NX_BUILD_PFS0_EXE} "${NX_EXEFS_TEMP_DIR}" "${NX_EXEFS_OUTPUT}"
		DEPENDS "${NX_EXEFS_MAIN}" "${NX_EXEFS_NPDM}"
		COMMENT "Building ExeFS target ${outtarget}"
		VERBATIM
	)

	add_custom_target(${outtarget} ALL DEPENDS "${NX_EXEFS_OUTPUT}")
	dkp_set_target_file(${outtarget} "${NX_EXEFS_OUTPUT}")
endfunction()

function(nx_create_kip target)
	cmake_parse_arguments(PARSE_ARGV 1 NX_ELF2KIP "" "TARGET;OUTPUT;CONFIG" "")

	if (NOT NX_ELF2KIP_EXE)
		message(FATAL_ERROR "Could not find elf2kip: try installing switch-tools")
	endif()

	if(DEFINED NX_ELF2KIP_TARGET)
		set(intarget "${NX_ELF2KIP_TARGET}")
		set(outtarget "${target}")
	else()
		set(intarget "${target}")
		set(outtarget "${target}_kip")
	endif()

	if(NOT TARGET "${intarget}")
		message(FATAL_ERROR "nx_create_kip: target '${intarget}' not defined")
	endif()

	if(DEFINED NX_ELF2KIP_OUTPUT)
		get_filename_component(NX_ELF2KIP_OUTPUT "${NX_ELF2KIP_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	elseif(DEFINED NX_ELF2KIP_TARGET)
		set(NX_ELF2KIP_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${outtarget}.kip")
	else()
		__dkp_target_derive_name(NX_ELF2KIP_OUTPUT ${intarget} ".kip")
	endif()

	if(DEFINED NX_ELF2KIP_CONFIG)
		get_filename_component(NX_ELF2KIP_CONFIG "${NX_ELF2KIP_CONFIG}" ABSOLUTE)
	else()
		message(FATAL_ERROR "nx_create_kip: must provide a CONFIG file in json format")
	endif()

	add_custom_command(
		OUTPUT "${NX_ELF2KIP_OUTPUT}"
		COMMAND ${NX_ELF2KIP_EXE} "$<TARGET_FILE:${intarget}>" "${NX_ELF2KIP_CONFIG}" "${NX_ELF2KIP_OUTPUT}"
		DEPENDS ${intarget} "${NX_ELF2KIP_CONFIG}"
		COMMENT "Building KIP target ${outtarget}"
		VERBATIM
	)

	add_custom_target(${outtarget} ALL DEPENDS "${NX_ELF2KIP_OUTPUT}")
	dkp_set_target_file(${outtarget} "${NX_ELF2KIP_OUTPUT}")
endfunction()

function(nx_add_shader_program target source type)
	cmake_parse_arguments(PARSE_ARGV 3 NX_UAM "" "OUTPUT" "")

	if (NOT NX_UAM_EXE)
		message(FATAL_ERROR "Could not find uam: try installing uam")
	endif()

	if(DEFINED NX_UAM_OUTPUT)
		get_filename_component(NX_UAM_OUTPUT "${NX_UAM_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	else()
		set(NX_UAM_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.dksh")
	endif()

	get_filename_component(source "${source}" ABSOLUTE)
	add_custom_command(
		OUTPUT "${NX_UAM_OUTPUT}"
		COMMAND "${NX_UAM_EXE}" -o "${NX_UAM_OUTPUT}" -s ${type} "${source}"
		DEPENDS "${source}"
		COMMENT "Building shader program ${target}"
		VERBATIM
	)

	add_custom_target(${target} DEPENDS "${NX_UAM_OUTPUT}")
	dkp_set_target_file(${target} "${NX_UAM_OUTPUT}")
endfunction()
