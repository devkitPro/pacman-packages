cmake_minimum_required(VERSION 3.7)

macro(__dkp_toolchain name arch triplet)
	set(${name} TRUE)

	if(NOT CMAKE_SYSTEM_NAME)
		# Set default platform name if none was supplied.
		# This default is appropriate for generic bare metal platforms.
		# On CMake 3.23+, we can request the variant that uses the .elf extension for executables.
		if(${CMAKE_VERSION} GREATER_EQUAL "3.23")
			set(CMAKE_SYSTEM_NAME Generic-ELF)
		else()
			set(CMAKE_SYSTEM_NAME Generic)
		endif()
	endif()

	if(NOT CMAKE_SYSTEM_VERSION)
		# Usually, this setting is unused in "non-standard" platforms.
		set(CMAKE_SYSTEM_VERSION 1)
	endif()

	if(NOT CMAKE_SYSTEM_PROCESSOR)
		# Set the correct processor name if no refinement was supplied.
		set(CMAKE_SYSTEM_PROCESSOR ${arch})
	endif()

	if(NOT CMAKE_USER_MAKE_RULES_OVERRIDE)
		# Load platform information overrides
		set(CMAKE_USER_MAKE_RULES_OVERRIDE ${CMAKE_CURRENT_LIST_DIR}/dkp-rule-overrides.cmake)
	endif()

	# Prevent standard build configurations from loading default flags
	set(CMAKE_NOT_USING_CONFIG_FLAGS TRUE)

	set(TOOL_PREFIX ${DEVKITPRO}/${name}/bin/${triplet}-)

	set(CMAKE_ASM_COMPILER ${TOOL_PREFIX}gcc        CACHE PATH "")
	set(CMAKE_C_COMPILER   ${TOOL_PREFIX}gcc        CACHE PATH "")
	set(CMAKE_CXX_COMPILER ${TOOL_PREFIX}g++        CACHE PATH "")
	set(CMAKE_LINKER       ${TOOL_PREFIX}ld         CACHE PATH "")
	set(CMAKE_AR           ${TOOL_PREFIX}gcc-ar     CACHE PATH "")
	set(CMAKE_RANLIB       ${TOOL_PREFIX}gcc-ranlib CACHE PATH "")
	set(CMAKE_STRIP        ${TOOL_PREFIX}strip      CACHE PATH "")
	set(DKP_OBJCOPY        ${TOOL_PREFIX}objcopy    CACHE PATH "")
	set(DKP_NM             ${TOOL_PREFIX}nm         CACHE PATH "")

	set(CMAKE_LIBRARY_ARCHITECTURE ${triplet} CACHE INTERNAL "abi")

	set(CMAKE_FIND_ROOT_PATH
		${DEVKITPRO}/${name}
		${DEVKITPRO}/${name}/${triplet}
		${DEVKITPRO}/tools
	)

	set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
	set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
	set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
	set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

	set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "Shared libs not available")

	find_program(DKP_BIN2S NAMES bin2s HINTS "${DEVKITPRO}/tools/bin")
	if (NOT DKP_BIN2S)
		message(WARNING "Could not find bin2s: try installing general-tools")
	endif()
endmacro()
