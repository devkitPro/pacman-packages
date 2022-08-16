# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform settings
set(OGC_ARCH_SETTINGS "-m${OGC_MACHINE} -DGEKKO -mcpu=750 -meabi -mhard-float")
set(OGC_COMMON_FLAGS  "-ffunction-sections")
set(OGC_LINKER_FLAGS  "-L${OGC_ROOT}/lib/${OGC_SUBDIR} -L${DEVKITPRO}/portlibs/${OGC_CONSOLE}/lib -L${DEVKITPRO}/portlibs/ppc/lib")
set(OGC_STANDARD_LIBRARIES "${OGC_EXTRA_LIBS} -logc -lm")
set(OGC_STANDARD_INCLUDE_DIRECTORIES "${OGC_ROOT}/include")

__dkp_init_platform_settings(OGC)

function(ogc_create_dol target)

    get_target_property(TARGET_OUTPUT_NAME ${target} OUTPUT_NAME)
    get_target_property(TARGET_BINARY_DIR  ${target} BINARY_DIR)

    if(NOT TARGET_OUTPUT_NAME)
        set(TARGET_OUTPUT_NAME "${target}")
    endif()

    set(DOL_OUTPUT "${TARGET_BINARY_DIR}/${TARGET_OUTPUT_NAME}.dol")

    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND "${ELF2DOL_EXE}" "$<TARGET_FILE:${target}>" "${DOL_OUTPUT}"
        BYPRODUCTS "${DOL_OUTPUT}"
        COMMENT "Converting ${target} to .dol format"
        VERBATIM
    )

endfunction()
