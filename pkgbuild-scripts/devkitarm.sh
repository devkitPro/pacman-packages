#!/usr/bin/env bash
export DEVKITPRO=/opt/devkitpro
export DEVKITARM=${DEVKITPRO}/devkitARM
export PORTLIBS_ROOT=${DEVKITPRO}/portlibs
export PATH=$DEVKITARM/bin:$PATH
export TOOL_PREFIX=arm-none-eabi-
export AR=${TOOL_PREFIX}gcc-ar
export RANLIB=${TOOL_PREFIX}gcc-ranlib
