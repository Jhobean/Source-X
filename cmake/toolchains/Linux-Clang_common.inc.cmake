SET (TOOLCHAIN_LOADED 1)

function (toolchain_force_compiler)
	SET (CMAKE_C_COMPILER 	"clang" 	CACHE STRING "C compiler" 	FORCE)
	SET (CMAKE_CXX_COMPILER "clang++" 	CACHE STRING "C++ compiler" FORCE)
endfunction ()


function (toolchain_exe_stuff_common)

	SET (ENABLED_SANITIZER false)
	IF (${USE_ASAN})
		SET (C_FLAGS_EXTRA 		"${C_FLAGS_EXTRA}   -fsanitize=address -fsanitize-address-use-after-scope")
		SET (CXX_FLAGS_EXTRA 	"${CXX_FLAGS_EXTRA} -fsanitize=address -fsanitize-address-use-after-scope")
		SET (ENABLED_SANITIZER true)
	ENDIF ()
	IF (${USE_MSAN})
		MESSAGE (WARNING "You have enabled MSAN. Make sure you do know what you are doing. It doesn't work out of the box. \
See comments in the toolchain and: https://github.com/google/sanitizers/wiki/MemorySanitizerLibcxxHowTo")
		SET (C_FLAGS_EXTRA 		"${C_FLAGS_EXTRA}   -fsanitize=memory -fsanitize-memory-track-origins -fPIE")
		SET (CXX_FLAGS_EXTRA 	"${CXX_FLAGS_EXTRA} -fsanitize=memory -fsanitize-memory-track-origins -fPIE")
		SET (ENABLED_SANITIZER true)
	ENDIF ()
	IF (${USE_LSAN})
		SET (C_FLAGS_EXTRA 		"${C_FLAGS_EXTRA}   -fsanitize=leak")
		SET (CXX_FLAGS_EXTRA 	"${CXX_FLAGS_EXTRA} -fsanitize=leak")
		SET (ENABLED_SANITIZER true)
	ENDIF ()
	IF (${USE_UBSAN})
		SET (UBSAN_FLAGS		"-fsanitize=undefined,\
shift,integer-divide-by-zero,vla-bound,null,signed-integer-overflow,bounds,\
float-divide-by-zero,float-cast-overflow,pointer-overflow,\
unreachable,nonnull-attribute,returns-nonnull-attribute \
-fno-sanitize=enum")
		SET (C_FLAGS_EXTRA 		"${C_FLAGS_EXTRA}   ${UBSAN_FLAGS}")
		SET (CXX_FLAGS_EXTRA 	"${CXX_FLAGS_EXTRA} ${UBSAN_FLAGS} -fsanitize=return,vptr")
		SET (ENABLED_SANITIZER true)
	ENDIF ()
	IF (${ENABLED_SANITIZER})
		SET (PREPROCESSOR_DEFS_EXTRA "${PREPROCESSOR_DEFS_EXTRA} _SANITIZERS")
	ENDIF ()


	#-- Setting compiler flags common to all builds.

	SET (C_WARNING_OPTS
		"-Wall -Wextra -Wno-unknown-pragmas -Wno-format -Wno-switch -Wno-implicit-fallthrough\
		-Wno-parentheses -Wno-misleading-indentation -Wno-strict-aliasing -Wno-unused-result\
		-Wno-error=unused-but-set-variable -Wno-implicit-function-declaration") # this line is for warnings issued by 3rd party C code
	SET (CXX_WARNING_OPTS
		"-Wall -Wextra -Wno-unknown-pragmas -Wno-format -Wno-switch -Wno-implicit-fallthrough\
		-Wno-parentheses -Wno-misleading-indentation -Wno-conversion-null -Wno-unused-result")
	#SET (C_ARCH_OPTS	) # set in parent toolchain
	#SET (CXX_ARCH_OPTS	) # set in parent toolchain
	SET (C_OPTS			"-std=c11   -pthread -fexceptions -fnon-call-exceptions")
	SET (CXX_OPTS		"-std=c++20 -pthread -fexceptions -fnon-call-exceptions")
	SET (C_SPECIAL		"-pipe")
	SET (CXX_SPECIAL	"-pipe -ffast-math")

	SET (CMAKE_C_FLAGS		"${C_WARNING_OPTS} ${C_OPTS} ${C_SPECIAL} ${C_FLAGS_EXTRA}"		PARENT_SCOPE)
	SET (CMAKE_CXX_FLAGS	"${CXX_WARNING_OPTS} ${CXX_OPTS} ${CXX_SPECIAL} ${CXX_FLAGS_EXTRA}"	PARENT_SCOPE)
	# GCC flags not supported by clang:
	#	Warnings: "-Wno-nonnull-compare -Wno-maybe-uninitialized"
	#	Other: "-fno-expensive-optimizations"

	# MemorySanitizer: it doesn't work out of the box. It needs to be linked to an MSAN-instrumented build of libc++ and libc++abi.
	#  This means: one should build them from LLVM source...
	#  https://github.com/google/sanitizers/wiki/MemorySanitizerLibcxxHowTo
	#IF (${USE_MSAN})
	#	SET (CMAKE_CXX_FLAGS	"${CMAKE_CXX_FLAGS} -stdlib=libc++")
	#ENDIF()
	# Use "-stdlib=libstdc++" to link against GCC c/c++ libs (this is done by default)
	# To use LLVM libc++ use "-stdlib=libc++", but you need to install it separately


	#-- Find libraries to be linked to.

	MESSAGE(STATUS "Locating libraries to be linked to...")

	SET (LIBS_LINK_LIST
		mariadb
		dl
	)
	FOREACH (LIB_NAME ${LIBS_LINK_LIST})
		IF (${ARCH_BITS} EQUAL 64)
			FIND_LIBRARY(
				LIB_${LIB_NAME}_WITH_PATH	${LIB_NAME}
				HINT
				"/usr/lib/x86_64-linux-gnu/libmariadb3"
				"/usr/lib/x86_64-linux-gnu/mysql"
				"/usr/lib/x86_64-linux-gnu"
				"/usr/lib64/mysql"
				"/usr/lib64"
				"/usr/lib/mysql"
				"/usr/lib"
			)
		ELSE ()
			FIND_LIBRARY(
				LIB_${LIB_NAME}_WITH_PATH	${LIB_NAME}
				HINT
				"/usr/lib/i386-linux-gnu/libmariadb3"
				"/usr/lib/i386-linux-gnu/mysql"
				"/usr/lib/i386-linux-gnu"
				"/usr/lib/mysql"
				"/usr/lib"
			)
		ENDIF ()
	ENDFOREACH ()


	#-- Setting common linker flags

	IF (${USE_MSAN})
		SET (CMAKE_EXE_LINKER_FLAGS_EXTRA	"${CMAKE_EXE_LINKER_FLAGS_EXTRA} -pie")
	ENDIF()

	 # -s and -g need to be added/removed also to/from linker flags!
	SET (CMAKE_EXE_LINKER_FLAGS	"-pthread -dynamic ${CMAKE_EXE_LINKER_FLAGS_EXTRA}" PARENT_SCOPE)



	#-- Adding compiler flags per build.

	 # (note: since cmake 3.3 the generator $<COMPILE_LANGUAGE> exists).
	 # do not use " " to delimitate these flags!
	 # -s: strips debug info (remove it when debugging); -g: adds debug informations;
	 # -fno-omit-frame-pointer disables a good optimization which may corrupt the debugger stack trace.
	 SET (COMPILE_OPTIONS_EXTRA)
	 IF (ENABLED_SANITIZER OR TARGET spheresvr_debug)
		 SET (COMPILE_OPTIONS_EXTRA -fno-omit-frame-pointer -fno-inline)
	 ENDIF ()
	 IF (TARGET spheresvr_release)
		 TARGET_COMPILE_OPTIONS ( spheresvr_release	PUBLIC -s -O3 ${COMPILE_OPTIONS_EXTRA})
	 ENDIF ()
	 IF (TARGET spheresvr_nightly)
		 IF (ENABLED_SANITIZER)
			 TARGET_COMPILE_OPTIONS ( spheresvr_nightly	PUBLIC -ggdb3 -O1 ${COMPILE_OPTIONS_EXTRA})
		 ELSE ()
			 TARGET_COMPILE_OPTIONS ( spheresvr_nightly	PUBLIC -O3 ${COMPILE_OPTIONS_EXTRA})
		 ENDIF ()
	 ENDIF ()
	 IF (TARGET spheresvr_debug)
		 TARGET_COMPILE_OPTIONS ( spheresvr_debug	PUBLIC -ggdb3 -Og ${COMPILE_OPTIONS_EXTRA})
	 ENDIF ()


	#-- Setting per-build linker flags.

	 # Linking Unix libs.
	 # same here, do not use " " to delimitate these flags!
	IF (TARGET spheresvr_release)
		TARGET_LINK_LIBRARIES ( spheresvr_release	${LIB_mariadb_WITH_PATH} ${LIB_dl_WITH_PATH} )
	ENDIF (TARGET spheresvr_release)
	IF (TARGET spheresvr_nightly)
		TARGET_LINK_LIBRARIES ( spheresvr_nightly	${LIB_mariadb_WITH_PATH} ${LIB_dl_WITH_PATH} )
	ENDIF (TARGET spheresvr_nightly)
	IF (TARGET spheresvr_debug)
		TARGET_LINK_LIBRARIES ( spheresvr_debug		${LIB_mariadb_WITH_PATH} ${LIB_dl_WITH_PATH} )
	ENDIF (TARGET spheresvr_debug)


	#-- Set common define macros.

	add_compile_definitions(${PREPROCESSOR_DEFS_EXTRA} _LINUX _LIBEV Z_PREFIX _POSIX_SOURCE _GITVERSION _EXCEPTIONS_DEBUG)
		# _LINUX: linux OS.
		# _LIBEV: use libev
		# Z_PREFIX: Use the "z_" prefix for the zlib functions
		# _POSIX_SOURCE: needed for libev compilation in some linux distributions (doesn't seem to affect compilation on distributions that don't need it)
		# _EXCEPTIONS_DEBUG: Enable advanced exceptions catching. Consumes some more resources, but is very useful for debug
		#   on a running environment. Also it makes sphere more stable since exceptions are local.


	#-- Add per-build define macros.

	IF (TARGET spheresvr_release)
		TARGET_COMPILE_DEFINITIONS ( spheresvr_release	PUBLIC NDEBUG )
	ENDIF (TARGET spheresvr_release)
	IF (TARGET spheresvr_nightly)
		TARGET_COMPILE_DEFINITIONS ( spheresvr_nightly	PUBLIC NDEBUG THREAD_TRACK_CALLSTACK _NIGHTLYBUILD )
	ENDIF (TARGET spheresvr_nightly)
	IF (TARGET spheresvr_debug)
		TARGET_COMPILE_DEFINITIONS ( spheresvr_debug	PUBLIC _DEBUG THREAD_TRACK_CALLSTACK _PACKETDUMP )
	ENDIF (TARGET spheresvr_debug)


	#-- Set different output folders for each build type
	# (When we'll have support for multi-target builds...)
	#SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_RELEASE	"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Release"	)
	#SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_DEBUG		"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Debug"	)
	#SET_TARGET_PROPERTIES(spheresvr PROPERTIES RUNTIME_OUTPUT_NIGHTLY	"${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/Nightly"	)

endfunction()
