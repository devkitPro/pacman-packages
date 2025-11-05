cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

include(dkp-impl-helpers)

macro(__grit_parse_options_common)
	set(GRIT_ARGS -g)
	set(GRIT_DEPS "")
	set(GRIT_RENAME_CMDS "")

	if (NOT GRIT_EXE)
		message(FATAL_ERROR "Could not find grit: try installing grit")
	endif()

	if(GRIT_TEXTURE)
		set(GRIT_BITMAP TRUE)
		list(APPEND GRIT_ARGS -gb -gx)
	elseif(GRIT_BITMAP)
		list(APPEND GRIT_ARGS -gb)
	else()
		list(APPEND GRIT_ARGS -gt)
	endif()

	if(NOT DEFINED GRIT_DEPTH)
		if(GRIT_BITMAP)
			set(GRIT_DEPTH 8)
		else()
			set(GRIT_DEPTH 4)
		endif()
	endif()
	list(APPEND GRIT_ARGS -gB${GRIT_DEPTH})

	if(NOT GRIT_BITMAP AND NOT GRIT_NO_MAP)
		list(APPEND GRIT_ARGS -m)
	else()
		set(GRIT_NO_MAP TRUE)
		list(APPEND GRIT_ARGS -m!)
	endif()

	# TODO: handle metatile output

	if(NOT GRIT_DEPTH EQUAL 16 AND NOT GRIT_NO_PALETTE)
		list(APPEND GRIT_ARGS -p)
	else()
		set(GRIT_NO_PALETTE TRUE)
		list(APPEND GRIT_ARGS -p!)
	endif()

	if(DEFINED GRIT_OPTIONS)
		list(APPEND GRIT_ARGS ${GRIT_OPTIONS})
	endif()
endmacro()

macro(__grit_output_name var fext)
	if(DEFINED GRIT_${var})
		get_filename_component(GRIT_${var} "${GRIT_${var}}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	else()
		set(GRIT_${var} "${CMAKE_CURRENT_BINARY_DIR}/${target}.${fext}")
	endif()
endmacro()

macro(__grit_rename_cmd from to)
	list(APPEND GRIT_RENAME_CMDS
		COMMAND ${CMAKE_COMMAND} -E rename "${from}" "${to}"
	)
endmacro()

function(grit_add_grf_target target input)
	cmake_parse_arguments(PARSE_ARGV 1 GRIT "BITMAP;TEXTURE;NO_MAP;NO_PALETTE" "OUTPUT;DEPTH" "OPTIONS")
	__grit_parse_options_common()

	__grit_output_name(OUTPUT grf)
	__grit_rename_cmd("~$${target}.grf" "${GRIT_OUTPUT}")

	get_filename_component(input "${input}" ABSOLUTE)
	add_custom_command(
		OUTPUT "${GRIT_OUTPUT}"
		COMMAND ${GRIT_EXE} "${input}" ${GRIT_ARGS} -ftr -fh! -o "~$${target}.grf"
		${GRIT_RENAME_CMDS}
		DEPENDS "${input}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		COMMENT "Converting graphics to GRF ${target}"
		VERBATIM
	)

	add_custom_target(${target} DEPENDS "${GRIT_OUTPUT}")
	dkp_set_target_file(${target} "${GRIT_OUTPUT}")
endfunction()

macro(grit_add_nds_icon_target target input)
	grit_add_grf_target(${target} "${input}"
		NO_MAP
		DEPTH 4
		OPTIONS -pe 16 -gT FF00FF
	)
endmacro()

function(grit_add_binary_target target input)
	cmake_parse_arguments(PARSE_ARGV 1 GRIT "BITMAP;TEXTURE;NO_MAP;NO_PALETTE" "OUTPUT_GFX;OUTPUT_MAP;OUTPUT_PAL;DEPTH" "OPTIONS")
	__grit_parse_options_common()

	__grit_output_name(OUTPUT_GFX gfx)
	__grit_rename_cmd("~$${target}.img.bin" "${GRIT_OUTPUT_GFX}")
	set(GRIT_OUTPUTS "${GRIT_OUTPUT_GFX}")

	if(NOT GRIT_NO_MAP)
		__grit_output_name(OUTPUT_MAP map)
		__grit_rename_cmd("~$${target}.map.bin" "${GRIT_OUTPUT_MAP}")
		list(APPEND GRIT_OUTPUTS "${GRIT_OUTPUT_MAP}")
	endif()

	if(NOT GRIT_NO_PALETTE)
		__grit_output_name(OUTPUT_PAL pal)
		__grit_rename_cmd("~$${target}.pal.bin" "${GRIT_OUTPUT_PAL}")
		list(APPEND GRIT_OUTPUTS "${GRIT_OUTPUT_PAL}")
	endif()

	get_filename_component(input "${input}" ABSOLUTE)
	add_custom_command(
		OUTPUT ${GRIT_OUTPUTS}
		COMMAND ${GRIT_EXE} "${input}" ${GRIT_ARGS} -ftb -fh! -o "~$${target}.bin"
		${GRIT_RENAME_CMDS}
		DEPENDS "${input}"
		WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
		COMMENT "Converting graphics to binary ${target}"
		VERBATIM
	)

	add_custom_target(${target} DEPENDS ${GRIT_OUTPUTS})
	dkp_set_target_file(${target} ${GRIT_OUTPUTS})
endfunction()

function(mm_add_soundbank_target target)
	cmake_parse_arguments(PARSE_ARGV 1 MMUTIL "" "OUTPUT;HEADER" "INPUTS;OPTIONS")

	set(MMUTIL_ARGS "")
	set(MMUTIL_OUTPUTS "")

	if (NOT MMUTIL_EXE)
		message(FATAL_ERROR "Could not find mmutil: try installing mmutil")
	endif()

	if(NINTENDO_GBA)
		# Nothing on purpose
	elseif(NINTENDO_DS)
		list(APPEND MMUTIL_ARGS -d)
	else()
		message(FATAL_ERROR "mm_add_soundbank_target: only supported on GBA and DS platforms")
	endif()

	if(DEFINED MMUTIL_OUTPUT)
		get_filename_component(MMUTIL_OUTPUT "${MMUTIL_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
	else()
		set(MMUTIL_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}.bin")
	endif()
	list(APPEND MMUTIL_OUTPUTS "${MMUTIL_OUTPUT}")

	if(DEFINED MMUTIL_HEADER)
		get_filename_component(MMUTIL_HEADER "${MMUTIL_HEADER}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
		list(APPEND MMUTIL_ARGS "-h${MMUTIL_HEADER}")
		list(APPEND MMUTIL_OUTPUTS "${MMUTIL_HEADER}")
	endif()

	if(NOT DEFINED MMUTIL_INPUTS)
		if(DEFINED MMUTIL_UNPARSED_ARGUMENTS)
			set(MMUTIL_INPUTS "${MMUTIL_UNPARSED_ARGUMENTS}")
		else()
			message(FATAL_ERROR "mm_add_soundbank_target: must provide at least one input file")
		endif()
	endif()

	add_custom_command(
		OUTPUT ${MMUTIL_OUTPUTS}
		COMMAND "${MMUTIL_EXE}" ${MMUTIL_ARGS} "-o${MMUTIL_OUTPUT}" ${MMUTIL_INPUTS}
		DEPENDS ${MMUTIL_INPUTS}
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
		COMMENT "Building maxmod soundbank ${target}"
		VERBATIM
	)

	add_custom_target(${target} DEPENDS "${MMUTIL_OUTPUT}")
	dkp_set_target_file(${target} "${MMUTIL_OUTPUT}")
endfunction()
