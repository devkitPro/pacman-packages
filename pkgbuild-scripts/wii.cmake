set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR powerpc)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -mrvl")

set(CMAKE_FIND_ROOT_PATH /opt/devkitpro/portlibs/wii /opt/devkitpro/portlibs/ppc)

set(WII TRUE)

include(/opt/devkitpro/devkitppc.cmake)

