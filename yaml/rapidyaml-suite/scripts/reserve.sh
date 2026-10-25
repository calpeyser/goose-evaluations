#!/bin/bash
# reserve.sh - bm_ryml_yaml_inplace_reserve on medium.yaml with the reserve inside the timer,
# for both trees (reserve_then_parse.cpp, median of 21). Uses each tree's libryml.a from build.sh.
set -euo pipefail
source "$(dirname "$0")/env.sh"
for t in master grow; do
  S=$WT/$t; B=$S/build-bm
  g++ -O3 -DNDEBUG -std=c++17 -I"$S/src" -I"$S/ext/c4core.src" -I"$B/src" "$(dirname "$0")/reserve_then_parse.cpp" \
    "$B/libryml.a" -o "$WORK/reserve_then_parse_$t"
done
for t in master grow master grow; do echo "$t: $("$WORK/reserve_then_parse_$t" "$WORK/cases/medium.yaml")"; done
