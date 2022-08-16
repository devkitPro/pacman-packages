cmake_minimum_required(VERSION 3.13)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME NintendoSwitch)
endif()

# Import devkitA64 toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitA64.cmake)

set(NX_ROOT ${DEVKITPRO}/libnx)
set(DKP_INSTALL_PREFIX_INIT ${DEVKITPRO}/portlibs/switch)

__dkp_platform_prefix(
	${DEVKITPRO}/portlibs/switch
	${NX_ROOT}
)

find_program(PKG_CONFIG_EXECUTABLE NAMES aarch64-none-elf-pkg-config HINTS "${DEVKITPRO}/portlibs/switch/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(FATAL_ERROR "Could not find aarch64-none-elf-pkg-config: try installing switch-pkg-config")
endif()

find_program(NX_ELF2NRO_EXE NAMES elf2nro HINTS "${DEVKITPRO}/tools/bin")
if (NOT NX_ELF2NRO_EXE)
	message(FATAL_ERROR "Could not find elf2nro: try installing switch-tools")
endif()

find_program(NX_NACPTOOL_EXE NAMES nacptool HINTS "${DEVKITPRO}/tools/bin")
if (NOT NX_NACPTOOL_EXE)
	message(FATAL_ERROR "Could not find nacptool: try installing switch-tools")
endif()

find_program(NX_UAM_EXE NAMES uam HINTS "${DEVKITPRO}/tools/bin")
if (NOT NX_UAM_EXE)
	message(FATAL_ERROR "Could not find uam: try installing uam")
endif()

find_file(NX_DEFAULT_ICON NAMES default_icon.jpg HINTS "${NX_ROOT}" NO_CMAKE_FIND_ROOT_PATH)
if (NOT NX_DEFAULT_ICON)
	message(FATAL_ERROR "Could not find default icon: try installing libnx")
endif()
