#!/bin/bash
# profile.sh [input] - perf record -e cycles:u per row; top symbols to
# $OUT/json/results/profile-<row>-<input>.txt. Rows from ROWS (default "cjson yyjson goose").
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
f=${1:-gharchive-30m}; R=$OUT/json/results; mkdir -p "$R"
for r in ${ROWS:-cjson yyjson goose}; do
  "$PERF" record -q -F 2000 -e cycles:u -o "$R/perf-$r.data" "$OUT/json/bin/bench_$r" "$INPUTS/json/$f.json" > /dev/null 2>&1
  "$PERF" report -i "$R/perf-$r.data" --no-children --sort sym --stdio 2>/dev/null | grep -v '^#' | grep -v '^$' | head -25 > "$R/profile-$r-$f.txt"
done
