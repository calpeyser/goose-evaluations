#!/bin/bash
# Build the YAML rows into $OUT/yaml/bin, all at -O2:
#   yamlcpp_row       the harness over yaml-cpp (static library, Release)    idiomatic
#   ryml_row          the harness over rapidyaml (static library, Release)   expert
#   ryml_reserve_row  rapidyaml with its node array sized before the parse   control
#   yaml_goose        goose/yaml.goose
#   c_twin            baselines/twin.c, the Goose program written again in C  control
#   c_twin_pad133     the C twin with 144-byte nodes (the size of a rapidyaml node)
#   yaml_goose_sa     goose/yaml.goose as one C file, as Goose's own suite builds it
set -euo pipefail
source "$(dirname "$0")/../../bin/env.sh"
H=$ROOT/yaml; B=$OUT/yaml/bin; mkdir -p "$B"
fetch_repo yaml-cpp jbeder/yaml-cpp "$YAMLCPP_COMMIT"
fetch_repo rapidyaml biojppm/rapidyaml "$RAPIDYAML_COMMIT"
FLAGS=(-DCMAKE_BUILD_TYPE=Release "-DCMAKE_CXX_FLAGS_RELEASE=-O2 -DNDEBUG" -G Ninja)
[ -f "$DEPS/yaml-cpp/build/libyaml-cpp.a" ] || (cd "$DEPS/yaml-cpp" && cmake -B build "${FLAGS[@]}" -DYAML_CPP_BUILD_TESTS=OFF -DYAML_CPP_BUILD_TOOLS=OFF -DYAML_BUILD_SHARED_LIBS=OFF && ninja -C build)
[ -f "$DEPS/rapidyaml/build/libryml.a" ] || (cd "$DEPS/rapidyaml" && cmake -B build "${FLAGS[@]}" && ninja -C build)
S=$H/baselines; R=$DEPS/rapidyaml
g++ -O2 -DNDEBUG -std=c++17 -I"$DEPS/yaml-cpp/include" "$S/yamlcpp_row.cpp" "$DEPS/yaml-cpp/build/libyaml-cpp.a" -o "$B/yamlcpp_row"
g++ -O2 -DNDEBUG -std=c++17 -I"$R/src" -I"$R/ext/c4core.src" -I"$R/build/src" "$S/ryml_row.cpp" "$R/build/libryml.a" -o "$B/ryml_row"
g++ -O2 -DNDEBUG -DRESERVE -std=c++17 -I"$R/src" -I"$R/ext/c4core.src" -I"$R/build/src" "$S/ryml_row.cpp" "$R/build/libryml.a" -o "$B/ryml_reserve_row"
gcc -O2 -Wall -Wextra "$S/twin.c" -o "$B/c_twin"
gcc -O2 -DPAD=133 "$S/twin.c" -o "$B/c_twin_pad133"
"$GOOSE" build "$H/goose/yaml.goose" -O2 --cc gcc -o "$B/yaml_goose"
"$GOOSE" -O2 --standalone -o "$OUT/yaml/yaml_sa.c" "$H/goose/yaml.goose"
gcc -O2 -DGS_STACK_RESERVE=2147483648ull "$OUT/yaml/yaml_sa.c" -o "$B/yaml_goose_sa" -lm
echo "yaml rows built: yaml-cpp $(git -C "$DEPS/yaml-cpp" rev-parse --short HEAD), rapidyaml $(git -C "$R" rev-parse --short HEAD), goose $(git -C "$DEPS/goose" rev-parse --short HEAD)"
