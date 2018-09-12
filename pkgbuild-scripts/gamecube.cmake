set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR powerpc)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -mogc")

SET(CMAKE_FIND_ROOT_PATH /opt/devkitpro/portlibs/gamecube /opt/devkitpro/portlibs/ppc)

include(devkitppc.cmake)

