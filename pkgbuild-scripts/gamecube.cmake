set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR powerpc)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -mogc")

set(CMAKE_FIND_ROOT_PATH /opt/devkitpro/portlibs/gamecube /opt/devkitpro/portlibs/ppc)

set(GAMECUBE TRUE)

include(/opt/devkitpro/devkitppc.cmake)

