set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR armv6k)

set(N3DS TRUE)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -specs=3dsx.specs")

set(CMAKE_FIND_ROOT_PATH /opt/devkitpro/portlibs/3ds)

include(/opt/devkitpro/devkitarm.cmake)

