#!/bin/bash
# build.sh - make the two worktrees and build both benchmark programs with the same flags.
set -euo pipefail
source "$(dirname "$0")/env.sh"
[ -d "$RYML/.git" ] || git clone https://github.com/biojppm/rapidyaml "$RYML"
git -C "$RYML" remote get-url fork >/dev/null 2>&1 || git -C "$RYML" remote add fork https://github.com/calpeyser/rapidyaml
git -C "$RYML" fetch -q origin; git -C "$RYML" fetch -q fork
[ -d "$WT/master" ] || git -C "$RYML" worktree add --detach "$WT/master" $MASTER_COMMIT
[ -d "$WT/grow" ] || git -C "$RYML" worktree add --detach "$WT/grow" $BRANCH_COMMIT
git -C "$WT/grow" checkout -q --detach $BRANCH_COMMIT
mkdir -p "$WORK"
if [ ! -x "$PYBM" ]; then
  python3 -m venv "$WORK/venv"
  "$WORK/venv/bin/pip" install -q -r "$WT/master/proj/c4proj/bm-xp/requirements.txt"
fi
for t in master grow; do
  cmake -S "$WT/$t" -B "$WT/$t/build-bm" -G Ninja -DCMAKE_BUILD_TYPE=Release \
    -DRYML_BUILD_BENCHMARKS=ON -DPython_EXECUTABLE="$PYBM"
  ninja -C "$WT/$t/build-bm" ryml-bm-build
done
