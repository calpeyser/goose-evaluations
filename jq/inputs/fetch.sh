#!/bin/bash
# fetch.sh small|medium|large - make the jq inputs in $INPUTS/jq.
#   gh-<s|m|l>.ndjson   the first 291 / 8,677 / 84,850 lines of GH Archive hour 2024-01-15-15
#   gen-<s|m|l>.ndjson  400 / 12,000 / 120,000 events from gen_events.py (seed 12345)
# jaq's own benchmark filters need no file: their input is one number, which bench.py writes.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
D=$INPUTS/jq; mkdir -p "$D"; GH=$INPUTS/dl/2024-01-15-15.json.gz
case $1 in small) s=s; n=291; g=400 ;; medium) s=m; n=8677; g=12000 ;; large) s=l; n=84850; g=120000 ;; esac
[ -f "$D/gh-$s.ndjson" ] || { zcat "$GH" | head -n $n > "$D/gh-$s.ndjson" || true; }
[ -f "$D/gen-$s.ndjson" ] || "$PY" "$ROOT/jq/inputs/gen_events.py" $g > "$D/gen-$s.ndjson"
