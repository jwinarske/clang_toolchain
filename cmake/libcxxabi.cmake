    SET(LIBCXXABI_C_FLAGS ${TARGET_CONFIG})
    SET(LIBCXXABI_CXX_FLAGS "${TARGET_CONFIG}")
    SET(LIBCXXABI_LINKER_FLAGS "-nostdlib -fuse-ld=lld")

    ExternalProject_Add(libcxxabi
        DOWNLOAD_COMMAND ""
        SOURCE_DIR ${LLVM_SRC_DIR}
        SOURCE_SUBDIR libcxxabi
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CMAKE_ARGS
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${TOOLCHAIN_DIR}
            -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_C_FLAGS=${LIBCXXABI_C_FLAGS}
            -DCMAKE_CXX_FLAGS=${LIBCXXABI_CXX_FLAGS}
            -DCMAKE_SHARED_LINKER_FLAGS=${LIBCXXABI_LINKER_FLAGS}
            -DLLVM_COMPILER_CHECKED=ON
            -DLLVM_PATH=${LLVM_SRC_DIR}/llvm
            -DLLVM_CONFIG_PATH=${LLVM_CONFIG_PATH}
            -DLLVM_ENABLE_PER_TARGET_RUNTIME_DIR=OFF
            -DLIBCXXABI_STANDALONE_BUILD=OFF
            -DLIBCXXABI_LIBCXX_PATH=${LLVM_SRC_DIR}/libcxx/include
            -DLIBCXXABI_TARGET_TRIPLE=${TARGET_TRIPLE}
            -DLIBCXXABI_SYSROOT=${TOOLCHAIN_DIR}
            -DLIBCXXABI_USE_COMPILER_RT=ON
            -DLIBCXXABI_INCLUDE_TESTS=ON
            -DLIBCXXABI_USE_LLVM_UNWINDER=ON
    )
    add_dependencies(libcxxabi clang)
    add_dependencies(libcxxabi libunwind)
    if(BUILD_PLATFORM_SYSROOT)
        add_dependencies(libcxxabi sysroot)
    endif()
