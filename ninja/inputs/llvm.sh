#!/bin/bash
# llvm.sh small|medium|large - configure LLVM with CMake (no build) to get a real build.ninja.
#   small   the runtimes: libc++, libc++abi, libunwind
#   medium  LLVM with one target (AArch64)
#   large   LLVM with clang, lld, mlir and clang-tools-extra, all targets
# The committed results used llvm-project main of 2026-10-20 and cmake 4.4. A configure
# needs a C++ compiler and Python; the large one takes a few minutes and about 2 GB.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
L=$DEPS/llvm-project; D=$INPUTS/ninja/$1
[ -f "$D/build.ninja" ] && exit 0
[ -d "$L/.git" ] || git clone -q --depth 1 https://github.com/llvm/llvm-project "$L"
COMMON=(-G Ninja -DCMAKE_BUILD_TYPE=Release)
case $1 in
  small)  cmake -S "$L/runtimes" -B "$D" "${COMMON[@]}" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;libunwind" ;;
  medium) cmake -S "$L/llvm" -B "$D" "${COMMON[@]}" -DLLVM_TARGETS_TO_BUILD=AArch64 ;;
  large)  cmake -S "$L/llvm" -B "$D" "${COMMON[@]}" -DLLVM_ENABLE_PROJECTS="clang;lld;mlir;clang-tools-extra" ;;
esac
