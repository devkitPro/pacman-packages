cmake_minimum_required(VERSION 3.13)
include_guard(GLOBAL)

include(dkp-impl-helpers)

function(dkp_target_generate_symbol_list target)
	__dkp_target_derive_name(prefix ${target} "")

	target_link_options(${target} PRIVATE
		-Wl,-Map,${prefix}.map
	)

	add_custom_command(
		TARGET ${target} POST_BUILD
		COMMAND ${DKP_NM} -CSn $<TARGET_FILE:${target}> > ${prefix}.lst
		BYPRODUCTS ${prefix}.lst ${prefix}.map
	)
endfunction()
