set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(SWITCH_LIBNX TRUE)

set(CMAKE_EXE_LINKER_FLAGS_INIT "-march=armv8-a -mtune=cortex-a57 -mtp=soft -fPIE -ftls-model=local-exec -L/opt/devkitpro/portlibs/switch/lib -L/opt/devkitpro/libnx/lib -specs=/opt/devkitpro/libnx/switch.specs")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT}")

set(CMAKE_FIND_ROOT_PATH /opt/devkitpro/portlibs/switch/)
set(CMAKE_PREFIX_PATH "/opt/devkitpro/portlibs/switch/")

include(/opt/devkitpro/devkita64.cmake)

