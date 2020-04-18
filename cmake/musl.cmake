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

set(MUSL_CONFIG "--with-arch=armv7-a --with-fpu=vfpv3-d16")
#set(MUSL_CONFIG "--with-arch=armv6k --with-fpu=vfpv2")

ExternalProject_Add(musl
    GIT_REPOSITORY git://git.musl-libc.org/musl
    GIT_TAG v1.2.0
    GIT_SHALLOW ON
    BUILD_IN_SOURCE 0
    SOURCE_DIR ${THIRD_PARTY_DIR}/musl
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND
        CC=${LLVM_BIN_DIR}/clang
        AS=${LLVM_BIN_DIR}/llvm-as
        LD=${LLVM_BIN_DIR}/llvm-ld.lld
        AR=${LLVM_BIN_DIR}/llvm-ar
        RANLIB=${LLVM_BIN_DIR}/llvm-ranlib
        NM=${LLVM_BIN_DIR}/llvm-nm
        ${THIRD_PARTY_DIR}/musl/configure
            -static
            --prefix=${TOOLCHAIN_DIR}
            --target=${TARGET_TRIPLE}
            ${MUSL_CONFIG}
)
if(BUILD_BINUTILS)
    add_dependencies(musl binutils)
endif()
if(BUILD_COMPILER_RT)
    add_dependencies(musl compiler-rt)
endif()

