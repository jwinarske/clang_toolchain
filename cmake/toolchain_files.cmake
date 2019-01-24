
set(LLVM_CONFIG ${LLVM_CONFIG_PATH} CACHE PATH "llvm-config path")

include(llvm_config)


configure_file(cmake/clang.toolchain.cmake.in ${CMAKE_BINARY_DIR}/toolchain.cmake @ONLY)

configure_file(cmake/app.clang.toolchain.cmake.in ${CMAKE_BINARY_DIR}/app.clang.toolchain.cmake @ONLY)