#!/bin/bash
# nocheck.sh [json] - a test version, not a row: build goose/json.goose with the bounds-check
# macro GS_IDX replaced by the bare index, to measure what the kept checks cost.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
n=${1:-json}; B=$OUT/json/bin; T=$OUT/json/nocheck; mkdir -p "$B" "$T"
cd "$ROOT/json/goose"
# The gcc line that `goose build` would run, with the generated C swapped for an edited copy.
cmd=$("$GOOSE" build $n.goose -O2 --cc gcc -o OUT --dry-run 2>&1 | grep -E '^/usr/bin/gcc .* -o OUT ')
c=$(echo "$cmd" | grep -oE '[^ "]*/'$n'\.c')
"$GOOSE" build $n.goose -O2 --cc gcc -o "$T/tmp" > /dev/null 2>&1   # writes the C, the run-time object and the shim
sed -e '/^#define GS_IDX(i, n, f, l)/,/^$/c\#define GS_IDX(i, n, f, l) (i)\n' "$c" > "$T/${n}_nocheck.c"
grep -q '#define GS_IDX(i, n, f, l) (i)' "$T/${n}_nocheck.c"
eval "$(echo "${cmd//$c/$T/${n}_nocheck.c}" | sed "s| -o OUT | -o $B/bench_goose_nocheck |")"
echo "built $B/bench_goose_nocheck"
