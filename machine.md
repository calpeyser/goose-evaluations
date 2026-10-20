# The machine and how times were taken

All committed results come from one kind of machine, on 2026-10-20. Each evaluation ran on its own
machine of this kind, with nothing else running.

| | |
|---|---|
| CPU | AWS Graviton (aarch64), 2 vCPUs; 128 KB L1 data, 2 MB L2, 32 MB L3 |
| memory | 7 GB |
| system | Amazon Linux 2023, Linux 6.x, `perf_event_paranoid` = 2, stack limit 10 MB |
| C and C++ | gcc and g++ 11.5.0 (Red Hat 11.5.0-5), at `-O2` for every row |
| Rust | rustc 1.99.1, `cargo build --release` |
| Goose | commit `0e04966` of github.com/aardappel/goose, Release build; rows built with `goose build -O2 --cc gcc` |
| cmake | 4.4.4 |
| perf | 6.1.188 (the distribution package, unpacked without root) |
| Python | 3.9, PyYAML 6.0.3 with libyaml |

The commits of the baselines are in [THIRD_PARTY.md](THIRD_PARTY.md) and in `bin/env.sh`.

## How times were taken

Every evaluation uses the same plan:

1. Build each row once, at `-O2`, one thread.
2. For each input, run the rows in turn (a, b, c, a, b, c, ...): 1 warm-up run, then 5 timed runs.
3. Check the output of every run. A row whose checksum lines differ from the first row's stops the run.
4. Report the median of the 5 timed runs. "Spread" is the worst run against the best, divided by the
   median (ninja divides by the best).
5. Count user-mode cycles and instructions with `perf stat -e cycles:u,instructions:u`.

Where the four differ:

| evaluation | wall clock | peak memory | script |
|---|---|---|---|
| ninja | `time.perf_counter` around fork, exec and wait | `ru_maxrss` from `wait4` | `ninja/scripts/bench.py` |
| json | perf stat's "seconds time elapsed" | `/usr/bin/time -f %M` | `json/scripts/bench.sh` |
| yaml | `time.perf_counter` around `perf stat -- /usr/bin/time -- row` | `/usr/bin/time -f %M` | `yaml/scripts/bench.py` |
| jq | `time.perf_counter` around fork, exec and wait | `/usr/bin/time -f %M`, one run (`jq/scripts/rss.py`) | `jq/scripts/bench.py` |

The yaml wall clock includes the start of perf and time. Its `floor` row (`/bin/true` under the same
tools) shows that cost: 7 ms.

Each process is timed whole: start, read the input, the work, free, exit. Where a row frees its data,
that is inside the time.

## Run it on an idle machine

The rows run one at a time, so other load on the machine goes straight into the times. On a busy
machine perf's elapsed time (the json clock) also gave values far too small. The checksums do not
depend on load.
