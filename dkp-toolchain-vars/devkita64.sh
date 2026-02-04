export DEVKITPRO=/opt/devkitpro
export PORTLIBS_ROOT=${DEVKITPRO}/portlibs
export TOOL_PREFIX=aarch64-none-elf-
export CC=${TOOL_PREFIX}gcc
export CXX=${TOOL_PREFIX}g++
export AR=${TOOL_PREFIX}gcc-ar
export RANLIB=${TOOL_PREFIX}gcc-ranlib

DKP_PATH=${DEVKITPRO}/tools/bin:${DEVKITPRO}/devkitA64/bin${DKP_PATH:+:${DKP_PATH}}
