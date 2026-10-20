# Third-party code and data

This repository holds no third-party source code and no third-party data. `bin/build-all` fetches
the projects below at the commits listed, and `bin/fetch-inputs` downloads the data. The harnesses
in each `baselines/` folder are our own code, written against each project's public interface.

The `.c` files in each `goose/` folder are output of the Goose compiler for our `.goose` programs.

## Code

| project | where | version | license | used by |
|---|---|---|---|---|
| Goose | github.com/aardappel/goose | `0e04966` | Apache-2.0 | all four |
| Ninja | github.com/ninja-build/ninja | `3ccb227` | Apache-2.0 | ninja |
| n2 | github.com/evmar/n2 | `b1fead5` | Apache-2.0 | ninja |
| cJSON | github.com/DaveGamble/cJSON | `6d9f244` | MIT | json |
| yyjson | github.com/ibireme/yyjson | `556bf1c` | MIT | json |
| yaml-cpp | github.com/jbeder/yaml-cpp | `c5e6536` | MIT | yaml |
| rapidyaml (with c4core) | github.com/biojppm/rapidyaml | `c42152f` | MIT | yaml |
| jq | github.com/jqlang/jq, release tarball | 1.8.2 | MIT; also the dtoa notice, decNumber (ICU license) and Oniguruma (BSD-2-Clause) | jq |
| jaq | github.com/01mf02/jaq | `6b8cbeb` | MIT | jq |
| PyYAML | pypi.org/project/PyYAML | 6.0.3 | MIT | yaml (the reference output) |

The Rust harnesses also fetch crates from crates.io through Cargo: n2's dependencies (jemalloc among
them) and jaq's (mimalloc among them). Their versions are in each harness's `Cargo.lock`.

## Data

| data | where | license | used by |
|---|---|---|---|
| `twitter.json`, `citm_catalog.json`, `canada.json` | github.com/miloyip/nativejson-benchmark, `data/`, commit `478d572` | the repository is MIT; the files come from the sources it names | json |
| GH Archive, hour 2024-01-15 15:00 | data.gharchive.org | public GitHub event data | json, jq |
| Kubernetes YAML files | kubernetes/kubernetes `c905fdd`, prometheus-operator/prometheus-operator `96b60b7`, kubernetes/website `3d8f3d7` | Apache-2.0 (kubernetes, prometheus-operator); CC-BY-4.0 for the website's content | yaml |
| LLVM `build.ninja` files | made by CMake from github.com/llvm/llvm-project | Apache-2.0 with LLVM exceptions | ninja (optional) |
| jaq's benchmark filters | `examples/benches/` in jaq | MIT | jq |

The generated inputs (`gen-*`) come from our own generators and a fixed seed.
