cmake_minimum_required(VERSION 3.13)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME NintendoDS)
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR armv5te)
endif()

# Import devkitARM toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitARM.cmake)

list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES NDS_ARCH_THUMB)

set(CALICO_ROOT "${DEVKITPRO}/calico")
set(NDS_ROOT    "${DEVKITPRO}/libnds")

set(DKP_INSTALL_PREFIX_INIT ${DEVKITPRO}/portlibs/nds)

__dkp_platform_prefix(
	${DEVKITPRO}/portlibs/nds
	${DEVKITPRO}/portlibs/${CMAKE_SYSTEM_PROCESSOR}
	${DEVKITPRO}/portlibs/armv4t
	${NDS_ROOT}
	${CALICO_ROOT}
)

find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/nds/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(FATAL_ERROR "Could not find arm-none-eabi-pkg-config: try installing nds-pkg-config")
endif()

find_program(NDS_NDSTOOL_EXE NAMES ndstool HINTS "${DEVKITPRO}/tools/bin")

find_file(NDS_DEFAULT_ICON NAMES nds-icon.bmp HINTS "${CALICO_ROOT}/share" NO_CMAKE_FIND_ROOT_PATH)

include(dkp-gba-ds-common)
