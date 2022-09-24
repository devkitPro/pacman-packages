cmake_minimum_required(VERSION 3.13)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME NintendoGBA)
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR armv4t)
endif()

if(NOT DKP_GBA_PLATFORM_LIBRARY)
	set(DKP_GBA_PLATFORM_LIBRARY libgba)
endif()

# Import devkitARM toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitARM.cmake)

list(APPEND CMAKE_TRY_COMPILE_PLATFORM_VARIABLES DKP_GBA_PLATFORM_LIBRARY)

if("${DKP_GBA_PLATFORM_LIBRARY}" STREQUAL "libgba")
	set(GBA_ROOT "${DEVKITPRO}/libgba")
elseif("${DKP_GBA_PLATFORM_LIBRARY}" STREQUAL "libtonc")
	set(GBA_ROOT "${DEVKITPRO}/libtonc")
else()
	message(FATAL_ERROR "Unsupported GBA platform library: '${DKP_GBA_PLATFORM_LIBRARY}'")
endif()

set(DKP_INSTALL_PREFIX_INIT ${DEVKITPRO}/portlibs/gba)

__dkp_platform_prefix(
	${DEVKITPRO}/portlibs/gba
	${DEVKITPRO}/portlibs/armv4t
	${GBA_ROOT}
)

find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/gba/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(WARNING "Could not find arm-none-eabi-pkg-config: try installing gba-pkg-config")
endif()

find_program(GBA_GBAFIX_EXE NAMES gbafix HINTS "${DEVKITPRO}/tools/bin")
if (NOT GBA_GBAFIX_EXE)
	message(WARNING "Could not find gbafix: try installing gba-tools")
endif()

include(dkp-gba-ds-common)
