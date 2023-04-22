include(${CMAKE_CURRENT_LIST_DIR}/dkp-initialize-path.cmake)
include(dkp-toolchain-common)

set (DKP_BIN2S_ALIGNMENT 4)

__dkp_toolchain(devkitARM arm arm-none-eabi)
