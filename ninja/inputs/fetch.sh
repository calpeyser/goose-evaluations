#!/bin/bash
# fetch.sh small|medium|large - make the ninja inputs in $INPUTS/ninja/<name>/.
#   gen-<size>  gen_manifest.py with 12 / 160 / 1,800 libraries (seed 1): about 2 / 26 / 300 MB
# The real inputs (small, medium, large) come from CMake on the LLVM source tree; see
# README.md in this folder and llvm.sh. Run it with REAL=1. Their bytes hold absolute
# paths of the machine that made them, so their sha256 differ from ours.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
D=$INPUTS/ninja; mkdir -p "$D"
case $1 in small) n=12 ;; medium) n=160 ;; large) n=1800 ;; esac
[ -f "$D/gen-$1/build.ninja" ] || "$PY" "$ROOT/ninja/inputs/gen_manifest.py" "$D/gen-$1" $n
if [ "${REAL:-0}" = 1 ]; then "$ROOT/ninja/inputs/llvm.sh" "$1"; fi
