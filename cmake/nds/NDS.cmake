cmake_minimum_required(VERSION 3.13)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME NintendoDS)
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR armv5te)
endif()

# Import devkitARM toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitARM.cmake)

set(NDS_ROOT ${DEVKITPRO}/libnds)

__dkp_platform_prefix(
	${DEVKITPRO}/portlibs/nds
	${NDS_ROOT}
)

find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/nds/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(WARNING "Could not find arm-none-eabi-pkg-config: try installing nds-pkg-config")
endif()

find_program(NDS_NDSTOOL_EXE NAMES ndstool HINTS "${DEVKITPRO}/tools/bin")
if (NOT NDS_NDSTOOL_EXE)
	message(WARNING "Could not find ndstool: try installing ndstool")
endif()

find_file(NDS_DEFAULT_ICON NAMES icon.bmp HINTS "${DEVKITPRO}/libnds" NO_CMAKE_FIND_ROOT_PATH)
if (NOT NDS_DEFAULT_ICON)
	message(WARNING "Could not find default icon: try installing libnds")
endif()
