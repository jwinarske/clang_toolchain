#
# MIT License
#
# Copyright (c) 2018 Joel Winarske
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

cmake_minimum_required(VERSION 3.14.0)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "MinSizeRel" CACHE STRING "Choose the type of build, options are: Debug, Release, or MinSizeRel." FORCE)
    message(STATUS "CMAKE_BUILD_TYPE not set, defaulting to MinSizeRel.")
endif()

set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}" "${CMAKE_SOURCE_DIR}/cmake")

if(NOT BUILD_NUMBER)
    set(BUILD_NUMBER 0)
endif()
set(CLANG_TOOLCHAIN_VERSION 1.0.${BUILD_NUMBER})

set(PACKAGE_NAME clang-toolchain)
project(${PACKAGE_NAME} VERSION "${CLANG_TOOLCHAIN_VERSION}" LANGUAGES CXX C)

include (ExternalProject)

message(STATUS "Generator .............. ${CMAKE_GENERATOR}")
message(STATUS "Build Type ............. ${CMAKE_BUILD_TYPE}")

include(build_options)

set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/third_party CACHE PATH "Third party dir")

if(NOT SDK_ROOT_DIR)
    set(SDK_ROOT_DIR ${CMAKE_SOURCE_DIR})
endif()

if(NOT TOOLCHAIN_DIR)
    set(TOOLCHAIN_DIR ${SDK_ROOT_DIR}/sdk/toolchain CACHE PATH "Toolchain Dir")
endif()

if(NOT TOOLCHAIN_FILE_DIR)
    set(TOOLCHAIN_FILE_DIR ${CMAKE_BINARY_DIR} CACHE PATH "Toolchain File Dir")
endif()

if(NOT TARGET_SYSROOT)
    set(TARGET_SYSROOT ${SDK_ROOT_DIR}/sdk/sysroot CACHE PATH "Sysroot Dir")
endif()

if(NOT TARGET_TRIPLE)
    set(TARGET_TRIPLE arm-none-musleabihf CACHE STRING "Target Triple")
endif()

if(NOT LLVM_TARGETS_TO_BUILD)
    set(LLVM_TARGETS_TO_BUILD ARM)
endif()

if(NOT TARGET_ARCH)
    set(TARGET_ARCH arm)
endif()

if(NOT LLVM_GIT_TAG)
    set(LLVM_GIT_TAG llvmorg-10.0.0)
endif()

if(NOT LLVM_VER_DIR)
    set(LLVM_VER_DIR 10.0.0)
endif()

set(LLVM_CONFIG_PATH ${LLVM_BIN_DIR}/llvm-config)
set(LLVM_SRC_DIR ${THIRD_PARTY_DIR}/llvm-project)
set(LLVM_BIN_DIR ${TOOLCHAIN_DIR}/bin)

#
# Package Config
#
set(PKG_CONFIG_PATH ${TARGET_SYSROOT}/usr/lib/${TARGET_TRIPLE}/pkgconfig:${TARGET_SYSROOT}/usr/share/pkgconfig)

if(BUILD_PLATFORM_RPI)
    set(PKG_CONFIG_PATH ${PKG_CONFIG_PATH}:${TARGET_SYSROOT}/opt/vc/lib/pkgconfig)
endif()

MESSAGE(STATUS "PKG_CONFIG_PATH = ${PKG_CONFIG_PATH}")

SET(TARGET_MARCH armv7a)

SET(TARGET_CONFIG "-march=${TARGET_MARCH}") # --with-float=${TARGET_FLOAT} --with-fpu=${TARGET_FPU})
SET(TARGET_LINKER_FLAGS "-v -fuse-ld=lld")

# set(TARGET_C_LINK_FLAGS   "${TARGET_C_LINK_FLAGS} --rtlib=compiler-rt")
# set(TARGET_CXX_LINK_FLAGS "${TARGET_CXX_LINK_FLAGS} --rtlib=compiler-rt")
# set(TARGET_C_LINK_FLAGS   "${TARGET_C_LINK_FLAGS} -fuse-ld=${TARGET_LINKER}")
# set(TARGET_CXX_LINK_FLAGS "${TARGET_CXX_LINK_FLAGS} -fuse-ld=${TARGET_LINKER}")


#
# Build Flow
#
#   Host    |    Target ->
#  -------      -----------      ----------      ------      -----------      -----------      --------      -------------
# | Clang | -> | musl inst | -> | Builtins | -> | musl | -> | libunwind | -> | libcxxabi | -> | libcxx | -> | compiler-rt |
#  -------      -----------      ----------      ------      -----------      -----------      --------      -------------
#
# 1. Clang is needed for builtins and sanitizers, can skip if you already have a recent Clang.
# 2. The builtins are the equivalent of libgcc, a static library. These are a small part of compiler-rt that we need to build first.
# 3. The LLVM unwinder may use builtins from libunwind, needs C++ header from libc++
# 4. The libc++abi C++ runtime uses the unwinder from LLVM unwind
# 5. The libc++ C++ standard library uses libc++abi
# 6. The remainder of compiler-rt includes the sanitizers, which need libc++

#
# Base Dependencies
#
include(sysroot)

include(clang)
include(libunwind)
include(libcxxabi)
include(libcxx)
include(compiler-rt)

if(BUILD_MUSL_CLIB)
    include(musl)
endif()
#elseif(BUILD_NEWLIB_CLIB)
    include(newlib)
#endif()

#
# Platform Apps
#

configure_file(${CMAKE_SOURCE_DIR}/cmake/target.clang.toolchain.cmake.in ${TOOLCHAIN_FILE_DIR}/target.toolchain.cmake @ONLY)


if(BUILD_PLATFORM_RPI)
    include(rpi/apps)
endif()

if(BUILD_WAYLAND)
    include(wayland/apps)
endif()

#
# Common
#
if(BUILD_MRAA AND BUILD_LIBCXX)

    SET(MRAA_C_FLAGS ${TARGET_CONFIG})
    SET(MRAA_CXX_FLAGS "--sysroot=${TOOLCHAIN_DIR} ${TARGET_CONFIG}")
    SET(MRAA_LINKER_FLAGS "-nostdlib -fuse-ld=lld")

    ExternalProject_Add(mraa
        GIT_REPOSITORY https://github.com/intel-iot-devkit/mraa.git
        GIT_TAG master
        GIT_SHALLOW ON
        SOURCE_DIR ${THIRD_PARTY_DIR}/mraa
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CMAKE_ARGS
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN_DIR}
            -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_C_FLAGS=${MRAA_C_FLAGS}
            -DCMAKE_CXX_FLAGS=${MRAA_CXX_FLAGS}
            -DCMAKE_SHARED_LINKER_FLAGS=${MRAA_LINKER_FLAGS}
            -DBUILDSWIG=OFF
            -DBUILDSWIGPYTHON=OFF
            -DBUILDSWIGNODE=OFF
            -DJSONPLAT=OFF
            -DBUILDTESTS=OFF
    )
    add_dependencies(mraa libcxx)
    if(BUILD_BINUTILS)
#        add_dependencies(mraa binutils)
    endif()
    if(BUILD_PLATFORM_SYSROOT)
#        add_dependencies(mraa sysroot)
    endif()
endif()
