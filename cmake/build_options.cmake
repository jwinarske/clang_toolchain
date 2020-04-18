#
# MIT License
#
# Copyright (c) 2020 Joel Winarske
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

#
# Platform
#
option(BUILD_PLATFORM_SYSROOT "Build Platform sysroot" ON)
option(BUILD_PLATFORM_RPI "Build Platform Raspberry Pi" ON)
option(UPDATE_TARGET "Update Target libraries" OFF)


#
# llvm projects
#
set(LLVM_ENABLE_PROJECTS "clang")

option(BUILD_CLANG_TOOLS_EXTRA "Build Clang Tools Extra" ON)
if(BUILD_CLANG_TOOLS_EXTRA)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|clang-tools-extra")
endif()

option(BUILD_COMPILER_RT "Build compiler-rt" ON)
if(BUILD_COMPILER_RT)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|compiler-rt")
endif()

option(BUILD_LIBCLC "Build libclc" ON)
if(BUILD_LIBCLC)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|libclc")
endif()

option(BUILD_LIBCXX "Build libcxx" ON) # cxxabi is built and linked with libcxx project build
if(BUILD_LIBCXX)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|libcxx")
endif()

option(BUILD_LIBCXXABI "Build libcxxabi" OFF) # cxxabi is built and linked with libcxx project build
if(BUILD_LIBCXXABI)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|libcxxabi")
endif()
option(BUILD_LIBCXXABI_EXCEPTIONS "c++abi Exceptions" OFF)
option(BUILD_LIBCXXABI_ASSERTIONS "c++abi Assertions" OFF)

option(BUILD_LIBUNWIND "Build libunwind" ON)
if(BUILD_LIBUNWIND)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|libunwind")
endif()

option(BUILD_LLD "Build lld Linker" ON)
if(BUILD_LLD)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|lld")
endif()

option(BUILD_LLDB "Build LLVM Debugger" OFF)
if(BUILD_LLDB)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|lldb")
endif()

option(BUILD_LLGO "Build llgo project" OFF)
if(BUILD_LLGO)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|llgo")
endif()

option(BUILD_MLIR "Build mlir project" OFF)
if(BUILD_MLIR)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|mlir")
endif()

option(BUILD_OPENMP "Build OpenMP support" ON)
if(BUILD_OPENMP)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|openmp")
endif()

option(BUILD_PARALLEL_LIBS "Build Parallel Libs supprt" ON)
if(BUILD_PARALLEL_LIBS)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|parallel-libs")
endif()

option(BUILD_POLLY "Build Polly supprt" ON)
if(BUILD_POLLY)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|polly")
endif()

option(BUILD_PSTL "Build Parallel STL support" ON)
if(BUILD_PSTL)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|pstl")
endif()

#
# Binutils
#
option(BUILD_BINUTILS "Download and build binutils for host" ON)

#
# C Libraries
#
option(BUILD_MUSL_CLIB "Musl C library" OFF)
option(BUILD_NEWLIB_CLIB "Newlib C library" OFF)
option(BUILD_LIBC "Build libc" ON)
if(BUILD_LIBC)
    set(LLVM_ENABLE_PROJECTS "${LLVM_ENABLE_PROJECTS}|libc")
endif()


#
# Sysroot
#

# Shop for Raspbian rootfs releases here: 
#  https://downloads.raspberrypi.org/raspbian/archive/
#
if(NOT ROOTFS_ARCHIVE_VERSION)
    set(ROOTFS_ARCHIVE_VERSION 2020-02-14-13:48)
endif()

if(NOT ROOTFS_ARCHIVE_MD5)
    set(ROOTFS_ARCHIVE_MD5 922e717dd1f2968e41c9f7c6b17dda13)
endif()

#
# Test Cases
#
option(BUILD_WAYLAND "Build Wayland apps" OFF)
option(BUILD_MRAA "Build MRAA repo" OFF)
