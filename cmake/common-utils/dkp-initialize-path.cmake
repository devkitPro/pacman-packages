cmake_minimum_required(VERSION 3.13)

if(NOT DEFINED ENV{DEVKITPRO})
	set(DEVKITPRO /opt/devkitpro)
else()
	file(TO_CMAKE_PATH $ENV{DEVKITPRO} DEVKITPRO)
endif()

list(APPEND CMAKE_MODULE_PATH "${DEVKITPRO}/cmake")
