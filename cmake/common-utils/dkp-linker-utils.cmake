cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

function(dkp_target_generate_symbol_list target)
	get_target_property(outputname ${target} OUTPUT_NAME)
	if(NOT outputname)
		set(outputname "${target}")
	endif()

	target_link_options(${target} PRIVATE
		-Wl,-Map,$<TARGET_FILE_DIR:${target}>/${outputname}.map
	)

	add_custom_command(
		TARGET ${target} POST_BUILD
		COMMAND ${DKP_NM} -CSn $<TARGET_FILE:${target}> > ${outputname}.lst
		WORKING_DIRECTORY $<TARGET_FILE_DIR:${target}>
		BYPRODUCTS ${outputname}.lst ${outputname}.map
	)
endfunction()
