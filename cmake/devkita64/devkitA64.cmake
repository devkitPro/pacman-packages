include(${CMAKE_CURRENT_LIST_DIR}/dkp-initialize-path.cmake)
include(dkp-toolchain-common)

set (DKP_BIN2S_ALIGNMENT 8)

__dkp_toolchain(devkitA64 aarch64 aarch64-none-elf)
