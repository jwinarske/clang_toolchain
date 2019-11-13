
#
# Platform
#
option(BUILD_PLATFORM_SYSROOT "Build Platform sysroot" OFF)
option(BUILD_PLATFORM_RPI "Build Platform Raspberry Pi" OFF)
option(UPDATE_TARGET "Update Target libraries" OFF)

#
# Host
#
option(BUILD_LLD "Checkout and build LLVM Linker for host" ON)
option(BUILD_BINUTILS "Download and build binutils for host" ON)
option(BUILD_LLDB "Checkout and build LLVM Debugger for host" OFF)

#
# Target
#
option(BUILD_COMPILER_RT "Checkout and build compiler-rt" ON)
option(BUILD_LIBCXXABI "Checkout and build libcxxabi for target" ON)
option(BUILD_LIBCXXABI_EXCEPTIONS "c++abi Exceptions" ON)
option(BUILD_LIBCXXABI_ASSERTIONS "c++abi Assertions" ON)
option(BUILD_LIBUNWIND "Checkout and build libunwind for  target" ON)
option(BUILD_LIBCXX "Checkout and build libcxx for target" ON)

#
# Apps
#
option(BUILD_WAYLAND "Build Wayland apps" OFF)
option(BUILD_MRAA "Build MRAA repo" OFF)

#
# Sysroot
#

# Shop for Raspbian rootfs releases here: https://downloads.raspberrypi.org/raspbian/archive/
if(NOT ROOTFS_ARCHIVE_VERSION)
    set(ROOTFS_ARCHIVE_VERSION 2019-09-30-15:24)
endif()

if(NOT ROOTFS_ARCHIVE_MD5)
    set(ROOTFS_ARCHIVE_MD5 766f46bb5d3a223f8a8329393635f175)
endif()
