cmake_minimum_required(VERSION 3.7)
include(${CMAKE_CURRENT_LIST_DIR}/dkp-initialize-path.cmake)
include(dkp-toolchain-common)

__dkp_toolchain(devkitPPC ppc powerpc-eabi)
