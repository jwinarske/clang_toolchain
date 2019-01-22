cmake_minimum_required(VERSION 3.11)

if(POLICY CMP0068)
  cmake_policy(SET CMP0068 NEW)
  set(CMAKE_BUILD_WITH_INSTALL_NAME_DIR ON)
endif()
if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)
endif()
if(POLICY CMP0051)
  cmake_policy(SET CMP0051 NEW)
endif()
if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)
endif()

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

message(STATUS "Generator .............. ${CMAKE_GENERATOR}")
message(STATUS "Build Type ............. ${CMAKE_BUILD_TYPE}")


option(BUILD_RPI_SYSROOT "Build Raspberry Pi sysroot" OFF)
if(BUILD_RPI_SYSROOT)
    include(rpi.sysroot)
endif()


include (ExternalProject)

if(NOT ANDROID)

    if(NOT TOOLCHAIN_DIR)
        set(TOOLCHAIN_DIR ${CMAKE_SOURCE_DIR}/sdk/toolchain)
    endif()

    set(LLVM_CONFIG_PATH ${TOOLCHAIN_DIR}/bin/llvm-config CACHE PATH "llvm-config path")

    if(NOT TARGET_SYSROOT)
        set(TARGET_SYSROOT ${CMAKE_SOURCE_DIR}/sdk/sysroot)
    endif()

    if(NOT TARGET_TRIPLE)
        set(TARGET_TRIPLE arm-linux-gnueabihf)
    endif()

endif()

set(THIRD_PARTY_DIR ${CMAKE_SOURCE_DIR}/third_party)
set(LLVM_SRC_DIR ${THIRD_PARTY_DIR}/llvm)

if(NOT LLVM_TARGETS_TO_BUILD)
    set(LLVM_TARGETS_TO_BUILD ARM|AArch64|X86)
endif()

if(NOT LLVM_VERSION)
    set(LLVM_VERSION tags/RELEASE_701/final/)
endif()


#
# built for host
#
option(BUILD_LLD "Checkout and build LLVM Linker for host" ON)
option(BUILD_BINUTILS "Download and build binutils for host" ON)
option(BUILD_LLDB "Checkout and build LLVM Debugger for host" OFF)

set(LLVM_CHECKOUT
    cd ${THIRD_PARTY_DIR} &&
    svn co -q http://llvm.org/svn/llvm-project/llvm/${LLVM_VERSION} llvm &&
    cd ${LLVM_SRC_DIR}/tools &&
    svn co -q http://llvm.org/svn/llvm-project/cfe/${LLVM_VERSION} clang)

if(BUILD_LLDB)
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${LLVM_SRC_DIR}/tools &&
        svn co -q http://llvm.org/svn/llvm-project/lldb/${LLVM_VERSION} lldb)
else()
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${LLVM_SRC_DIR}/tools && rm -rf lldb)
endif()

if(BUILD_LLD)
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${LLVM_SRC_DIR}/projects &&
        svn co -q http://llvm.org/svn/llvm-project/lld/${LLVM_VERSION} lld)
else()
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${LLVM_SRC_DIR}/projects && rm -rf lld)
endif()

#
# built for target
#
option(BUILD_COMPILER_RT "Checkout and build compiler-rt" ON)
option(BUILD_LIBCXXABI "Checkout and build libcxxabi for target" ON)
option(BUILD_LIBUNWIND "Checkout and build libunwind for  target" ON)
option(BUILD_LIBCXX "Checkout and build libcxx for target" ON)

if(BUILD_COMPILER_RT)
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} &&
        cd ${THIRD_PARTY_DIR} &&
        svn co -q http://llvm.org/svn/llvm-project/compiler-rt/${LLVM_VERSION} compiler-rt)
else()
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${THIRD_PARTY_DIR} && rm -rf compiler-rt)
endif()

if(BUILD_LIBUNWIND)
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} &&
        cd ${THIRD_PARTY_DIR} &&
        svn co -q http://llvm.org/svn/llvm-project/libunwind/${LLVM_VERSION} libunwind)
else()
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${THIRD_PARTY_DIR} && rm -rf libunwind)
endif()

if(BUILD_LIBCXXABI)
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && 
        cd ${THIRD_PARTY_DIR} &&
        svn co -q http://llvm.org/svn/llvm-project/libcxxabi/${LLVM_VERSION} libcxxabi)
else()
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${THIRD_PARTY_DIR} && rm -rf libcxxabi)
endif()

