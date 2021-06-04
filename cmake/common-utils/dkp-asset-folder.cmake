cmake_minimum_required(VERSION 3.7)
include(dkp-custom-target)

function(dkp_add_asset_target target folder)
	if (NOT IS_ABSOLUTE "${folder}")
		set(folder "${CMAKE_CURRENT_LIST_DIR}/${folder}")
	endif()

	add_custom_target(${target})
	set_target_properties(${target} PROPERTIES
		DKP_ASSET_FOLDER "${folder}"
		DKP_ASSET_FILES ""
	)
endfunction()

function(dkp_install_assets target)
	get_target_property(_dest ${target} DKP_ASSET_FOLDER)
	if (NOT _dest)
		message(FATAL_ERROR "dkp_install_assets: ${target} is not a valid asset target")
	endif()

	cmake_parse_arguments(ASSET "" "DESTINATION" "TARGETS" ${ARGN})

	if (DEFINED ASSET_DESTINATION)
		set(_dest "${_dest}/${ASSET_DESTINATION}")
	endif()

	if (NOT DEFINED ASSET_TARGETS)
		message(FATAL_ERROR "dkp_install_assets: must specify at least one target to install")
	endif()

	foreach (srctarget ${ASSET_TARGETS})
		if (NOT TARGET ${srctarget})
			message(FATAL_ERROR "dkp_install_assets: target ${srctarget} not found")
		endif()

		if (TARGET ${srctarget}_install_to_${target})
			message(WARNING "dkp_install_assets: target ${srctarget} already installed to ${target}, skipping")
			continue()
		endif()

		dkp_resolve_file(_srcfile ${srctarget})
		get_filename_component(_name "${_srcfile}" NAME)
		set(_destfile "${_dest}/${_name}")

		add_custom_command(
			OUTPUT "${_destfile}"
			COMMAND ${CMAKE_COMMAND} -E make_directory "${_dest}"
			COMMAND ${CMAKE_COMMAND} -E copy "${_srcfile}" "${_destfile}"
			COMMENT "Installing ${srctarget} to ${target}"
			DEPENDS ${srctarget} "${_srcfile}"
		)

		add_custom_target(${srctarget}_install_to_${target}
			DEPENDS "${_destfile}"
		)

		add_dependencies(${target} ${srctarget}_install_to_${target})
		set_property(TARGET ${target} APPEND PROPERTY DKP_ASSET_FILES "${_destfile}")
	endforeach()
endfunction()

function(dkp_track_assets target)
	get_target_property(_dest ${target} DKP_ASSET_FOLDER)
	if (NOT _dest)
		message(FATAL_ERROR "dkp_track_assets: ${target} is not a valid asset target")
	endif()

	cmake_parse_arguments(ASSET "" "FOLDER" "FILES" ${ARGN})

	if (DEFINED ASSET_FOLDER)
		set(_dest "${_dest}/${ASSET_FOLDER}")
	endif()

	if (NOT DEFINED ASSET_FILES)
		message(FATAL_ERROR "dkp_track_assets: must provide at least one input file")
	endif()

	foreach (file ${ASSET_FILES})
		set(file "${_dest}/${file}")
		if (NOT EXISTS "${file}")
			message(FATAL_ERROR "dkp_track_assets: file ${file} does not exist")
		endif()

		set_property(TARGET ${target} APPEND PROPERTY DKP_ASSET_FILES "${file}")
	endforeach()
endfunction()
