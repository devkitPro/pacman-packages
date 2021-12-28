cmake_minimum_required (VERSION 3.7)

function(dkp_target_link_options target)
	if (${CMAKE_VERSION} GREATER_EQUAL "3.13")
		target_link_options(${target} PRIVATE ${ARGN})
	else()
		foreach(opt ${ARGN})
			set_property(TARGET ${target} APPEND_STRING PROPERTY LINK_FLAGS " ${opt}")
		endforeach()
	endif()
endfunction()

function(dkp_target_generate_symbol_list target)
	dkp_target_link_options(${target}
		-Wl,-Map,${target}.map
	)

	add_custom_command(
		TARGET ${target} POST_BUILD
		COMMAND ${DKP_NM} -CSn $<TARGET_FILE:${target}> > ${target}.lst
		BYPRODUCTS ${target}.lst ${target}.map
	)
endfunction()