if(BUILD_LIBCXX)
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} &&
        cd ${THIRD_PARTY_DIR} &&
        svn co -q http://llvm.org/svn/llvm-project/libcxx/${LLVM_VERSION} libcxx)
else()
    set(LLVM_CHECKOUT ${LLVM_CHECKOUT} && cd ${THIRD_PARTY_DIR} && rm -rf libcxx)
endif()

ExternalProject_Add(clang
    DOWNLOAD_COMMAND
        ${CMAKE_COMMAND} -E make_directory ${THIRD_PARTY_DIR} && ${LLVM_CHECKOUT}
    SOURCE_DIR ${LLVM_SRC_DIR}
    UPDATE_COMMAND ""
    BUILD_IN_SOURCE 0
    LIST_SEPARATOR |
    CMAKE_ARGS
        -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN_DIR}
        -DCMAKE_BUILD_TYPE=MinSizeRel
        -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
        -DLLVM_DEFAULT_TARGET_TRIPLE=${TARGET_TRIPLE}
        -DLLVM_TARGETS_TO_BUILD=${LLVM_TARGETS_TO_BUILD}
        -DLLVM_ENABLE_ASSERTIONS=ON
        -DLIBCXX_INSTALL_LIBRARY=OFF
)

if(BUILD_BINUTILS)
    ExternalProject_Add(binutils
        URL http://ftp.gnu.org/gnu/binutils/binutils-2.31.tar.gz
        URL_MD5 2a14187976aa0c39ad92363cfbc06505
        SOURCE_DIR ${THIRD_PARTY_DIR}/binutils
        BUILD_IN_SOURCE 1
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ./configure
            --prefix=${TOOLCHAIN_DIR}
            --target=${TARGET_TRIPLE}
            --enable-gold
            --enable-ld
            --enable-lto
    )
    add_dependencies(binutils clang)
endif()

#
# cross compile for target
#

configure_file(cmake/clang.toolchain.cmake.in ${CMAKE_BINARY_DIR}/toolchain.cmake @ONLY)

if(BUILD_COMPILER_RT)
    ExternalProject_Add(compiler-rt
        DOWNLOAD_COMMAND ""
        PATCH_COMMAND cd ${LLVM_SRC_DIR}/projects/compiler-rt && 
            svn revert cmake/config-ix.cmake && svn patch ${CMAKE_SOURCE_DIR}/cmake/patches/compiler-rt.patch
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ${CMAKE_COMMAND} ${LLVM_SRC_DIR}/projects/compiler-rt
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN_DIR}/lib/clang/9.0.0
            -DCMAKE_BUILD_TYPE=MinSizeRel
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
            -DLLVM_CONFIG_PATH=${LLVM_CONFIG_PATH}
            -DCOMPILER_RT_STANDALONE_BUILD=OFF
            -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=${TARGET_TRIPLE}
            -DCOMPILER_RT_HAS_FPIC_FLAG=ON
            -DCOMPILER_RT_BUILD_XRAY=ON
            -DCOMPILER_RT_BUILD_SANITIZERS=ON
    )
    add_dependencies(compiler-rt clang binutils)
    if(BUILD_SYSROOT)
        add_dependencies(compiler-rt sysroot)
    endif()
endif()

if(BUILD_LIBCXXABI)
    configure_file(cmake/patches/libcxxabi.patch.in ${CMAKE_BINARY_DIR}/libcxxabi.patch @ONLY)
    ExternalProject_Add(libcxxabi
        DOWNLOAD_COMMAND ""
        PATCH_COMMAND cd ${LLVM_SRC_DIR}/projects/libcxxabi && 
            svn revert cmake/config-ix.cmake && svn patch ${CMAKE_BINARY_DIR}/libcxxabi.patch
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ${CMAKE_COMMAND} ${LLVM_SRC_DIR}/projects/libcxxabi
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN_DIR}
            -DCMAKE_BUILD_TYPE=MinSizeRel
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
            -DLLVM_CONFIG_PATH=${LLVM_CONFIG_PATH}
            -DLIBCXXABI_SYSROOT=${TARGET_SYSROOT}
            -DLIBCXXABI_TARGET_TRIPLE=${TARGET_TRIPLE}
            -DLIBCXXABI_ENABLE_SHARED=ON
            -DLIBCXXABI_USE_COMPILER_RT=${BUILD_COMPILER_RT}
            -DLIBCXXABI_USE_LLVM_UNWINDER=${BUILD_LIBUNWIND}
            -DLIBCXXABI_ENABLE_STATIC_UNWINDER=${BUILD_LIBUNWIND}
            -DLIBCXXABI_ENABLE_EXCEPTIONS=OFF
            -DLIBCXXABI_ENABLE_ASSERTIONS=ON
            -DLIBCXXABI_ENABLE_PEDANTIC=ON
    )
    add_dependencies(libcxxabi clang binutils)
    if(BUILD_COMPILER_RT)
        add_dependencies(libcxxabi compiler-rt)
    endif()
    if(BUILD_SYSROOT)
        add_dependencies(libcxxabi sysroot)
    endif()        
