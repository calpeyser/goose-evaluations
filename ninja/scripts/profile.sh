#!/bin/bash
# Where the time goes: perf record (user cycles) of each row on one input, then the top
# symbols and the share of each shared object. Usage: profile.sh [input] [full|load]
# Writes $OUT/ninja/results/profile-<input>-<mode>-<row>.txt.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
IN=${1:-large}; MODE=${2:-full}; R=$OUT/ninja/results; mkdir -p "$R"
ARGS="build.ninja"; [ "$MODE" = load ] && ARGS="build.ninja load"
cd "$INPUTS/ninja/$IN"
for r in ninja_harness n2_harness goose_load; do
  "$PERF" record -q -F 4000 -e cycles:u -o "$R/$r.perf.data" "$OUT/ninja/bin/$r" $ARGS > /dev/null 2>&1
  {
    echo "## $r on $IN ($MODE)"
    echo "### by shared object"
    "$PERF" report -i "$R/$r.perf.data" --stdio --no-children --sort dso 2>/dev/null | grep -v '^#' | grep -v '^$' | head -8
    echo "### top symbols"
    "$PERF" report -i "$R/$r.perf.data" --stdio --no-children --sort sym 2>/dev/null | grep -v '^#' | grep -v '^$' | head -25
  } > "$R/profile-$IN-$MODE-$r.txt"
done
