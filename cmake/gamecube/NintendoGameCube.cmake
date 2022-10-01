# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Platform identification flags
set(NINTENDO_GAMECUBE CACHE BOOL TRUE)

# Inherit libogc platform configuration
include(Platform/libogc)