endif()

if(BUILD_LIBUNWIND)
    ExternalProject_Add(libunwind
        DOWNLOAD_COMMAND ""
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ${CMAKE_COMMAND} ${CMAKE_BINARY_DIR}/libunwind
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN_DIR}
            -DCMAKE_BUILD_TYPE=MinSizeRel
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
            -DLLVM_CONFIG_PATH=${LLVM_CONFIG_PATH}
            -DLIBUNWIND_STANDALONE_BUILD=OFF
            -DLIBUNWIND_TARGET_TRIPLE=${TARGET_TRIPLE}
            -DLIBUNWIND_SYSROOT=${TARGET_SYSROOT}
            -DLIBUNWIND_USE_COMPILER_RT=${BUILD_COMPILER_RT}
            -DLIBUNWIND_ENABLE_CROSS_UNWINDING=OFF
            -DLIBUNWIND_ENABLE_STATIC=ON
            -DLIBUNWIND_ENABLE_SHARED=OFF
            -DLIBUNWIND_ENABLE_THREADS=ON
    )
    add_dependencies(libunwind clang binutils)
    if(BUILD_COMPILER_RT)
        add_dependencies(libunwind compiler-rt)
    endif()
    if(BUILD_LIBCXXABI AND BUILD_LIBUNWIND)
        add_dependencies(libcxxabi libunwind)
    endif()
    if(BUILD_SYSROOT)
        add_dependencies(libunwind sysroot)
    endif()        
endif()

if(BUILD_LIBCXX)
    ExternalProject_Add(libcxx
        DOWNLOAD_COMMAND ""
        PATCH_COMMAND cd ${LLVM_SRC_DIR}/projects/libcxx && 
            svn revert cmake/config-ix.cmake && svn patch ${CMAKE_SOURCE_DIR}/cmake/patches/libcxx.patch
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CONFIGURE_COMMAND ${CMAKE_COMMAND} ${LLVM_SRC_DIR}/projects/libcxx
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN_DIR}
            -DCMAKE_BUILD_TYPE=MinSizeRel
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
            -DLLVM_CONFIG_PATH=${LLVM_CONFIG_PATH}
            -DLIBCXX_STANDALONE_BUILD=OFF
            -DLIBCXX_SYSROOT=${TARGET_SYSROOT}
            -DLIBCXX_TARGET_TRIPLE=${TARGET_TRIPLE}
            -DLIBCXX_USE_COMPILER_RT=${BUILD_COMPILER_RT}
            -DLIBCXX_ENABLE_SHARED=ON
            -DLIBCXXABI_USE_LLVM_UNWINDER=${BUILD_LIBUNWIND}
            -DLIBCXXABI_ENABLE_STATIC_UNWINDER=${BUILD_LIBUNWIND}
    )
    add_dependencies(libcxx libcxxabi)
    if(BUILD_COMPILER_RT)
        add_dependencies(libcxx compiler-rt)
    endif()
    if(BUILD_SYSROOT)
        add_dependencies(libcxx sysroot)
    endif()        
endif()


set(CXX_LIB_COPY_CMD 
    ${CMAKE_COMMAND} -E copy ${TOOLCHAIN_DIR}/lib/libc++${CMAKE_SHARED_LIBRARY_SUFFIX}.1.0 ${CMAKE_INSTALL_PREFIX}/lib/libc++${CMAKE_SHARED_LIBRARY_SUFFIX}.1 &&
    ${CMAKE_COMMAND} -E copy ${TOOLCHAIN_DIR}/lib/libc++abi${CMAKE_SHARED_LIBRARY_SUFFIX}.1.0 ${CMAKE_INSTALL_PREFIX}/lib/libc++abi${CMAKE_SHARED_LIBRARY_SUFFIX}.1 &&
    chmod +x ${CMAKE_INSTALL_PREFIX}/lib/libc++${CMAKE_SHARED_LIBRARY_SUFFIX}.1 &&
    chmod +x ${CMAKE_INSTALL_PREFIX}/lib/libc++abi${CMAKE_SHARED_LIBRARY_SUFFIX}.1)
