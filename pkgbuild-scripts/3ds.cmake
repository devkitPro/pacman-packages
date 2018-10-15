set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR armv6k)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -specs=3dsx.specs")

SET(CMAKE_FIND_ROOT_PATH "${DEVKITPRO}/portlibs/3ds")

include(devkitarm.cmake)

