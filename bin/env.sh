# Shared settings for the scripts in bin/ and in each evaluation's scripts/.
# Source it; do not run it. Every path can be set from outside.
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
export ROOT
export DEPS=${DEPS:-$ROOT/.deps}        # goose, the baselines, perf, a Python venv
export INPUTS=${INPUTS:-$ROOT/.inputs}  # downloaded and generated inputs
export OUT=${OUT:-$ROOT/.out}           # binaries and the results of new runs
export GOOSE=${GOOSE:-$DEPS/goose/build/goose}
export PY=${PY:-$DEPS/venv/bin/python}
if [ -z "${PERF:-}" ]; then
  if [ -x "$DEPS/perf/usr/bin/perf" ]; then PERF=$DEPS/perf/usr/bin/perf; else PERF=$(command -v perf || echo perf); fi
fi
export PERF
export PATH=$DEPS/venv/bin:$HOME/.cargo/bin:$HOME/.local/share/mise/shims:$PATH

# The pinned commits. These are the versions every committed result was measured at.
GOOSE_COMMIT=0e049664cb4cdd5818a27a1a64542788c676cd14
NINJA_COMMIT=3ccb2270e8ef5a84bb31c4651c0df84440f30362
N2_COMMIT=b1fead52ccda0c497d816696f23f4099c3e8ec1f
CJSON_COMMIT=6d9f2443ab071f86e5d9b43025a40929ec41c46c
YYJSON_COMMIT=556bf1c12b99608957271d319a546010e301da63
YAMLCPP_COMMIT=c5e65360373d1d99d6b6848c991cd4fcee435009
RAPIDYAML_COMMIT=c42152f2b7b8c7a450a670d61e890d9995088109
JAQ_COMMIT=6b8cbeb73e326950c435a57180742b40a82859cf
JQ_VERSION=1.8.2
JQ_SHA256=71b8d6e8f5fe81f6c6d0d110e3892251f6ce76ed095abd315e26e6e1193af3af
NATIVEJSON_COMMIT=478d5727c2a4048e835a29c65adecc7d795360d5

# fetch_repo <dir> <github owner/name> <commit>: a shallow checkout of one commit.
fetch_repo() {
  local dir=$DEPS/$1
  if [ -d "$dir/.git" ] && [ "$(git -C "$dir" rev-parse HEAD)" = "$3" ]; then return; fi
  rm -rf "$dir"; mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" remote add origin "https://github.com/$2"
  git -C "$dir" fetch -q --depth 1 origin "$3"
  git -C "$dir" -c advice.detachedHead=false checkout -q FETCH_HEAD
}

log() { echo "[$(date +%H:%M:%S)] $*"; }
