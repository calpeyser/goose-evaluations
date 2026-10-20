#!/bin/bash
# Where the time goes: profile.sh <case-label> '<filter>' <input-file>
# perf record -F 2000 -e cycles:u on each harness row, then the top 15 symbols by self time.
# Writes $OUT/jq/results/profile/<case-label>.txt.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
O=$OUT/jq/results/profile; mkdir -p "$O"
for row in harness_jq harness_jaq jqg; do
  "$PERF" record -q -F 2000 -e cycles:u -o "$O/$1-$row.data" -- "$OUT/jq/bin/$row" "$2" < "$3" > /dev/null
  echo "== $1 $row"
  "$PERF" report -q -i "$O/$1-$row.data" --no-children --sort symbol --percent-limit 1.5 2>/dev/null | head -15
done > "$O/$1.txt" 2>&1
cat "$O/$1.txt"
