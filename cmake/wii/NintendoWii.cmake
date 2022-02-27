# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Platform identification flags
set(NINTENDO_WII TRUE)
set(OGC_EXTRA_LIBS "-lwiiuse -lbte")

# Inherit libogc platform configuration
include(Platform/libogc)
