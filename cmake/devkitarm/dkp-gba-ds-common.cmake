cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

if(NOT DKP_NO_ARM_MODE_WRAPPER AND NOT CTEST_USE_LAUNCHERS)
	# Use this "internal" (but documented) global property instead of CMAKE_<LANG>_COMPILER_LAUNCHER
	# in order to allow users to specify their own compiler wrapper tools.
	set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CMAKE_CURRENT_LIST_DIR}/dkp-arm-mode-wrapper")
endif()

find_program(GRIT_EXE NAMES grit HINTS "${DEVKITPRO}/tools/bin")
if (NOT GRIT_EXE)
	message(WARNING "Could not find grit: try installing grit")
endif()

find_program(MMUTIL_EXE NAMES mmutil HINTS "${DEVKITPRO}/tools/bin")
if (NOT MMUTIL_EXE)
	message(WARNING "Could not find mmutil: try installing mmutil")
endif()
