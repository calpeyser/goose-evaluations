#!/bin/bash
# run.sh - the whole suite, as rapidyaml's ryml-bm-run target runs it, on both trees.
# For each repetition and each case: bm_parse then bm_emit, master and branch one after the
# other, with the first tree swapped on every case so neither always goes first. Each run
# writes the json file that the ryml-bm-run target writes: ryml-bm-<parse|emit>-<case>.json.
# The filter is the one bm/CMakeLists.txt uses: a .yml/.yaml case runs only the YAML rows.
set -euo pipefail
source "$(dirname "$0")/env.sh"
C=$WORK/cases; R=$WORK/runs/$RUN
# The emit rows that write files make temporary files in the current folder.
mkdir -p "$WORK/tmp"; cd "$WORK/tmp"
k=0
for rep in $(seq 1 $REPS); do
  for f in $(cat "$C/cases.txt"); do
    case_=${f%%.*}; trees="master grow"
    [ $((k % 2)) = 1 ] && trees="grow master"; k=$((k + 1))
    filter=(); [[ $f == *.json ]] || filter=(--benchmark_filter='ryml_yaml|rymlints_yaml|yaml')
    for t in $trees; do
      d=$R/rep$rep/$t; mkdir -p "$d"
      for cmd in parse emit; do
        "$WT/$t/build-bm/bm/ryml-bm-$cmd" "${filter[@]}" --benchmark_out_format=json \
          --benchmark_out="$d/ryml-bm-$cmd-$case_.json" "$C/$f" > "$d/ryml-bm-$cmd-$case_.log" 2>&1
      done
    done
    echo "$(date -u +%H:%M:%S) rep $rep $f"
  done
done
