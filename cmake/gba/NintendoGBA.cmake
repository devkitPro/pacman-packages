# -----------------------------------------------------------------------------
# Platform configuration

cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

# Inherit default devkitPro platform configuration
include(Platform/Generic-dkP)

# Platform identification flags
set(NINTENDO_GBA TRUE)

# Platform settings
set(GBA_STANDARD_INCLUDE_DIRECTORIES "${GBA_ROOT}/include")
set(GBA_ARCH_SETTINGS "-march=armv4t -mtune=arm7tdmi -mthumb -mthumb-interwork")
set(GBA_COMMON_FLAGS  "-ffunction-sections -fdata-sections -D__GBA__ -DARM7")
set(GBA_LINKER_FLAGS  "-L${GBA_ROOT}/lib -L${DEVKITPRO}/portlibs/gba/lib -L${DEVKITPRO}/portlibs/armv4t/lib")

set(GBA_LINKER_FLAGS_CART "-specs=gba.specs")
set(GBA_LINKER_FLAGS_MB   "-specs=gba_mb.specs")

if("${DKP_GBA_PLATFORM_LIBRARY}" STREQUAL "libgba")
	set(GBA_STANDARD_LIBRARIES "-lgba")
elseif("${DKP_GBA_PLATFORM_LIBRARY}" STREQUAL "libtonc")
	set(GBA_STANDARD_LIBRARIES "-ltonc")
else()
	message(FATAL_ERROR "Unsupported GBA platform library: '${DKP_GBA_PLATFORM_LIBRARY}'")
endif()

__dkp_init_platform_settings(GBA)

# -----------------------------------------------------------------------------
# Platform-specific helper utilities

function(gba_create_rom target)
	cmake_parse_arguments(PARSE_ARGV 1 GBA "MULTIBOOT;PAD" "OUTPUT;TITLE;GAMECODE;MAKERCODE;VERSION;DEBUG" "")

	if(NOT TARGET "${target}")
		message(FATAL_ERROR "gba_create_rom: target '${target}' not defined")
	endif()

	if(GBA_MULTIBOOT)
		target_link_options(${target} PRIVATE "${GBA_LINKER_FLAGS_MB}")
	else()
		target_link_options(${target} PRIVATE "${GBA_LINKER_FLAGS_CART}")
	endif()

	if(DEFINED GBA_OUTPUT)
		get_filename_component(GBA_OUTPUT "${GBA_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	else()
		__dkp_target_derive_name(GBA_OUTPUT ${target} ".gba")
	endif()

	set(GBA_ARGS "")

	if(GBA_PAD)
		list(APPEND GBA_ARGS "-p")
	endif()

	if(DEFINED GBA_TITLE)
		list(APPEND GBA_ARGS "-t${GBA_TITLE}")
	endif()

	if(DEFINED GBA_GAMECODE)
		list(APPEND GBA_ARGS "-c${GBA_GAMECODE}")
	endif()

	if(DEFINED GBA_MAKERCODE)
		list(APPEND GBA_ARGS "-m${GBA_MAKERCODE}")
	endif()

	if(DEFINED GBA_VERSION)
		list(APPEND GBA_ARGS "-v${GBA_VERSION}")
	endif()

	if(DEFINED GBA_DEBUG)
		list(APPEND GBA_ARGS "-d${GBA_DEBUG}")
	endif()

	add_custom_command(TARGET ${target} POST_BUILD
		COMMAND "${CMAKE_OBJCOPY}" -O binary "$<TARGET_FILE:${target}>" "${GBA_OUTPUT}"
		COMMAND "${GBA_GBAFIX_EXE}" "${GBA_OUTPUT}" ${GBA_ARGS}
		BYPRODUCTS "${GBA_OUTPUT}"
		COMMENT "Building GBA ROM for ${target}"
		VERBATIM
	)

	dkp_set_target_file(${target} "${GBA_OUTPUT}")
endfunction()

include(dkp-gba-ds-utils)
