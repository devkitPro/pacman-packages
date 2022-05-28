# -----------------------------------------------------------------------------
# Generic configuration for devkitPro platforms

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Use .elf extension for compiled binaries
set(CMAKE_EXECUTABLE_SUFFIX .elf)

# Prevent standard build configurations from loading unwanted "default" flags
if(DKP_NO_BUILTIN_CMAKE_CONFIGS)
	set(CMAKE_NOT_USING_CONFIG_FLAGS TRUE)
endif()

# Disable shared library support
set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available")
set_property(GLOBAL PROPERTY TARGET_SUPPORTS_SHARED_LIBS FALSE)

# Helper macro for platform settings initialization
macro(__dkp_init_platform_settings platform)
	foreach(lang C CXX ASM)
		set(CMAKE_${lang}_FLAGS_INIT "${${platform}_ARCH_SETTINGS} ${${platform}_COMMON_FLAGS}")

		if(NOT DKP_PLATFORM_BOOTSTRAP)
			set(CMAKE_${lang}_STANDARD_LIBRARIES "${${platform}_STANDARD_LIBRARIES}" CACHE STRING "" FORCE)
			set(CMAKE_${lang}_STANDARD_INCLUDE_DIRECTORIES "${${platform}_STANDARD_INCLUDE_DIRECTORIES}" CACHE STRING "")
		endif()
	endforeach()

	if(NOT DKP_PLATFORM_BOOTSTRAP)
		set(CMAKE_EXE_LINKER_FLAGS_INIT "${${platform}_ARCH_SETTINGS} ${${platform}_LINKER_FLAGS}")
	else()
		set(CMAKE_EXE_LINKER_FLAGS_INIT "${${platform}_ARCH_SETTINGS}")
		set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
	endif()
endmacro()

# -----------------------------------------------------------------------------
# Helper utilities

# Include common devkitPro bits and pieces
include(dkp-linker-utils)
include(dkp-custom-target)
include(dkp-embedded-binary)
include(dkp-asset-folder)
