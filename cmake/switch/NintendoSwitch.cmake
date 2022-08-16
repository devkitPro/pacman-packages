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

function(nx_generate_nacp outfile)
	cmake_parse_arguments(PARSE_ARGV 1 NACP "" "NAME;AUTHOR;VERSION" "")
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

	add_custom_command(
		OUTPUT "${outfile}"
		COMMAND "${NX_NACPTOOL_EXE}" --create "${NACP_NAME}" "${NACP_AUTHOR}" "${NACP_VERSION}" "${outfile}"
		VERBATIM
	)
endfunction()

function(nx_create_nro target)
	cmake_parse_arguments(PARSE_ARGV 1 ELF2NRO "NOICON;NONACP" "ICON;NACP;ROMFS" "")

	get_target_property(TARGET_OUTPUT_NAME ${target} OUTPUT_NAME)
	if(NOT TARGET_OUTPUT_NAME)
		set(TARGET_OUTPUT_NAME "${target}")
	endif()

	set(ELF2NRO_ARGS "$<TARGET_FILE:${target}>" "${TARGET_OUTPUT_NAME}.nro")
	set(ELF2NRO_DEPS ${target})

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
		set(ELF2NRO_NACP "${target}.default.nacp")
		nx_generate_nacp(${ELF2NRO_NACP})
	endif()

	if (DEFINED ELF2NRO_ICON)
		list(APPEND ELF2NRO_ARGS "--icon=${ELF2NRO_ICON}")
		list(APPEND ELF2NRO_DEPS "${ELF2NRO_ICON}")
	endif()

	if (DEFINED ELF2NRO_NACP)
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
			if (NOT IS_ABSOLUTE "${ELF2NRO_ROMFS}")
				set(ELF2NRO_ROMFS "${CMAKE_CURRENT_LIST_DIR}/${ELF2NRO_ROMFS}")
			endif()
			if (NOT IS_DIRECTORY "${ELF2NRO_ROMFS}")
				message(FATAL_ERROR "nx_create_nro: cannot find romfs dir: ${ELF2NRO_ROMFS}")
			endif()
			list(APPEND ELF2NRO_ARGS "--romfsdir=${ELF2NRO_ROMFS}")
		endif()
	endif()

	add_custom_command(
		OUTPUT "${TARGET_OUTPUT_NAME}.nro"
		COMMAND "${NX_ELF2NRO_EXE}" ${ELF2NRO_ARGS}
		DEPENDS ${ELF2NRO_DEPS}
		VERBATIM
	)

	add_custom_target(
		"${target}_nro" ALL
		DEPENDS "${TARGET_OUTPUT_NAME}.nro"
	)
endfunction()

function(nx_add_shader_program target source type)
	if(NOT IS_ABSOLUTE ${source})
		set(source "${CMAKE_CURRENT_LIST_DIR}/${source}")
	endif()

	set(outfile "${CMAKE_CURRENT_BINARY_DIR}/${target}.dksh")
	add_custom_command(
		OUTPUT "${outfile}"
		COMMAND "${NX_UAM_EXE}" -o "${outfile}" -s ${type} "${source}"
		DEPENDS "${source}"
		COMMENT "Building shader program ${target}"
	)
	add_custom_target(${target} DEPENDS "${outfile}")
	dkp_set_target_file(${target} "${outfile}")
endfunction()
