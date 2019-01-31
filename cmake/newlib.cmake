
option(BUILD_NEWLIB "Checkout and build newlib" OFF)
if(NOT BUILD_NEWLIB_CFG)
    set(BUILD_NEWLIB_CFG STD)
endif()

if(${TARGET_TRIPLE} MATCHES "arm-none-eabi")
    set(NEWLIB_PATCH
        git checkout libgloss/arm/Makefile.in &&
        git apply ${CMAKE_SOURCE_DIR}/cmake/patches/newlib/libgloss.arm.makefile.patch &&
        git checkout libgloss/libnosys/configure.in &&
        git apply ${CMAKE_SOURCE_DIR}/cmake/patches/newlib/libgloss.libnosys.configure.patch
    )
else()
    set(NEWLIB_PATCH)
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
    GIT_TAG newlib-3.0.0
    GIT_SHALLOW true
    PATCH_COMMAND ${NEWLIB_PATCH}
    BUILD_IN_SOURCE 0
    SOURCE_DIR ${THIRD_PARTY_DIR}/newlib
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND
        CC_FOR_TARGET=${LLVM_BIN_DIR}/clang
        AS_FOR_TARGET=${LLVM_BIN_DIR}/${TARGET_TRIPLE}-as
        LD_FOR_TARGET=${LLVM_BIN_DIR}/llvm-ld.lld
        AR_FOR_TARGET=${LLVM_BIN_DIR}/llvm-ar
        RANLIB_FOR_TARGET=${LLVM_BIN_DIR}/llvm-ranlib
        NM_FOR_TARGET=${LLVM_BIN_DIR}/llvm-nm
        ${THIRD_PARTY_DIR}/newlib/configure
            --prefix=${TOOLCHAIN_DIR}
            --target=${TARGET_TRIPLE}
            ${NEWLIB_CONFIG}
)
