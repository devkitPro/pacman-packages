cmake_minimum_required(VERSION 3.13)

macro(__dkp_toolchain name arch triplet)
	set(${name} TRUE)

	if(NOT CMAKE_SYSTEM_NAME)
		# Set default platform if none was supplied.
		set(CMAKE_SYSTEM_NAME Generic-dkP)
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

	# [CMake 3.15+] Start find_package in config mode
	set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

	if(CMAKE_VERSION VERSION_GREATER_EQUAL 3.16)
		set(DKP_PREFIX_VAR CMAKE_SYSTEM_PREFIX_PATH)
		set(CMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH OFF)
		string(REPLACE ":" ";" CMAKE_SYSTEM_PROGRAM_PATH "$ENV{PATH}")
	else()
		set(DKP_PREFIX_VAR CMAKE_FIND_ROOT_PATH)
		set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
		set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
		set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
		set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
		set(CMAKE_SYSTEM_INCLUDE_PATH /include)
		set(CMAKE_SYSTEM_LIBRARY_PATH /lib)
		set(CMAKE_SYSTEM_PROGRAM_PATH /bin)
	endif()

	set(${DKP_PREFIX_VAR}
		${DEVKITPRO}/${name}
		${DEVKITPRO}/${name}/${triplet}
		${DEVKITPRO}/tools
	)

	find_program(DKP_BIN2S NAMES bin2s HINTS "${DEVKITPRO}/tools/bin")
	if (NOT DKP_BIN2S)
		message(WARNING "Could not find bin2s: try installing general-tools")
	endif()
endmacro()

macro(__dkp_platform_prefix)
	list(INSERT ${DKP_PREFIX_VAR} 0 ${ARGN})
endmacro()
