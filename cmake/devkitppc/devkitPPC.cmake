include(${CMAKE_CURRENT_LIST_DIR}/dkp-initialize-path.cmake)
include(dkp-toolchain-common)

set (DKP_BIN2S_ALIGNMENT 32)

__dkp_toolchain(devkitPPC ppc powerpc-eabi)

set(DKP_INSTALL_PREFIX_INIT ${DEVKITPRO}/portlibs/ppc)
