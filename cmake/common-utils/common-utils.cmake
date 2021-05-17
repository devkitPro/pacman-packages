find_program(BIN2S_EXE NAMES bin2s HINTS "${DEVKITPRO}/tools/bin")
if (NOT BIN2S_EXE)
	message(WARNING "Could not find bin2s: try installing general-tools")
endif()

function(dkp_embed_binaries outvar)
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "dkp_generate_binary: must provide at least one input file")
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
			COMMENT "Generating embedded binary for ${infile}"
		)

		list(APPEND outlist "${CMAKE_CURRENT_BINARY_DIR}/${basename}.s" "${CMAKE_CURRENT_BINARY_DIR}/${basename}.h")
	endforeach()

	set(${outvar} "${outlist}" PARENT_SCOPE)
endfunction()

function(dkp_target_embedded_binaries target)
	dkp_embed_binaries(intermediates ${ARGN})
	target_sources(${target} PRIVATE ${intermediates})
endfunction()
