#!/bin/bash
# run.sh small|medium|large|all - time the three rows on the inputs of that size that exist
# (gen-<size>, and <size> if the real file was made), in both modes. Writes
# $OUT/ninja/results/bench-<mode>.json and .md.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
sizes=$1; [ "$1" = all ] && sizes="small medium large"
ins=""; for s in $sizes; do for n in $s gen-$s; do [ -f "$INPUTS/ninja/$n/build.ninja" ] && ins="$ins $n"; done; done
mkdir -p "$OUT/ninja/results"
for mode in full load; do
  "$PY" "$ROOT/ninja/scripts/bench.py" --mode $mode $ins | tee "$OUT/ninja/results/bench-$mode.md"
done
