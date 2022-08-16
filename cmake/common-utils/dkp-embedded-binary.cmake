cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

include(dkp-custom-target)

function(dkp_add_embedded_binary_library target)
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "dkp_add_embedded_binary_library: must provide at least one input file")
	endif()

	set(genfolder "${CMAKE_CURRENT_BINARY_DIR}/.dkp-generated/${target}")
	set(intermediates "")
	foreach (inname ${ARGN})
		dkp_resolve_file(infile "${inname}")
		get_filename_component(basename "${infile}" NAME)
		string(REPLACE "." "_" basename "${basename}")

		if (TARGET "${inname}")
			set(indeps ${inname} ${infile})
		else()
			set(indeps ${infile})
		endif()

		add_custom_command(
			OUTPUT "${genfolder}/${basename}.s" "${genfolder}/${basename}.h"
			COMMAND ${CMAKE_COMMAND} -E make_directory "${genfolder}"
			COMMAND ${DKP_BIN2S} -H "${genfolder}/${basename}.h" "${infile}" > "${genfolder}/${basename}.s"
			DEPENDS ${indeps}
			COMMENT "Generating binary embedding source for ${inname}"
		)

		list(APPEND intermediates "${genfolder}/${basename}.s" "${genfolder}/${basename}.h")
	endforeach()

	add_library(${target} OBJECT ${intermediates})
	target_include_directories(${target} INTERFACE "${genfolder}")
endfunction()

function(dkp_target_use_embedded_binary_libraries target)
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "dkp_target_use_embedded_binary_libraries: must provide at least one input library")
	endif()

	foreach (libname ${ARGN})
		target_sources(${target} PRIVATE $<TARGET_OBJECTS:${libname}>)
		target_include_directories(${target} PRIVATE $<TARGET_PROPERTY:${libname},INTERFACE_INCLUDE_DIRECTORIES>)
	endforeach()
endfunction()
