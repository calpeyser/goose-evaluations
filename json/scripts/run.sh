#!/bin/bash
# run.sh small|medium|large|all - every JSON row on the inputs of that size, then the table.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
case $1 in
  small) F="twitter citm_catalog canada gharchive-1m gen-500" ;;
  medium) F="gharchive-30m gen-14000" ;;
  large) F="gharchive-300m gen-140000" ;;
  all) F="twitter citm_catalog canada gharchive-1m gharchive-30m gharchive-300m gen-500 gen-14000 gen-140000" ;;
esac
tsv=$(ROWS="cjson yyjson goose goose_nocheck goose_fast goose_view" FILES="$F" "$ROOT/json/scripts/bench.sh" | tee /dev/stderr | tail -1)
"$PY" "$ROOT/json/scripts/table.py" "$tsv" | tee "${tsv%.tsv}-table.md"
