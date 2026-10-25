#!/bin/bash
# cases.sh - gather the cases into $WORK/cases: rapidyaml's 13 files in bm/cases, the 22 MB
# medium.yaml from this repo's yaml evaluation, and three 1 MB scalar-heavy streams made from
# copies of bm/cases files (each copy is one document, after a '---' line).
set -euo pipefail
source "$(dirname "$0")/env.sh"
C=$WORK/cases; mkdir -p "$C"
for f in $(cat "$WT/master/bm/cases/bm-cases.txt"); do cp "$WT/master/bm/cases/$f" "$C/"; done
cp "$MEDIUM" "$C/medium.yaml"
for n in scalar_block_literal_multiline scalar_dquot_multiline scalar_plain_multiline; do
  out=$C/big_$n.yml; : > "$out"
  while [ $(stat -c %s "$out") -lt 1048576 ]; do printf -- '---\n' >> "$out"; cat "$WT/master/bm/cases/$n.yml" >> "$out"; done
done
{ cat "$WT/master/bm/cases/bm-cases.txt"; echo medium.yaml; for n in scalar_block_literal_multiline scalar_dquot_multiline scalar_plain_multiline; do echo big_$n.yml; done; } > "$C/cases.txt"
sha256sum $(sed "s#^#$C/#" "$C/cases.txt")
