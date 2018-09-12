set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(SWITCH_LIBNX TRUE)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIE -specs=/opt/devkitpro/libnx/switch.specs")

SET(CMAKE_FIND_ROOT_PATH /opt/devkitpro/portlibs/switch)

include(devkita64.cmake)

