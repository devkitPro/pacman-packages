include(${CMAKE_CURRENT_LIST_DIR}/dkp-initialize-path.cmake)
include(dkp-toolchain-common)

__dkp_toolchain(devkitPPC ppc powerpc-eabi)

set(DKP_INSTALL_PREFIX_INIT ${DEVKITPRO}/portlibs/ppc)
