#!/bin/bash
# plot.sh - run rapidyaml's bm/bm_plot_rapidyaml.py on each tree's median results, exactly as the
# ryml-bm-plot target runs it: once per case for parse and for emit, then 'scatter' over the folder.
# Output: $WORK/plot/$RUN/<tree>/bm-results/*.png (and the .md, .txt, .html the script also writes).
set -euo pipefail
source "$(dirname "$0")/env.sh"
P=$WT/master/bm/bm_plot_rapidyaml.py
for t in ${TREES:-master grow}; do
  D=$WORK/plot/$RUN/$t/bm-results; rm -rf "$D"; mkdir -p "$D"
  cp "$SUITE/results/$RUN/$t"/*.json "$D/"
  for f in $(cat "$WORK/cases/cases.txt"); do
    c=${f%%.*}
    for cmd in parse emit; do
      "$PYBM" "$P" $cmd "$c" "$WORK/cases/$f" "$D/ryml-bm-$cmd-$c.json" > "$D/plot-$cmd-$c.log" 2>&1
    done
  done
  # The scatter charts use only rapidyaml's own bm/cases. On the multi-document streams we added,
  # yaml-cpp reads only the first document and libfyaml stops at an error, so their points there
  # would be far off the chart.
  for cmd in parse emit; do
    "$PYBM" -c 'import sys, os, yaml
f, keep = sys.argv[1], set(open(sys.argv[2]).read().split())
d = [e for e in yaml.safe_load(open(f)) if os.path.basename(e["path"]) in keep]
yaml.safe_dump(d, open(f, "w"))' "$D/ryml-bm-$cmd-scatter-_specs.yml" "$WT/master/bm/cases/bm-cases.txt"
  done
  "$PYBM" "$P" scatter "$D" > "$D/plot-scatter.log" 2>&1
done
