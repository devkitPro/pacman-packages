
foreach(lang IN ITEMS C CXX ASM)
	# Set object file extension back to the default for Unix-like platforms
	set(CMAKE_${lang}_OUTPUT_EXTENSION .o)

	if(NOT DKP_USE_DOUBLE_OBJECT_FILE_EXTENSIONS)
		# Disable usage of double object file extensions (.cpp.o -> .o)
		set(CMAKE_${lang}_OUTPUT_EXTENSION_REPLACE 1)
	endif()

	if(NOT DKP_NO_BUILTIN_CMAKE_CONFIGS)
		# Override CMake's built-in flags for GNU compilers with saner defaults:
		# - Define DEBUG for Debug (no idea why CMake doesn't do this by default)
		# - Use -Og for Debug (As per GCC docs: "It is a better choice than -O0 for producing debuggable
		#     code because some compiler passes that collect debug information are disabled at -O0.")
		# - Use -Oz for MinSizeRel (Os no longer generates the "smallest possible size binaries")
		# - Use -O2 instead of -O3 for Release (O3 enables aggressive loop unrolling which can be
		#     extremely detrimental to code size, especially for platforms such as GBA/DS)
		# - Emit debug metadata on all configurations
		set(CMAKE_${lang}_FLAGS_DEBUG_INIT          " -g -Og -DDEBUG")
		set(CMAKE_${lang}_FLAGS_MINSIZEREL_INIT     " -g -Oz -DNDEBUG")
		set(CMAKE_${lang}_FLAGS_RELEASE_INIT        " -g -O2 -DNDEBUG")
		set(CMAKE_${lang}_FLAGS_RELWITHDEBINFO_INIT " -g -O2 -DNDEBUG")
	endif()
endforeach()
