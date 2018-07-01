#!/usr/bin/env bash
export DEVKITPRO=/opt/devkitpro
export DEVKITPPC=${DEVKITPRO}/devkitPPC
export PORTLIBS_ROOT=${DEVKITPRO}/portlibs
export PATH=${DEVKITPRO}/tools/bin:${DEVKITPRO}/devkitPPC/bin:$PATH
export TOOL_PREFIX=powerpc-eabi-
export AR=${TOOL_PREFIX}gcc-ar
export RANLIB=${TOOL_PREFIX}gcc-ranlib
