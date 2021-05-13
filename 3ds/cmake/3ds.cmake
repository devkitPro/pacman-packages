include(/opt/devkitpro/devkitARM/share/devkitarm.cmake)

set (DKA_3DS_C_FLAGS "-D__3DS__ -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft -mword-relocations -ffunction-sections -fdata-sections")
set(CMAKE_C_FLAGS   "${DKA_3DS_C_FLAGS}" CACHE STRING "")
set(CMAKE_CXX_FLAGS "${DKA_3DS_C_FLAGS}" CACHE STRING "")
set(CMAKE_ASM_FLAGS "${DKA_3DS_C_FLAGS}" CACHE STRING "")

set(CMAKE_EXE_LINKER_FLAGS_INIT "-march=armv6k -mtune=mpcore -specs=3ds.specs")

set(CMAKE_FIND_ROOT_PATH
  ${DEVKITPRO}/devkitARM
  ${DEVKITPRO}/tools
  ${DEVKITPRO}/portlibs/3ds
  ${DEVKITPRO}/libctru
)

# Set pkg-config for the same
find_program(PKG_CONFIG_EXECUTABLE NAMES arm-none-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/3ds/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
   message(WARNING "Could not find arm-none-eabi-pkg-config: try installing switch-pkg-config")
endif()

set(NINTENDO_3DS TRUE)


set(CTR_ROOT ${DEVKITPRO}/libctru)

set(CTR_STANDARD_LIBRARIES "-lctru -lm")
set(CMAKE_C_STANDARD_LIBRARIES "${CTR_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_LIBRARIES "${CTR_STANDARD_LIBRARIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_LIBRARIES "${CTR_STANDARD_LIBRARIES}" CACHE STRING "")

#for some reason cmake (3.14.3) doesn't appreciate having \" here
set(CTR_STANDARD_INCLUDE_DIRECTORIES "${CTR_ROOT}/include")
set(CMAKE_C_STANDARD_INCLUDE_DIRECTORIES "${CTR_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES "${CTR_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
set(CMAKE_ASM_STANDARD_INCLUDE_DIRECTORIES "${CTR_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")

link_directories( ${DEVKITPRO}/libctru/lib ${DEVKITPRO}/portlibs/3ds/lib )
