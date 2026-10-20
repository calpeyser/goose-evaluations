#!/bin/bash
# fetch.sh small|medium|large - make the JSON inputs in $INPUTS/json.
#   small   twitter, citm_catalog, canada (nativejson-benchmark), gharchive-1m, gen-500
#   medium  gharchive-30m, gen-14000
#   large   gharchive-300m, gen-140000
# gharchive-N: the first K events of GH Archive hour 2024-01-15-15, as one JSON array:
# "[" + the event lines joined by ",\n" + "]\n". gen-N: N events from gen_events.c.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
D=$INPUTS/json; mkdir -p "$D"; GH=$INPUTS/dl/2024-01-15-15.json.gz
gh() {  # gh <name> <events>
  [ -f "$D/$1.json" ] || "$PY" -c '
import gzip, sys
n = int(sys.argv[2]); lines = []
with gzip.open(sys.argv[1], "rb") as f:
    for l in f:
        if len(lines) == n: break
        lines.append(l.rstrip(b"\n"))
open(sys.argv[3], "wb").write(b"[" + b",\n".join(lines) + b"]\n")' "$GH" "$2" "$D/$1.json"
}
gen() { [ -f "$D/gen-$1.json" ] || "$OUT/json/bin/gen_events" "$1" > "$D/gen-$1.json"; }
case $1 in
  small)
    for f in twitter citm_catalog canada; do
      [ -f "$D/$f.json" ] || curl -fsSL -o "$D/$f.json" "https://raw.githubusercontent.com/miloyip/nativejson-benchmark/$NATIVEJSON_COMMIT/data/$f.json"
    done
    gh gharchive-1m 282; gen 500 ;;
  medium) gh gharchive-30m 8254; gen 14000 ;;
  large) gh gharchive-300m 80701; gen 140000 ;;
esac
