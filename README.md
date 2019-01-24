# clang_toolchain

This repo is used to build a Clang toolchain, sysroot, libcxxabi, and libcxx.  The default sysroot created is the latest Raspbian rootfs.  The default triple is arm-linux-gnueabihf.  These defaults are overridable, for use with other sysroots, such as a Yocto SDK.

# Project Status

Builds tested on Trusty, Xenial, and Bionic.

## Travis-CI

[![Build Status](https://travis-ci.com/jwinarske/clang_toolchain.svg?branch=master)](https://travis-ci.com/jwinarske/clang_toolchain)

Note:  If you don't have a commercial account, your travis build will fail due to the build time exceeding max.

## Raspbian rootfs

The rootfs used is https://downloads.raspberrypi.org/raspbian/archive/2018-11-15-21:02/root.tar.xz

This can be overriden with

    -DRASPBIAN_ROOTFS_VERSION=2018-10-11-11:37

Note: When you override with a different version there may/will be other symlinks that need fixing up.

# Pre-requisites

1. CMake 3.11 or greater

## Build Reference

    .travis.yml

## Target Triple (1)

The triple has the general format `<arch><sub>-<vendor>-<sys>-<abi>`, where:

        arch = x86_64, i386, arm, thumb, mips, etc.
        sub = for ex. on ARM: v5, v6m, v7a, v7m, etc.
        vendor = pc, apple, nvidia, ibm, etc.
        sys = none, linux, win32, darwin, cuda, etc.
        abi = eabi, gnu, android, macho, elf, etc.

The sub-architecture options are available for their own architectures, of course, so "x86v7a" doesn’t make sense. The vendor needs to be specified only if there’s a relevant change, for instance between PC and Apple. Most of the time it can be omitted (and Unknown) will be assumed, which sets the defaults for the specified architecture. The system name is generally the OS (linux, darwin), but could be special like the bare-metal “none”.

When a parameter is not important, it can be omitted, or you can choose unknown and the defaults will be used. If you choose a parameter that Clang doesn’t know, like blerg, it’ll ignore and assume unknown, which is not always desired, so be careful.

## LLVM_TARGETS_TO_BUILD ARM

This is a list seperated by the pipe symbol '|'.  The default value is 'ARM'.

This variable setting would build LLVM/Clang that could cross-compile for machine types ARM, AArch64, x86:

    -DLLVM_TARGETS_TO_BUILD=ARM|AArch64|X86

LLVM by default always supports the host config.

# References
(1) https://clang.llvm.org/docs/CrossCompilation.html
