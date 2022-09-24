cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

function(dkp_set_target_file target)
	if (NOT ${ARGC} GREATER 1)
		message(FATAL_ERROR "dkp_set_target_file: must provide at least one input file")
	endif()

	set_target_properties(${target} PROPERTIES DKP_FILE "${ARGN}")
endfunction()

function(dkp_resolve_file outvar inname)
	cmake_parse_arguments(PARSE_ARGV 2 ARG "MULTI" "" "")

	if (TARGET "${inname}")
		get_target_property(_filename "${inname}" DKP_FILE)
		if (NOT _filename)
			message(FATAL_ERROR "dkp_resolve_file: target ${inname} does not have a registered file")
		endif()

		list(LENGTH _filename listlen)
		if(listlen GREATER 1 AND NOT ARG_MULTI)
			message(FATAL_ERROR "dkp_resolve_file: target ${inname} has more than one registered file")
		endif()

		set(${outvar} "${_filename}" PARENT_SCOPE)
	else()
		get_filename_component(innameabs "${inname}" ABSOLUTE)
		if(NOT EXISTS "${innameabs}")
			message(FATAL_ERROR "dkp_resolve_file: unable to resolve file: ${inname}")
		endif()
		set(${outvar} "${innameabs}" PARENT_SCOPE)
	endif()
endfunction()
