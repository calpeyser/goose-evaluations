#!/bin/bash
# Build the jq rows into $OUT/jq/bin:
#   harness_jq    the harness over libjq 1.8.2 (release tarball, gcc -O2)        idiomatic
#   harness_jaq   the harness over jaq's library crates (cargo release, mimalloc) expert
#   jqg           goose/jqg.goose through `goose build -O2 --cc gcc`
#   jq, jaq       the two commands themselves, for the fairness check
# With EXTRA=1 also harness_jq_nodec: libjq built with --disable-decnum.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
H=$ROOT/jq; B=$OUT/jq/bin; mkdir -p "$B"

build_jq() {  # build_jq <dir> <configure flags...>
  local d=$DEPS/$1; shift
  [ -f "$d/install/lib/libjq.a" ] && return
  mkdir -p "$DEPS/dl"
  local t=$DEPS/dl/jq-$JQ_VERSION.tar.gz
  [ -f "$t" ] || curl -fsSL -o "$t" "https://github.com/jqlang/jq/releases/download/jq-$JQ_VERSION/jq-$JQ_VERSION.tar.gz"
  echo "$JQ_SHA256  $t" | sha256sum -c -
  rm -rf "$d"; mkdir -p "$d"; tar -xzf "$t" -C "$d" --strip-components=1
  (cd "$d" && CFLAGS=-O2 ./configure --disable-docs --with-oniguruma=builtin --prefix="$d/install" "$@" && make -j"$(nproc)" && make install)
}
build_jq jq
gcc -O2 -I"$DEPS/jq/install/include" -o "$B/harness_jq" "$H/baselines/harness_jq.c" "$DEPS/jq/install/lib/libjq.a" "$DEPS/jq/install/lib/libonig.a" -lm -lpthread
cp "$DEPS/jq/install/bin/jq" "$B/jq"
if [ "${EXTRA:-0}" = 1 ]; then
  build_jq jq-nodec --disable-decnum
  gcc -O2 -I"$DEPS/jq-nodec/install/include" -o "$B/harness_jq_nodec" "$H/baselines/harness_jq.c" "$DEPS/jq-nodec/install/lib/libjq.a" "$DEPS/jq-nodec/install/lib/libonig.a" -lm -lpthread
fi

fetch_repo jaq 01mf02/jaq "$JAQ_COMMIT"
(cd "$DEPS/jaq" && cargo build --release -q)
cp "$DEPS/jaq/target/release/jaq" "$B/jaq"
W=$OUT/jq/harness_jaq; rm -rf "$W"; cp -r "$H/baselines/harness_jaq" "$W"
sed -i "s|^jaq-all = { path = \"[^\"]*\"|jaq-all = { path = \"$DEPS/jaq/jaq-all\"|" "$W/Cargo.toml"
(cd "$W" && cargo build --release -q) && cp "$W/target/release/harness_jaq" "$B/"

"$GOOSE" build "$H/goose/jqg.goose" -O2 --cc gcc -o "$B/jqg"
echo "jq rows built: jq $JQ_VERSION, jaq $(git -C "$DEPS/jaq" rev-parse --short HEAD), goose $(git -C "$DEPS/goose" rev-parse --short HEAD)"
