
#
# Platform
#
option(BUILD_PLATFORM_SYSROOT "Build Platform sysroot" OFF)
option(BUILD_PLATFORM_RPI "Build Platform Raspberry Pi" OFF)

option(BUILD_WAYLAND "Build expecting wayland-protocols, wayland-client, etc in sysroot" OFF)

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
option(BUILD_LIBUNWIND "Checkout and build libunwind for  target" ON)
option(BUILD_LIBCXX "Checkout and build libcxx for target" ON)
