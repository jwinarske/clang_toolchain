# clang_toolchain

This repo is used to build a Clang toolchain, sysroot, libcxxabi, and libcxx.  The default sysroot created is the latest Raspbian rootfs.  The default triple is arm-linux-gnueabihf.  These defaults are overridable, for use with other sysroots, such as a Yocto SDK.

# Project Status

Builds tested on Trusty, Xenial, and Bionic.

## Travis-CI

Builds fail, due to log size exceeding max.

## Raspbian rootfs

The rootfs used is https://downloads.raspberrypi.org/raspbian/archive/2018-11-15-21:02/root.tar.xz

This can be overriden with

    -DRASPBIAN_ROOTFS_VERSION=2018-10-11-11:37

Note: When you override with a different version there may/will be other symlinks that need fixing up.

# Pre-requisites

1. CMake 3.11 or greater

## Build Reference

    .travis.yml