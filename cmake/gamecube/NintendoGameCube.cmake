# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Platform identification flags
set(NINTENDO_GAMECUBE TRUE)

# Inherit libogc platform configuration
include(Platform/libogc)
