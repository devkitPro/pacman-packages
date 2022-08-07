cmake_minimum_required(VERSION 3.13)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME CafeOS)
endif()

# Import devkitPPC toolchain
include(${CMAKE_CURRENT_LIST_DIR}/devkitPPC.cmake)

set(WUT_ROOT ${DEVKITPRO}/wut)

__dkp_platform_prefix(
	${DEVKITPRO}/portlibs/wiiu
	${DEVKITPRO}/portlibs/ppc
	${WUT_ROOT}
)

find_program(PKG_CONFIG_EXECUTABLE NAMES powerpc-eabi-pkg-config HINTS "${DEVKITPRO}/portlibs/wiiu/bin")
if (NOT PKG_CONFIG_EXECUTABLE)
	message(FATAL_ERROR "Could not find powerpc-eabi-pkg-config: try installing wiiu-pkg-config")
endif()

find_program(WUT_ELF2RPL_EXE NAMES elf2rpl HINTS "${DEVKITPRO}/tools/bin")
if (NOT WUT_ELF2RPL_EXE)
	message(FATAL_ERROR "Could not find elf2rpl: try installing wut-tools")
endif()

find_program(WUT_WUHBTOOL_EXE NAMES wuhbtool HINTS "${DEVKITPRO}/tools/bin")
if (NOT WUT_WUHBTOOL_EXE)
	message(FATAL_ERROR "Could not find wuhbtool: try installing wut-tools")
endif()

find_program(WUT_RPLEXPORTGEN_EXE NAMES rplexportgen HINTS "${DEVKITPRO}/tools/bin")
if (NOT WUT_RPLEXPORTGEN_EXE)
	message(FATAL_ERROR "Could not find rplexportgen: try installing wut-tools")
endif()

find_program(WUT_RPLIMPORTGEN_EXE NAMES rplimportgen HINTS "${DEVKITPRO}/tools/bin")
if (NOT WUT_RPLIMPORTGEN_EXE)
	message(FATAL_ERROR "Could not find rplimportgen: try installing wut-tools")
endif()
