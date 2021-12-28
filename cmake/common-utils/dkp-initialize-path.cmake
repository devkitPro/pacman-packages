cmake_minimum_required(VERSION 3.7)

if(NOT DEFINED ENV{DEVKITPRO})
	set(DEVKITPRO /opt/devkitpro)
else()
	set(DEVKITPRO $ENV{DEVKITPRO})
endif()

list(APPEND CMAKE_MODULE_PATH "${DEVKITPRO}/cmake")
