cmake_minimum_required(VERSION 3.13)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME Nintendo3DS)
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR armv6k)
endif()

# Import devkitARM toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitARM.cmake)

set(CTR_ROOT ${DEVKITPRO}/libctru)
set(DKP_INSTALL_PREFIX_INIT ${DEVKITPRO}/portlibs/3ds)

__dkp_platform_prefix(
	${DEVKITPRO}/portlibs/3ds
	${CTR_ROOT}
)

find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/3ds/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(FATAL_ERROR "Could not find arm-none-eabi-pkg-config: try installing 3ds-pkg-config")
endif()

find_program(CTR_SMDHTOOL_EXE NAMES smdhtool HINTS "${DEVKITPRO}/tools/bin")
find_program(CTR_3DSXTOOL_EXE NAMES 3dsxtool HINTS "${DEVKITPRO}/tools/bin")
find_program(CTR_PICASSO_EXE NAMES picasso HINTS "${DEVKITPRO}/tools/bin")
find_program(CTR_TEX3DS_EXE NAMES tex3ds HINTS "${DEVKITPRO}/tools/bin")

find_file(CTR_DEFAULT_ICON NAMES default_icon.png HINTS "${CTR_ROOT}" NO_CMAKE_FIND_ROOT_PATH)
