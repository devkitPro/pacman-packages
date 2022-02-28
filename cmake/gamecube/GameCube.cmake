cmake_minimum_required(VERSION 3.13)

if(NOT CMAKE_SYSTEM_NAME)
	set(CMAKE_SYSTEM_NAME NintendoGameCube)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/ogc-common.cmake)
