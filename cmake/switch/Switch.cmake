cmake_minimum_required(VERSION 3.7)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME NintendoSwitch)
endif()

# Import devkitA64 toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitA64.cmake)

list(APPEND CMAKE_FIND_ROOT_PATH
	${DEVKITPRO}/portlibs/switch
	${DEVKITPRO}/libnx
)

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

find_program(NX_UAM_EXE NAMES uam HINTS "${DEVKITPRO}/tools/bin")
if (NOT NX_UAM_EXE)
	message(WARNING "Could not find uam: try installing uam")
endif()

find_file(NX_DEFAULT_ICON NAMES default_icon.jpg HINTS "${DEVKITPRO}/libnx" NO_CMAKE_FIND_ROOT_PATH)
if (NOT NX_DEFAULT_ICON)
	message(WARNING "Could not find default icon: try installing libnx")
endif()
