
ExternalProject_Add(llvm-project
    GIT_REPOSITORY https://github.com/llvm/llvm-project
    GIT_TAG ${LLVM_GIT_TAG}
    GIT_SHALLOW ON
    SOURCE_DIR ${LLVM_SRC_DIR}
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
)
