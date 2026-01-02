# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform settings
set(OGC_ARCH_SETTINGS "-m${OGC_MACHINE} -mcpu=750 -meabi -mhard-float")
set(OGC_COMMON_FLAGS  "-ffunction-sections -fdata-sections -D__${OGC_CONSOLE}__ -DGEKKO")
set(OGC_LINKER_FLAGS  "-L${OGC_ROOT}/lib/${OGC_SUBDIR} -L${DEVKITPRO}/portlibs/${OGC_CONSOLE}/lib -L${DEVKITPRO}/portlibs/ppc/lib")
set(OGC_STANDARD_LIBRARIES "${OGC_EXTRA_LIBS} -logc -lm")
set(OGC_STANDARD_INCLUDE_DIRECTORIES "${OGC_ROOT}/include")

__dkp_init_platform_settings(OGC)

set(CMAKE_ASM_FLAGS_INIT "${CMAKE_ASM_FLAGS_INIT} -mregnames")

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

function(ogc_create_dol target)
    if (NOT ELF2DOL_EXE)
        message(FATAL_ERROR "Could not find elf2dol: try installing gamecube-tools")
    endif()

    __dkp_target_derive_name(DOL_OUTPUT ${target} ".dol")
    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND "${ELF2DOL_EXE}" "$<TARGET_FILE:${target}>" "${DOL_OUTPUT}"
        BYPRODUCTS "${DOL_OUTPUT}"
        COMMENT "Converting ${target} to .dol format"
        VERBATIM
    )
    dkp_set_target_file(${target} "${DOL_OUTPUT}")
endfunction()

function(ogc_add_dsp_binary target infile)
    if (NOT GCDSPTOOL_EXE)
        message(FATAL_ERROR "Could not find gcdsptool: try installing gamecube-tools")
    endif()

    cmake_parse_arguments(PARSE_ARGV 1 DSP "" "OUTPUT" "")

    if(DEFINED DSP_OUTPUT)
        get_filename_component(DSP_OUTPUT "${DSP_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    else()
        set(DSP_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.bin")
    endif()

    add_custom_command(
        OUTPUT ${DSP_OUTPUT}
        COMMAND "${GCDSPTOOL_EXE}" -c ${infile} -o ${DSP_OUTPUT}
        DEPENDS ${infile}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Building DSP binary ${target}"
        VERBATIM
    )

    add_custom_target(${target} DEPENDS "${DSP_OUTPUT}")
    dkp_set_target_file(${target} "${DSP_OUTPUT}")
endfunction()
