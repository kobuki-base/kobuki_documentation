
set(TOOLCHAIN_TUPLE "arm-linux-gnueabihf" CACHE STRING "Toolchain signature identifying cpu-vendor-platform-clibrary.")
set(TOOLCHAIN_ROOT "/usr/${TOOLCHAIN_TUPLE}" CACHE STRING "Root of the target development environment (libraries, headers etc).")

# Target information
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR "arm")
unset(CMAKE_Fortran_COMPILER)  # This toolchain doesn't have a fortran compiler
set(CMAKE_C_COMPILER   ${TOOLCHAIN_TUPLE}-gcc) # Make sure these are in your PATH
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_TUPLE}-g++)

# Search paths
set(CMAKE_FIND_ROOT_PATH "${TOOLCHAIN_SYSROOT};${CMAKE_CURRENT_LIST_DIR}/install" CACHE STRING "Cmake search variable for finding libraries/headers.")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER) # Don't search for programs outside of CMAKE_FIND_ROOT_PATH and CMAKE_SYSROOT
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)  # ... libraries
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)  # ... headers
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)  # ... cmake modules


# CXX Flags specific to the target platform (typical raspberry pi platform)
#
#  - benchmark yourself, mileage will vary considerably, large speedups to be gained
#  - a good starting point is https://wiki.gentoo.org/wiki/Safe_CFLAGS#ARMv6.2FARM1176JZF-S
#
# Also, -Wno-psabi avoids irritating gcc 7.1 warnings about not mixing binaries with gcc 6 binaries
#
set(CMAKE_CXX_FLAGS "-march=armv7 -mtune=arm1176jzf-s -pipe -mfloat-abi=hard -mfpu=vfp -Wno-psabi" CACHE STRING "flags specific for an armv7/arm1176jzf-s platform")

# Hide from cache's front page
MARK_AS_ADVANCED(CMAKE_GENERATOR CMAKE_FIND_ROOT_PATH CMAKE_TOOLCHAIN_FILE TOOLCHAIN_FAMILY TOOLCHAIN_TUPLE)
