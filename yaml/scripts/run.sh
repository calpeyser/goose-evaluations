#!/bin/bash
# run.sh small|medium|large|all - the YAML measurement, for the real inputs (if made) and
# the generated ones:
#   1. every row's output text must equal PyYAML's, byte for byte, at each size;
#   2. bench.py: 1 warm-up and 5 runs per row, rows in turn, checksum lines compared;
#   3. one run per row with the phase timers (stderr);
#   4. the C twin with 144-byte nodes, and the Goose build as one C file, beside Goose.
# Writes $OUT/yaml/results/: verify.txt, bench-<set>.csv and -table.md, phases-<set>.txt.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
B=$OUT/yaml/bin; R=$OUT/yaml/results; mkdir -p "$R"; T=$(mktemp -d)
sizes=$1; [ "$1" = all ] && sizes="small,medium,large"; sizes=${sizes// /,}
ROWS=yamlcpp_row,ryml_row,ryml_reserve_row,yaml_goose,c_twin,floor
rm -f "$R/verify.txt"
for set in real gen; do
  D=$INPUTS/yaml/$set; have=""
  for s in ${sizes//,/ }; do [ -f "$D/$s.expect.json" ] && have="$have,$s"; done
  have=${have#,}; [ -z "$have" ] && continue
  for s in ${have//,/ }; do for r in ${ROWS//,/ } c_twin_pad133 yaml_goose_sa; do [ $r = floor ] && continue
    "$B/$r" "$D/$s.yaml" "$T/v.json" > /dev/null 2>&1 || true
    if cmp -s "$T/v.json" "$D/$s.expect.json"; then echo "verify $set $s $r MATCH"; else echo "verify $set $s $r DIFFERS"; fi
  done; done | tee -a "$R/verify.txt"
  rm -f "$R/bench-$set.csv" "$R/bench-$set-extra.csv"
  TMPDIR=$T YAML_INPUTS=$D "$PY" "$ROOT/yaml/scripts/bench.py" "$R/bench-$set.csv" "$have" $ROWS 5 > "$R/bench-$set.log"
  TMPDIR=$T YAML_INPUTS=$D "$PY" "$ROOT/yaml/scripts/bench.py" "$R/bench-$set-extra.csv" "$have" yaml_goose,c_twin_pad133,yaml_goose_sa 5 > "$R/bench-$set-extra.log"
  "$PY" "$ROOT/yaml/scripts/table.py" "$R/bench-$set.csv" | tee "$R/bench-$set-table.md"
  "$PY" "$ROOT/yaml/scripts/table.py" "$R/bench-$set-extra.csv" > "$R/bench-$set-extra-table.md"
  for s in ${have//,/ }; do for r in ${ROWS//,/ }; do [ $r = floor ] && continue
    echo "$s $r $("$B/$r" "$D/$s.yaml" 2>&1 >/dev/null)"; done; done > "$R/phases-$set.txt"
done
rm -rf "$T"
! grep -q DIFFERS "$R/verify.txt"
