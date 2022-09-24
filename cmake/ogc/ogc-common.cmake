cmake_minimum_required(VERSION 3.13)

if("${CMAKE_SYSTEM_NAME}" STREQUAL "NintendoWii")
    set(OGC_CONSOLE wii)
    set(OGC_SUBDIR wii)
    set(OGC_MACHINE rvl)
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "NintendoGameCube")
    set(OGC_CONSOLE gamecube)
    set(OGC_SUBDIR cube)
    set(OGC_MACHINE ogc)
else()
    message(FATAL_ERROR "Unsupported libogc platform")
endif()

# Import devkitPPC toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitPPC.cmake)

set(OGC_ROOT ${DEVKITPRO}/libogc)
set(DKP_INSTALL_PREFIX_INIT ${DEVKITPRO}/portlibs/${OGC_CONSOLE})

__dkp_platform_prefix(
    ${DEVKITPRO}/portlibs/${OGC_CONSOLE}
    ${DEVKITPRO}/portlibs/ppc
    ${OGC_ROOT}
)

find_program(PKG_CONFIG_EXECUTABLE NAMES powerpc-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/${OGC_CONSOLE}/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
    message(FATAL_ERROR "Could not find powerpc-eabi-pkg-config: try installing ${OGC_CONSOLE}-pkg-config")
endif()

find_program(ELF2DOL_EXE NAMES elf2dol HINTS "${DEVKITPRO}/tools/bin")
if (NOT ELF2DOL_EXE)
    message(FATAL_ERROR "Could not find elf2dol: try installing gamecube-tools")
endif()

find_program(GCDSPTOOL_EXE NAMES gcdsptool HINTS "${DEVKITPRO}/tools/bin")
if (NOT GCDSPTOOL_EXE)
    message(FATAL_ERROR "Could not find gcdsptool: try installing gamecube-tools")
endif()

find_program(GXTEXCONV_EXE NAMES gxtexconv HINTS "${DEVKITPRO}/tools/bin")
if (NOT GXTEXCONV_EXE)
    message(FATAL_ERROR "Could not find gxtexconv: try installing gamecube-tools")
endif()