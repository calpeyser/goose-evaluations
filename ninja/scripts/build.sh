#!/bin/bash
# Build the three ninja rows into $OUT/ninja/bin:
#   ninja_harness  the harness linked against Ninja's own objects (-O2, LTO as Ninja's CMake does)
#   n2_harness     the harness over n2's loader (cargo release: LTO, jemalloc)
#   goose_load     goose/ninja_load.goose through `goose build -O2 --cc gcc`
# and the empty programs used for the start-up floor.
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
H=$ROOT/ninja; B=$OUT/ninja/bin; mkdir -p "$B"

fetch_repo ninja ninja-build/ninja "$NINJA_COMMIT"
fetch_repo n2 evmar/n2 "$N2_COMMIT"
if [ ! -f "$DEPS/ninja/build/ninja" ]; then
  (cd "$DEPS/ninja" && cmake -B build -DCMAKE_BUILD_TYPE=Release "-DCMAKE_CXX_FLAGS_RELEASE=-O2 -DNDEBUG" -DBUILD_TESTING=OFF && cmake --build build -j"$(nproc)")
fi
OBJS=$(ls "$DEPS"/ninja/build/CMakeFiles/libninja-re2c.dir/src/*.o "$DEPS"/ninja/build/CMakeFiles/libninja.dir/src/*.o)
g++ -O2 -DNDEBUG -std=c++17 -flto=auto -I"$DEPS/ninja/src" -o "$B/ninja_harness" "$H/baselines/ninja_harness.cc" $OBJS

# n2: the harness crate names n2 by path, so build it from a copy that points at $DEPS/n2.
W=$OUT/ninja/n2_harness; rm -rf "$W"; cp -r "$H/baselines/n2_harness" "$W"
sed -i "s|^n2 = .*|n2 = { path = \"$DEPS/n2\" }|" "$W/Cargo.toml"
(cd "$W" && cargo build --release -q) && cp "$W/target/release/n2_harness" "$B/"

"$GOOSE" build "$H/goose/ninja_load.goose" -O2 --cc gcc -o "$B/goose_load"
g++ -O2 -o "$B/empty_cpp" "$H/baselines/empty/empty.cc"
rustc -O -o "$B/empty_rs" "$H/baselines/empty/empty.rs"
"$GOOSE" build "$H/goose/empty.goose" -O2 --cc gcc -o "$B/empty_goose"
echo "ninja rows built: ninja $(git -C "$DEPS/ninja" rev-parse --short HEAD), n2 $(git -C "$DEPS/n2" rev-parse --short HEAD), goose $(git -C "$DEPS/goose" rev-parse --short HEAD)"
