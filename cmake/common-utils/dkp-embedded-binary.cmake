cmake_minimum_required(VERSION 3.7)

find_program(BIN2S_EXE NAMES bin2s HINTS "${DEVKITPRO}/tools/bin")
if (NOT BIN2S_EXE)
	message(WARNING "Could not find bin2s: try installing general-tools")
endif()

function(dkp_generate_binary_embed_sources outvar)
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "dkp_generate_binary_embed_sources: must provide at least one input file")
	endif()

	set(outlist "")
	foreach (infile ${ARGN})
		get_filename_component(basename "${infile}" NAME)
		string(REPLACE "." "_" basename "${basename}")

		add_custom_command(
			OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${basename}.s" "${CMAKE_CURRENT_BINARY_DIR}/${basename}.h"
			COMMAND ${BIN2S_EXE} -H "${CMAKE_CURRENT_BINARY_DIR}/${basename}.h" "${infile}" > "${CMAKE_CURRENT_BINARY_DIR}/${basename}.s"
			DEPENDS "${infile}"
			WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
			COMMENT "Generating binary embedding source for ${infile}"
		)

		list(APPEND outlist "${CMAKE_CURRENT_BINARY_DIR}/${basename}.s" "${CMAKE_CURRENT_BINARY_DIR}/${basename}.h")
	endforeach()

	set(${outvar} "${outlist}" PARENT_SCOPE)
endfunction()

function(dkp_add_embedded_binary_library target)
	dkp_generate_binary_embed_sources(intermediates ${ARGN})
	add_library(${target} OBJECT ${intermediates})
	target_include_directories(${target} INTERFACE ${CMAKE_CURRENT_BINARY_DIR})
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
