include(/opt/devkitpro/portlibs/switch/share/devkita64.cmake)

set (DKA_SWITCH_C_FLAGS "-D__SWITCH__ -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -ftls-model=local-exec -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS   "${DKA_SWITCH_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${DKA_SWITCH_C_FLAGS}" CACHE STRING "")
set(CMAKE_ASM_FLAGS "${DKA_SWITCH_C_FLAGS}" CACHE STRING "")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-fPIE -specs=${DEVKITPRO}/libnx/switch.specs")

set(CMAKE_FIND_ROOT_PATH
	${CMAKE_FIND_ROOT_PATH}
	${DEVKITPRO}/portlibs/switch
	${DEVKITPRO}/libnx
)

# Set pkg-config for the same
find_program(PKG_CONFIG_EXECUTABLE NAMES aarch64-none-elf-pkg-config HINTS "${DEVKITPRO}/portlibs/switch/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(WARNING "Could not find aarch64-none-elf-pkg-config: try installing switch-pkg-config")
endif()

find_program(NX_ELF2NRO_EXE NAMES elf2nro HINTS "${DEVKITPRO}/tools/bin")
if (NOT NX_ELF2NRO_EXE)
	message(WARNING "Could not find elf2nro: try installing switch-tools")
endif()

find_program(NX_NACPTOOL_EXE NAMES nacptool HINTS "${DEVKITPRO}/tools/bin")
if (NOT NX_NACPTOOL_EXE)
	message(WARNING "Could not find nacptool: try installing switch-tools")
endif()

find_file(NX_DEFAULT_ICON NAMES default_icon.jpg HINTS "${DEVKITPRO}/libnx" NO_CMAKE_FIND_ROOT_PATH)
if (NOT NX_DEFAULT_ICON)
	message(WARNING "Could not find default icon: try installing libnx")
endif()

set(NINTENDO_SWITCH TRUE)

set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(NX_ROOT ${DEVKITPRO}/libnx)

set(NX_STANDARD_LIBRARIES "${NX_ROOT}/lib/libnx.a")
set(CMAKE_C_STANDARD_LIBRARIES "${NX_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_LIBRARIES "${NX_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_LIBRARIES "${NX_STANDARD_LIBRARIES}" CACHE STRING "")

#for some reason cmake (3.14.3) doesn't appreciate having \" here
set(NX_STANDARD_INCLUDE_DIRECTORIES "${NX_ROOT}/include")
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "${NX_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "${NX_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_INCLUDE_DIRECTORIES "${NX_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")

link_directories( ${DEVKITPRO}/libnx/lib ${DEVKITPRO}/portlibs/switch/lib )

function(nx_generate_nacp target)
	cmake_parse_arguments(NACP "" "NAME;AUTHOR;VERSION" "" "${ARGN}")
	if (NOT DEFINED NACP_NAME)
		set(NACP_NAME "${CMAKE_PROJECT_NAME}")
	endif()
	if (NOT DEFINED NACP_AUTHOR)
		set(NACP_AUTHOR "Unspecified Author")
	endif()
	if (NOT DEFINED NACP_VERSION)
		set(NACP_VERSION "1.0.0")
	endif()

	add_custom_command(
		OUTPUT "${target}"
		COMMAND "${NX_NACPTOOL_EXE}" --create "${NACP_NAME}" "${NACP_AUTHOR}" "${NACP_VERSION}" "${target}"
		VERBATIM
	)
endfunction()

function(nx_create_nro prefix)
	cmake_parse_arguments(ELF2NRO "NOICON;NONACP" "ICON;NACP" "" "${ARGN}")

	set(ELF2NRO_ARGS "${prefix}" "${prefix}.nro")
	set(ELF2NRO_DEPS "${prefix}")

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
		set(ELF2NRO_NACP "${prefix}.default.nacp")
		nx_generate_nacp(${ELF2NRO_NACP})
	endif()

	if (DEFINED ELF2NRO_ICON)
		set(ELF2NRO_ARGS ${ELF2NRO_ARGS} "--icon=${ELF2NRO_ICON}")
		set(ELF2NRO_DEPS ${ELF2NRO_DEPS} "${ELF2NRO_ICON}")
	endif()

	if (DEFINED ELF2NRO_NACP)
		set(ELF2NRO_ARGS ${ELF2NRO_ARGS} "--nacp=${ELF2NRO_NACP}")
		set(ELF2NRO_DEPS ${ELF2NRO_DEPS} "${ELF2NRO_NACP}")
	endif()

	add_custom_command(
		OUTPUT "${prefix}.nro"
		COMMAND "${NX_ELF2NRO_EXE}" ${ELF2NRO_ARGS}
		DEPENDS "${prefix}" ${ELF2NRO_DEPS}
		VERBATIM
	)

	add_custom_target(
		"${prefix}_nro" ALL
		DEPENDS "${prefix}.nro"
	)
endfunction()
