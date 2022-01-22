
foreach(lang C CXX ASM)
	# Set object file extension back to the default for Unix-like platforms
	set(CMAKE_${lang}_OUTPUT_EXTENSION .o)

	if(NOT DKP_USE_DOUBLE_OBJECT_FILE_EXTENSIONS)
		# Disable usage of double object file extensions (.cpp.o -> .o)
		set(CMAKE_${lang}_OUTPUT_EXTENSION_REPLACE 1)
	endif()
endforeach()
