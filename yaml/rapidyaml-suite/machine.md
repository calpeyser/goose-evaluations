# The machine for this run

Both trees ran on one machine, in one session, on 2026-10-25, with nothing else running. The final
run went from 17:05 to 18:49 UTC. The before-fixes run went from 15:14 to 16:57 UTC. The two
trees took turns case by case, so they share the same conditions.

| | |
|---|---|
| instance | AWS `m7g.large`: Graviton3 (aarch64, Neoverse V1), 2 vCPUs, one thread per core |
| caches | 64 KB L1 data and 64 KB L1 instruction per core, 1 MB L2 per core, 32 MB L3 shared |
| memory | 7.6 GB |
| system | Amazon Linux 2023, Linux 6.18.54 |
| C and C++ | gcc and g++ 11.5.0 (Red Hat 11.5.0-5) |
| build | CMake 4.4.4 and Ninja, `-DCMAKE_BUILD_TYPE=Release` (`-O3 -DNDEBUG`), `-DRYML_BUILD_BENCHMARKS=ON` |
| benchmark library | Google Benchmark v1.10.0, Release (the version rapidyaml's build downloads) |
| Python for the charts | 3.9.25, with `proj/c4proj/bm-xp/requirements.txt` from the rapidyaml tree |
| `mhz_per_cpu` | 2100 in every result file of both trees |
| CPU scaling, ASLR | off and off, as Google Benchmark reports them |

`mhz_per_cpu` is the nominal clock that Google Benchmark reads from the system. This machine has no
frequency driver, so the number does not change, and it does not prove the clock was steady. The
rows that this change cannot touch are the real check: see "The noise floor" in the
[README](README.md).

The rapidyaml commits:

| tree | commit | what |
|---|---|---|
| master | `c42152f2` | biojppm/rapidyaml `master` on 2026-10-25 |
| branch | `5e3f3342` | calpeyser/rapidyaml `grow-untouched-tail`: one commit on `c42152f2` |
| branch, as measured | `0507bcdd` | the same library sources as `5e3f3342`; only `test/test_tree.cpp` differs |
| branch, before the fixes | `ebf17e15` | the earlier commit, for `results/before-fixes/` |
