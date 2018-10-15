set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(SWITCH_LIBNX TRUE)

set(CMAKE_EXE_LINKER_FLAGS_INIT "-march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIE -ftls-model=local-exec -L$PORTLIBS_PREFIX/lib -L$DEVKITPRO/libnx/lib -specs=$DEVKITPRO/libnx/switch.specs")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT}")

SET(CMAKE_FIND_ROOT_PATH "${DEVKITPRO}/portlibs/switch")
set(CMAKE_PREFIX_PATH "${DEVKITPRO}/portlibs/switch/")

include(devkita64.cmake)

