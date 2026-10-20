# Goose evaluations

Four programs written in [Goose](https://github.com/aardappel/goose), each measured against the usual
C, C++ or Rust program for the same job (idiomatic) and the fastest one we know (expert). Goose beats
the idiomatic program in all four. It beats the expert program in three: Ninja build files, YAML and
jq. It loses to the expert in one: JSON, where yyjson is 1.2 to 1.3 times faster.

In every case the Goose win comes from the data layout: one pool per structure, values only as large
as they need to be, 4-byte links, and nothing to free one piece at a time. An expert C programmer can
write the same layout by hand. In Goose it is the ordinary way to write the program.

| evaluation | idiomatic | expert | largest input | idiomatic | expert | Goose | Goose against the expert |
|---|---|---|---|---:|---:|---:|---|
| [ninja](ninja/): load a build graph | Ninja | n2 (Rust) | LLVM `build.ninja`, 139 MB | 0.885 s | 0.753 s | 0.598 s | 1.26 times faster |
| [json](json/): a JSON tree | cJSON | yyjson | GitHub events, 300 MB | 3.445 s | 1.407 s | 1.811 s | 1.29 times slower |
| [yaml](yaml/): a YAML tree | yaml-cpp | rapidyaml | Kubernetes YAML, 180 MB | 20.803 s | 2.384 s | 0.990 s | 2.4 times faster |
| [jq](jq/): a jq core | jq 1.8.2 | jaq (Rust) | GitHub events, 315 MB, sum of string lengths | 9.44 s | 13.81 s | 2.38 s | 5.8 times faster |

Times are medians of 5 runs on a 2-vCPU AWS Graviton machine with gcc 11.5 at `-O2`
([machine.md](machine.md)). Where each number comes from:

- ninja: `ninja/scripts/bench.py --mode full`, [ninja/results/bench-full.md](ninja/results/bench-full.md).
- json: `json/scripts/bench.sh`, [json/results/bench-20261020-0104-table.md](json/results/bench-20261020-0104-table.md).
- yaml: `yaml/scripts/run.sh`, [yaml/results/bench-table.md](yaml/results/bench-table.md).
- jq: `jq/scripts/bench.py`, [jq/results/bench-table.md](jq/results/bench-table.md) (case `gh-strings-l`).

Each evaluation's README has the full tables, where the time goes, and the cases where Goose loses:
JSON with many decimal numbers (6.8 times slower than yyjson, because Goose's float printer is
exact and slow), and jq filters that recurse deeply or grow an array step by step.

## Run it in about 30 minutes

You need a Linux machine with git, gcc and g++ 11 or newer, make, Python 3, curl, and Rust (cargo).
perf must be able to count user cycles (`perf_event_paranoid` 2 or less). On Amazon Linux,
`bin/build-all` gets perf without root.

```bash
git clone https://github.com/calpeyser/goose-evaluations && cd goose-evaluations
bin/build-all                    # goose and every baseline at the pinned commits (about 20 minutes)
bin/fetch-inputs --size small    # about 1 MB per input, and one 136 MB download (about 2 minutes)
bin/run-all --size small         # every row, checked and timed (about 3 minutes)
```

`bin/run-all` writes `.out/tables.md`. For each input it says whether the rows agree with each other,
and whether each checksum equals the one in the committed results. Use `--size medium`, `large` or
`all` for the larger inputs. Run it on an idle machine: other load shows in the times.

Our own run from a fresh clone is in [results/clean-clone-run.md](results/clean-clone-run.md).

What a fresh clone does not reproduce:

- The real Ninja build files. CMake writes absolute paths into them, so their bytes differ on each
  machine. `REAL=1 bin/fetch-inputs ninja` makes them; the generated build files have the same bytes
  as ours.
- The exact times. They depend on the machine. The checksums do not.

## What is here

| path | what |
|---|---|
| `ninja/`, `json/`, `yaml/`, `jq/` | one folder per evaluation, all with the same parts (below) |
| `bin/build-all` | builds perf (if needed), a Python venv, goose, and each evaluation's baselines and rows |
| `bin/fetch-inputs` | downloads or generates the inputs, and checks their sha256 against `<evaluation>/inputs/sha256.txt` |
| `bin/run-all` | runs each evaluation's `scripts/run.sh`, then `bin/make-tables` |
| `bin/make-tables` | folds a run into `.out/tables.md` and checks every checksum |
| `bin/emit-c` | writes the C for every Goose program again; `--check` compares it with the committed C |
| `bin/env.sh` | the pinned commits and the paths every script uses |
| [machine.md](machine.md) | the machine, the compilers, and how times were taken |
| [THIRD_PARTY.md](THIRD_PARTY.md) | every baseline and data source, with its commit and license |

Each evaluation folder has:

| path | what |
|---|---|
| `README.md` | the evaluation: the question, the rows, the results, where the time goes, what it means |
| `goose/` | the Goose program(s), and the C that `goose -O2` writes for each ([GENERATED.md](ninja/goose/GENERATED.md)) |
| `baselines/` | our harnesses around the real libraries and tools (which `bin/build-all` fetches) |
| `inputs/` | the generators and the download recipes; real files are not committed |
| `scripts/` | build, run, table and profile scripts |
| `results/` | the committed measurements: tables, raw logs, profiles |

## License

Our code is Apache-2.0 ([LICENSE](LICENSE)). The projects it builds against and the data it downloads
keep their own licenses ([THIRD_PARTY.md](THIRD_PARTY.md)).
