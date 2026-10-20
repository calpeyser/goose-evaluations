#!/bin/bash
# real.sh - make the real inputs in $INPUTS/yaml/real: small (the first 271 files),
# medium (all 8,925 files) and large (medium 8 times), with their expected text.
# It fetches only the .yaml and .yml files of three repositories at fixed commits, then
# joins the files that PyYAML, yaml-cpp and rapidyaml read the same way, as recorded in
# ../results/agree-baselines.tsv. With CLASSIFY=1 it also runs the classifier and the
# agreement check again (that needs the rows built) and writes them to $OUT/yaml.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
H=$ROOT/yaml; R=$INPUTS/yaml/repos; D=$INPUTS/yaml/real; mkdir -p "$R" "$D"
[ -f "$D/large.expect.json" ] && exit 0
sparse() {  # sparse <dir> <owner/name> <commit>: only the YAML files, without other blobs
  local d=$R/$1
  [ -d "$d/.git" ] && return
  git init -q "$d"; git -C "$d" remote add origin "https://github.com/$2"
  git -C "$d" sparse-checkout set --no-cone '*.yaml' '*.yml'
  git -C "$d" fetch -q --depth 1 --filter=blob:none origin "$3"
  git -C "$d" -c advice.detachedHead=false checkout -q FETCH_HEAD
}
sparse k8s kubernetes/kubernetes c905fddc593a9458e776ad13bbfecbe5b3686afe
sparse prometheus-operator prometheus-operator/prometheus-operator 96b60b7490084819bd3a895ff9431968651fa1cb
sparse website kubernetes/website 3d8f3d7b579d7dfcef7b835fee8da2a37199012d
if [ "${CLASSIFY:-0}" = 1 ]; then
  mkdir -p "$OUT/yaml"
  for r in k8s prometheus-operator website; do "$PY" "$H/inputs/prep.py" classify "$R/$r" "$OUT/yaml/$r-classify.tsv"; done
  for r in k8s prometheus-operator website; do awk -F'\t' -v p="$R/$r/" '$2=="ok"{print p $1}' "$OUT/yaml/$r-classify.tsv"; done \
    | "$PY" "$H/inputs/agree.py" "$OUT/yaml/agree-baselines.tsv" "$OUT/yaml/bin/yamlcpp_row" "$OUT/yaml/bin/ryml_row"
fi
sed "s|^yaml-inputs/|$R/|" "$H/results/agree-baselines.tsv" > "$D/agree.tsv"
"$PY" "$H/inputs/corpus.py" "$D/agree.tsv" "$D" 8
