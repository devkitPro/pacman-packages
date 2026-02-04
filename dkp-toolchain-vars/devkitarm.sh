export DEVKITPRO=/opt/devkitpro
export DEVKITARM=${DEVKITPRO}/devkitARM
export PORTLIBS_ROOT=${DEVKITPRO}/portlibs
export TOOL_PREFIX=arm-none-eabi-
export CC=${TOOL_PREFIX}gcc
export CXX=${TOOL_PREFIX}g++
export AR=${TOOL_PREFIX}gcc-ar
export RANLIB=${TOOL_PREFIX}gcc-ranlib

DKP_PATH=${DEVKITPRO}/tools/bin:${DEVKITARM}/bin${DKP_PATH:+:${DKP_PATH}}
