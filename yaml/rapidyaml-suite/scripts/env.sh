# env.sh - the paths every script here uses. Override any of them in the environment.
export RYML=${RYML:-$HOME/projects/rapidyaml}            # a clone of github.com/biojppm/rapidyaml
export MASTER_COMMIT=c42152f2b7b8c7a450a670d61e890d9995088109
export BRANCH_COMMIT=${BRANCH_COMMIT:-5e3f3342}           # calpeyser/rapidyaml, branch grow-untouched-tail
                                                          # (measured: 0507bcdd, same library; before-fixes: ebf17e15)
export WT=${WT:-$RYML-wt}                                 # worktrees: $WT/master and $WT/grow
export SUITE=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export EVAL_ROOT=$(cd "$SUITE/../.." && pwd)
export WORK=${WORK:-$EVAL_ROOT/.out/rapidyaml-suite}      # cases, raw runs, plots before they are copied
export MEDIUM=${MEDIUM:-$EVAL_ROOT/.inputs/yaml/real/medium.yaml}
export REPS=${REPS:-5}
export RUN=${RUN:-final}                                   # a name for one run of both trees
export PYBM=${PYBM:-$WORK/venv/bin/python}                # a venv with rapidyaml's plot requirements
