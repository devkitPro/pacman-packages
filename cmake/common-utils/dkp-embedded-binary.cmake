cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

include(dkp-impl-helpers)
include(dkp-custom-target)

function(dkp_add_embedded_binary_library target)
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "dkp_add_embedded_binary_library: must provide at least one input file")
	endif()

	__dkp_asm_lang(lang dkp_add_embedded_binary_library)
	set(genfolder "${CMAKE_CURRENT_BINARY_DIR}/.dkp-generated/${target}")
	set(intermediates "")
	foreach (inname IN LISTS ARGN)
		dkp_resolve_file(infiles "${inname}" MULTI)
		foreach(infile IN LISTS infiles)
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
			set_source_files_properties("${genfolder}/${basename}.s" PROPERTIES LANGUAGE "${lang}")
		endforeach()
	endforeach()

	add_library(${target} OBJECT ${intermediates})
	target_include_directories(${target} INTERFACE "${genfolder}")
endfunction()

function(dkp_target_use_embedded_binary_libraries target)
	message(DEPRECATION "dkp_target_use_embedded_binary_libraries is deprecated, please use target_link_libraries(${target} PRIVATE ...) instead")
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "dkp_target_use_embedded_binary_libraries: must provide at least one input library")
	endif()

	target_link_libraries(${target} PRIVATE ${ARGN})
endfunction()
