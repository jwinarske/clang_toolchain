# clang_toolchain

This repo is used to build a Clang toolchain, sysroot, compiler-rt, libcxxabi, and libcxx.

The default sysroot created is the latest Raspbian rootfs.

The default triple is arm-linux-gnueabihf.

These defaults are overridable, for use with other sysroots, such as a Yocto SDK.

# Project Status

Tested with GCC (Trusty, Xenial, and Bionic), and Clang (macOS Mojave).  Sysroot install step will fail on Windows native, should work on Cygwin or Mingw.

## Travis-CI

[![Build Status](https://travis-ci.com/jwinarske/clang_toolchain.svg?branch=master)](https://travis-ci.com/jwinarske/clang_toolchain)

Note:  If you don't have a commercial account, your travis build will fail due to the build time exceeding max.  If you *do* have a commercial account, you will need to request a max build time setting of 180 minutes.

# Build Prerequisites

1. CMake 3.11 or greater

2. Host capable of building something

        sudo apt-get update
        sudo apt install gcc clang build-essentials make subversion texinfo bison flex

    Alternatively install LLVM/Clang

3.  sysroot generation uses rsync, or ln, tar, and curl.

## Build Example

    mkdir -p ~/git && cd ~/git
    git clone https://github.com/jwinarske/clang_toolchain.git
    cd clang_toolchain && mkdir build && cd build
    cmake .. -DTARGET_TRIPLE=arm-none-eabi -DTARGET_SYSROOT=/home/joel/sdk/gcc-arm-none-eabi-8-2018-q4-major
    make -j$(numproc)

## Notes
When passing path values to CMake use aboslute paths

If you want to force a rebuild of a sub-project, either delete the specific folder from your build folder, or delete to appropriate flags from the sub projects build folder.

## Cross compiling for RaspberryPi (armhf raspbian)

#### Build 7.0.1 Toolchain, populate sysroot from target via rsync, and build MRAA
    -DLLVM_TARGETS_TO_BUILD="ARM"
    -DBUILD_PLATFORM_RPI=ON
    -DTARGET_HOSTNAME=pi@raspberrypi.local
    -DBUILD_MRAA=ON

#### Build 8.0.0 rc2 Toolchain, create sysroot from official rootfs, build MRAA, and specify sdk folder
    -DLLVM_VERSION=tags/RELEASE_800/rc2/
    -DLLVM_VER_DIR=8.0.0
    -DBUILD_PLATFORM_RPI=ON
    -DBUILD_PLATFORM_SYSROOT=ON
    -DBUILD_MRAA=ON
    -DSDK_ROOT_DIR=/home/joel/rpi
    -DTOOLCHAIN_FILE_DIR=/home/joel/rpi/sdk/build/cmake

#### Build 8.0.0 rc2 Toolchain, populate sysroot from target via rsync, and build MRAA
    -DLLVM_TARGETS_TO_BUILD="ARM"
    -DBUILD_PLATFORM_RPI=ON
    -DTARGET_HOSTNAME=pi@raspberrypi.local
    -DBUILD_MRAA=ON
    -DLLVM_VERSION=tags/RELEASE_800/rc2/
    -DLLVM_VER_DIR=8.0.0

### Cross compiling for AtomicPi (x86_64 lubuntu)

#### Build 7.0.1 Toolchain, populate sysroot from target via rsync, and build MRAA
    -DTARGET_ARCH=x86_64
    -DTARGET_TRIPLE=x86_64-linux-gnu
    -DLLVM_TARGETS_TO_BUILD="X86" -DTARGET_HOSTNAME=atomic@atomicpi.local
    -DBUILD_MRAA=ON

#### Build 8.0.0 rc2 Toolchain, populate sysroot from target via rsync, and build MRAA
    -DTARGET_ARCH=x86_64
    -DTARGET_TRIPLE=x86_64-linux-gnu
    -DLLVM_TARGETS_TO_BUILD="X86" -DTARGET_HOSTNAME=atomic@atomicpi.local
    -DBUILD_MRAA=ON
    -DLLVM_VERSION=tags/RELEASE_800/rc2/
    -DLLVM_VER_DIR=8.0.0

#### Sequence to build 7.0.1 Toolchain, populate sysroot from target, build hello-wayland, push to target, and execute
    ssh atomic@atomicpi.local
    sudo apt-get install wayland-protocols libwayland-dev
    exit
    mkdir -p ~/git && cd ~/git
    git clone https://github.com/jwinarske/clang_toolchain.git
    cd clang_toolchain && mkdir build && cd build
    cmake .. -DTARGET_ARCH=x86_64 -DTARGET_TRIPLE=x86_64-linux-gnu -DTARGET_HOSTNAME=atomic@atomicpi.local -DBUILD_WAYLAND=ON
    make -j$(nproc)
    scp ./target/bin/hello_wayland atomic@atomicpi.local:/home/atomicpi
    ssh atomic@atomicpi.local
    ./hello-wayland

## CMake Build options

#### BUILD_PLATFORM_RPI
Build Platform Raspberry Pi

#### BUILD_PLATFORM_SYSROOT
Build Platform sysroot.  This currently only affects RPI.  You either provide your own, or create from scratch.

#### BUILD_WAYLAND
Build hello-wayland app

#### BUILD_LLD
Checkout and build LLVM Linker for host.  Defaults to ON

#### BUILD_BINUTILS
Download and build binutils for host.  Defaults to OFF

#### BUILD_LLDB
Checkout and build LLVM Debugger for host.  Defaults to OFF.  Enables use of -fuse-ld=gold

#### BUILD_COMPILER_RT
Checkout and build compiler-rt.  Defaults to ON

#### BUILD_LIBCXXABI
Checkout and build libcxxabi for target.  Defaults to ON

#### BUILD_LIBCXXABI_ENABLE_EXCEPTIONS
Build c++abi with exception support  Defaults to ON

#### BUILD_LIBUNWIND
Checkout and build libunwind for  target.  Defaults to ON

#### BUILD_LIBCXX
Checkout and build libcxx for target.  Defaults to ON

## CMake variables

#### RASPBIAN_ROOTFS_URL
Defaults to http://director.downloads.raspberrypi.org/raspbian/archive/

#### RASPBIAN_ROOTFS_VERSION
Defaults to 2018-11-15-21:02

Note: When changing this you may need to adjust dangling/missing symlinks specific to selected version.  See cmake/rpi/sysroot.cmake

#### THIRD_PARTY_DIR
Defaults to ${CMAKE_SOURCE_DIR}/third_party

#### SDK_ROOT_DIR
Defaults to ${CMAKE_SOURCE_DIR}

#### TOOLCHAIN_FILE_DIR
Defaults to ${CMAKE_BINARY_DIR}

#### TOOLCHAIN_DIR
Defaults to ${SDK_ROOT_DIR}/sdk/toolchain

#### TARGET_SYSROOT
Defaults to ${SDK_ROOT_DIR}/sdk/sysroot

#### TARGET_TRIPLE
Defaults to arm-linux-gnueabihf

#### CMAKE_VERBOSE_MAKEFILE
Defaults to OFF.  This variable affects all subprojects.  Alternatively use: 

    make VERBOSE=1

#### LLVM_TARGETS_TO_BUILD
Defaults to X86|ARM|AArch64.  One example setting would be

    -DLLVM_TARGETS_TO_BUILD="ARM"

Note: This only affects LLVM/Clang (host), not target builds; compiler-rt, libunwind, libcxxabi, and libcxx.

Regardless of this value, the LLVM/Clang build as a minimum will build support for the host triple.

#### LLVM_VERSION
Defaults to tags/RELEASE_701/final/

Some examples

    -DLLVM_VERSION=trunk/
    -DLLVM_VERSION=tags/RELEASE_800/rc1/
    -DLLVM_VERSION=branches/release_80/

Note: LLVM_VER_DIR needs to match selected version, in order for compiler-rt to install into the proper location.

#### LLVM_VER_DIR
Defaults to 7.0.1.  This must match LLVM version, or use of compiler-rt will fail, as library will not be found.  This variable is only used for installation of compiler-rt libraries.

## Target Triple (1)

The triple has the general format `<arch><sub>-<vendor>-<sys>-<abi>`, where:

        arch = x86_64, i386, arm, thumb, mips, etc.
        sub = for ex. on ARM: v5, v6m, v7a, v7m, etc.
        vendor = pc, apple, nvidia, ibm, etc.
        sys = none, linux, win32, darwin, cuda, etc.
        abi = eabi, gnu, android, macho, elf, etc.

The sub-architecture options are available for their own architectures, of course, so "x86v7a" doesn’t make sense. The vendor needs to be specified only if there’s a relevant change, for instance between PC and Apple. Most of the time it can be omitted (and Unknown) will be assumed, which sets the defaults for the specified architecture. The system name is generally the OS (linux, darwin), but could be special like the bare-metal “none”.

When a parameter is not important, it can be omitted, or you can choose unknown and the defaults will be used. If you choose a parameter that Clang doesn’t know, like blerg, it’ll ignore and assume unknown, which is not always desired, so be careful.

# References
(1) https://clang.llvm.org/docs/CrossCompilation.html
