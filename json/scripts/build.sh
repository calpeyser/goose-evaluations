#!/bin/bash
# Build the JSON rows into $OUT/json/bin, all with gcc -O2:
#   bench_cjson, bench_yyjson  the harness around each library (compiled in from the pinned source)
#   bench_goose                goose/json.goose
#   bench_goose_<v>            the test versions: fast, view, purefloat, and nocheck (no index checks)
#   gen_events                 the input generator
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
H=$ROOT/json; B=$OUT/json/bin; mkdir -p "$B"
fetch_repo cJSON DaveGamble/cJSON "$CJSON_COMMIT"
fetch_repo yyjson ibireme/yyjson "$YYJSON_COMMIT"
gcc -O2 -I"$H/baselines" -I"$DEPS/cJSON" -o "$B/bench_cjson" "$H/baselines/bench_cjson.c" "$DEPS/cJSON/cJSON.c" -lm
gcc -O2 -I"$H/baselines" -I"$DEPS/yyjson/src" -o "$B/bench_yyjson" "$H/baselines/bench_yyjson.c" "$DEPS/yyjson/src/yyjson.c"
gcc -O2 -o "$B/gen_events" "$H/inputs/gen_events.c"
cd "$H/goose"
"$GOOSE" build json.goose -O2 --cc gcc -o "$B/bench_goose"
for v in fast view purefloat; do "$GOOSE" build json_$v.goose -O2 --cc gcc -o "$B/bench_goose_$v"; done
"$H/scripts/nocheck.sh" json
echo "json rows built: cJSON $(git -C "$DEPS/cJSON" rev-parse --short HEAD), yyjson $(git -C "$DEPS/yyjson" rev-parse --short HEAD), goose $(git -C "$DEPS/goose" rev-parse --short HEAD)"
