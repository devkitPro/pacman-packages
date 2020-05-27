include(/opt/devkitpro/devkitarm.cmake)

set (DKA_3DS_C_FLAGS "-D_3DS -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -O2 -mword-relocations -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS   "${DKA_3DS_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${DKA_3DS_C_FLAGS}" CACHE STRING "")
set(CMAKE_ASM_FLAGS "${DKA_3DS_C_FLAGS}" CACHE STRING "")

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -specs=3dsx.specs")

set(CMAKE_FIND_ROOT_PATH
  ${DEVKITPRO}/devkitARM
  ${DEVKITPRO}/tools
  ${DEVKITPRO}/portlibs/3ds
  ${DEVKITPRO}/libctru
)

# Set pkg-config for the same
find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/3ds/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
   message(WARNING "Could not find arm-none-eabi-pkg-config: try installing 3ds-pkg-config")
endif()

set(N3DS TRUE)

set(CTRU_ROOT ${DEVKITPRO}/libctru)

set(CTRU_STANDARD_LIBRARIES "${CTRU_ROOT}/lib/libctru.a")
set(CMAKE_C_STANDARD_LIBRARIES "${CTRU_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_LIBRARIES "${CTRU_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_LIBRARIES "${CTRU_STANDARD_LIBRARIES}" CACHE STRING "")

#for some reason cmake (3.14.3) doesn't appreciate having \" here
set(CTRU_STANDARD_INCLUDE_DIRECTORIES "${CTRU_ROOT}/include")
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "${CTRU_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "${CTRU_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_INCLUDE_DIRECTORIES "${CTRU_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
