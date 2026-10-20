# Run from a fresh clone

On 2026-10-20 we cloned this repository into an empty folder on a machine of the kind in
[../machine.md](../machine.md) (2-vCPU AWS Graviton, Amazon Linux 2023, gcc 11.5). Then we ran the
three steps of the README at the small size. All three ended with exit status 0, and every check
passed.

| step | time | result |
|---|---:|---|
| `bin/build-all` | 397 s | perf unpacked, Python venv, goose `0e04966` built, then every baseline and row of the four evaluations |
| `bin/fetch-inputs --size small` | 10 s | 13 files made or downloaded; all 13 sha256 equal `<evaluation>/inputs/sha256.txt` |
| `bin/run-all --size small` | 36 s | every row run, checked and timed; `bin/make-tables` reports "All checks passed: yes" |
| total | 443 s | |

`bin/emit-c --check` also gave the same C, byte for byte, for all 9 Goose programs.

The machine already had two caches from earlier work: Cargo's downloaded crates (they were compiled
again) and Goose's compiled run-time object. On a new machine, expect the build to take longer, about
15 to 20 minutes on 2 cores.

## What the checks mean

- **Inputs.** The small inputs include all three real YAML inputs (small, medium and large), because
  `yaml/inputs/real.sh` makes them together. All of them have the bytes we measured.
- **Rows agree.** In every evaluation, every row printed the same checksum lines on every input.
- **Same as committed.** Each checksum equals the one in that evaluation's `results/` folder.
- **Output = PyYAML.** Every YAML row, including the controls, wrote text equal to PyYAML's.

## What this run did not cover

- **Medium and large sizes.** Not run from the fresh clone. Their inputs were made on the same day
  with the same scripts, and their sha256 equal the recorded ones (`inputs/sha256.txt`).
- **Real Ninja build files.** CMake writes absolute paths into them, so their bytes and their path
  hash differ on every machine. `REAL=1 bin/fetch-inputs ninja` makes them; this run used the
  generated build file only.
- **jq without decNumber** (`EXTRA=1`) and the profiles. Not run.

## The tables of this run

Made by `bin/make-tables` (`.out/tables.md`). Times are medians of 5 runs.

### ninja: load a build graph (Ninja, n2, Goose)

| mode | input | Ninja | n2 | Goose | Goose vs Ninja | Goose vs n2 | rows agree | same as committed |
|---|---|---:|---:|---:|---:|---:|---|---|
| full | gen-small | 18.7 ms | 16.7 ms | 14.6 ms | 1.28x | 1.14x | yes | yes |
| load | gen-small | 13.0 ms | 11.0 ms | 9.4 ms | 1.39x | 1.18x | yes | yes |

The harness stops if a row's output differs from the first row's, so every line here agrees.

### json: a JSON tree (cJSON, yyjson, Goose)

| input | cJSON | yyjson | Goose | Goose vs yyjson | Goose vs cJSON | rows agree | same as committed |
|---|---:|---:|---:|---:|---:|---|---|
| twitter | 7.8 ms | 4.0 ms | 4.9 ms | 1.22x | 0.63x | yes | yes |
| citm_catalog | 12.8 ms | 5.7 ms | 6.7 ms | 1.18x | 0.52x | yes | yes |
| canada | 155.2 ms | 13.5 ms | 89.9 ms | 6.68x | 0.58x | yes | yes |
| gharchive-1m | 12.8 ms | 6.9 ms | 8.4 ms | 1.21x | 0.65x | yes | yes |
| gen-500 | 14.5 ms | 7.4 ms | 8.6 ms | 1.16x | 0.60x | yes | yes |

A ratio above 1 means Goose takes longer. "Rows agree" leaves out the output text, which cJSON prints differently.

### yaml: a YAML tree (yaml-cpp, rapidyaml, Goose)

| inputs | size | yaml-cpp | rapidyaml | Goose | C twin | rapidyaml vs Goose | yaml-cpp vs Goose | output = PyYAML | same as committed |
|---|---|---:|---:|---:|---:|---:|---:|---|---|
| real | small | 141.5 ms | 24.7 ms | 14.8 ms | 14.5 ms | 1.67x | 9.6x | yes | yes |
| gen | small | 144.6 ms | 22.6 ms | 15.6 ms | 15.1 ms | 1.45x | 9.3x | yes | yes |

Every row writes the tree as text; "output = PyYAML" means that text is byte for byte PyYAML's.

### jq: a jq core (jq, jaq, Goose)

| case | jq | jaq | Goose | jq vs Goose | jaq vs Goose | rows agree | same as committed |
|---|---:|---:|---:|---:|---:|---|---|
| gh-reemit-s | 30.4 ms | 19.7 ms | 11.5 ms | 2.65x | 1.71x | yes | yes |
| gh-select-s | 16.8 ms | 14.9 ms | 8.7 ms | 1.92x | 1.70x | yes | yes |
| gh-strings-s | 35.5 ms | 50.4 ms | 10.8 ms | 3.29x | 4.67x | yes | yes |
| gen-reemit-s | 29.5 ms | 19.8 ms | 10.8 ms | 2.73x | 1.83x | yes | yes |
| gen-select-s | 16.5 ms | 15.4 ms | 8.2 ms | 2.03x | 1.89x | yes | yes |
| gen-strings-s | 36.1 ms | 53.2 ms | 10.2 ms | 3.52x | 5.19x | yes | yes |
| reverse-s | 42.4 ms | 8.8 ms | 4.6 ms | 9.24x | 1.91x | yes | yes |
| sort-s | 37.2 ms | 13.4 ms | 5.7 ms | 6.48x | 2.33x | yes | yes |
| group-by-s | 99.1 ms | 22.6 ms | 13.6 ms | 7.31x | 1.67x | yes | yes |
| min-max-s | 15.6 ms | 13.5 ms | 4.9 ms | 3.21x | 2.77x | yes | yes |
| add-s | 49.1 ms | 32.7 ms | 7.9 ms | 6.24x | 4.15x | yes | yes |
| kv-s | 13.7 ms | 11.6 ms | 4.2 ms | 3.28x | 2.78x | yes | yes |
| cumsum-s | 34.6 ms | 24.6 ms | 8.9 ms | 3.87x | 2.75x | yes | yes |
| cumsum-xy-s | 49.7 ms | 38.3 ms | 12.0 ms | 4.13x | 3.18x | yes | yes |
| last-s | 10.1 ms | 4.2 ms | 2.1 ms | 4.89x | 2.04x | yes | yes |
| to-fromjson-s | 10.9 ms | 6.9 ms | 2.5 ms | 4.43x | 2.80x | yes | yes |
| ack-s | 34.1 ms | 32.5 ms | 8.9 ms | 3.85x | 3.67x | yes | yes |
| upto-s | 30.5 ms | 4.1 ms | 7.3 ms | 4.17x | 0.56x | yes | yes |
| str-slice-s | 93.2 ms | 26.7 ms | 15.7 ms | 5.92x | 1.70x | yes | yes |
| range-prop-s | 18.0 ms | 27.6 ms | 4.9 ms | 3.70x | 5.67x | yes | yes |
| empty | 2.6 ms | 2.6 ms | 1.7 ms | 1.56x | 1.59x | yes | yes |

