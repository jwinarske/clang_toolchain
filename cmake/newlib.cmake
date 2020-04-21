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

if(NOT BUILD_NEWLIB_CFG)
    set(BUILD_NEWLIB_CFG STD)
endif()

MESSAGE(STATUS "Using newlib config = ${BUILD_NEWLIB_CFG}")

if(BUILD_NEWLIB_CFG MATCHES "STD")

    set(NEWLIB_CONFIG
        --enable-newlib-io-long-long
        --enable-newlib-register-fini
        --enable-newlib-retargetable-locking
        --disable-newlib-supplied-syscalls
        --disable-nls
    )

elseif(BUILD_NEWLIB_CFG MATCHES "NANO")

    set(NEWLIB_CONFIG
        --enable-newlib-supplied-syscalls 
        --enable-newlib-reent-small 
        --disable-newlib-fvwrite-in-streamio 
        --disable-newlib-fseek-optimization 
        --disable-newlib-wide-orient 
        --enable-newlib-nano-malloc 
        --disable-newlib-unbuf-stream-opt 
        --enable-lite-exit 
        --enable-newlib-global-atexit 
        --enable-newlib-nano-formatted-io 
        --disable-nls
    )

endif()

ExternalProject_Add(newlib
    GIT_REPOSITORY git://sourceware.org/git/newlib-cygwin.git
    GIT_TAG newlib-3.3.0
    GIT_SHALLOW ON
    PATCH_COMMAND ${NEWLIB_PATCH}
    BUILD_IN_SOURCE 1
    SOURCE_DIR ${THIRD_PARTY_DIR}/newlib
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND
        CC=${LLVM_BIN_DIR}/clang
        AS=${LLVM_BIN_DIR}/llvm-as
        AR=${LLVM_BIN_DIR}/llvm-ar
        RANLIB=${LLVM_BIN_DIR}/llvm-ranlib
        NM=${LLVM_BIN_DIR}/llvm-nm
        LDFLAGS=-fuse-ld=lld
        ${THIRD_PARTY_DIR}/newlib/configure
            --prefix=${TOOLCHAIN_DIR}
            --target=${TARGET_TRIPLE}
            --sysroot${TOOLCHAIN_DIR}
            --enable-wrapper=clang
            --disable-gcc-wrapper
            --enable-static
            --enable-shared
            ${NEWLIB_CONFIG}
)
