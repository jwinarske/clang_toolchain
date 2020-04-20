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
option(BUILD_CLANG_TOOLS_EXTRA "Build Clang Tools Extra" ON)
option(BUILD_COMPILER_RT "Build compiler-rt" ON)
option(BUILD_LIBCLC "Build libclc" ON)
option(BUILD_LIBCXX "Build libcxx" ON) # cxxabi is built and linked with libcxx project build
option(BUILD_LIBCXXABI "Build libcxxabi" OFF) # cxxabi is built and linked with libcxx project build
option(BUILD_LIBCXXABI_EXCEPTIONS "c++abi Exceptions" OFF)
option(BUILD_LIBCXXABI_ASSERTIONS "c++abi Assertions" OFF)
option(BUILD_LIBUNWIND "Build libunwind" ON)
option(BUILD_LLD "Build lld Linker" ON)
option(BUILD_LLDB "Build LLVM Debugger" OFF)
option(BUILD_LLGO "Build llgo project" OFF)
option(BUILD_MLIR "Build mlir project" OFF)
option(BUILD_OPENMP "Build OpenMP support" ON)
option(BUILD_PARALLEL_LIBS "Build Parallel Libs supprt" ON)
option(BUILD_POLLY "Build Polly supprt" ON)
option(BUILD_PSTL "Build Parallel STL support" ON)

#
# Binutils
#
option(BUILD_BINUTILS "Download and build binutils for host" ON)

#
# C Libraries
#
option(BUILD_MUSL_CLIB "Musl C library" OFF)
option(BUILD_NEWLIB_CLIB "Newlib C library" OFF)


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
