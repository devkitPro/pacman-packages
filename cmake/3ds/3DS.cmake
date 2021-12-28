cmake_minimum_required(VERSION 3.7)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME Nintendo3DS)
endif()

if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR armv6k)
endif()

# Import devkitARM toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitARM.cmake)

list(APPEND CMAKE_FIND_ROOT_PATH
	${DEVKITPRO}/portlibs/3ds
	${DEVKITPRO}/libctru
)

find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/3ds/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(WARNING "Could not find arm-none-eabi-pkg-config: try installing 3ds-pkg-config")
endif()

find_program(CTR_SMDHTOOL_EXE NAMES smdhtool HINTS "${DEVKITPRO}/tools/bin")
if (NOT CTR_SMDHTOOL_EXE)
	message(WARNING "Could not find smdhtool: try installing 3ds-tools")
endif()

find_program(CTR_3DSXTOOL_EXE NAMES 3dsxtool HINTS "${DEVKITPRO}/tools/bin")
if (NOT CTR_3DSXTOOL_EXE)
	message(WARNING "Could not find 3dsxtool: try installing 3ds-tools")
endif()

find_program(CTR_PICASSO_EXE NAMES picasso HINTS "${DEVKITPRO}/tools/bin")
if (NOT CTR_PICASSO_EXE)
	message(WARNING "Could not find picasso: try installing picasso")
endif()

find_file(CTR_DEFAULT_ICON NAMES default_icon.png HINTS "${DEVKITPRO}/libctru" NO_CMAKE_FIND_ROOT_PATH)
if (NOT CTR_DEFAULT_ICON)
	message(WARNING "Could not find default icon: try installing libctru")
endif()
