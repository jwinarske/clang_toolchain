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

option(BUILD_APP_HELLO_WAYLAND "Build hello-wayland app" ON)
if(BUILD_APP_HELLO_WAYLAND)

    ExternalProject_Add(hello_wayland
        GIT_REPOSITORY https://github.com/emersion/hello-wayland.git
        GIT_TAG master
        GIT_SHALLOW ON
        PATCH_COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_SOURCE_DIR}/cmake/wayland/hello_wayland.cmake
            ${CMAKE_BINARY_DIR}/hello_wayland-prefix/src/hello_wayland/CMakeLists.txt
        BUILD_IN_SOURCE 0
        UPDATE_COMMAND ""
        CMAKE_ARGS
            -DCMAKE_TOOLCHAIN_FILE=${CMAKE_BINARY_DIR}/target.toolchain.cmake
            -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/target
            -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
            -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}
    )
    if(BUILD_BINUTILS)
        add_dependencies(hello_wayland binutils)
    endif()
    if(BUILD_COMPILER_RT)
        add_dependencies(hello_wayland compiler-rt)
    endif()

endif()
