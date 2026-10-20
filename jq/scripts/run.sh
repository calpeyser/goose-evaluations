#!/bin/bash
# run.sh small|medium|large|all - every jq case of that size (real GitHub events, generated
# events, jaq's own filters, and start-up), then peak memory and the table.
# Writes $OUT/jq/results/bench.json, bench.log and bench-table.md.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
case $1 in small) z=s ;; medium) z=m ;; large) z=l ;; all) z=sml ;; esac
R=$OUT/jq/results; mkdir -p "$R"; rm -f "$R/bench.json"
BENCH_SIZES=$z "$PY" "$ROOT/jq/scripts/bench.py" "$R/bench.json" | tee "$R/bench.log"
"$PY" "$ROOT/jq/scripts/rss.py" "$R/bench.json" > "$R/rss.log"
"$PY" "$ROOT/jq/scripts/table.py" "$R/bench.json" | tee "$R/bench-table.md"
! grep -q FAIL "$R/bench.log"
