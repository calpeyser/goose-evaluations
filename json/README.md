# A JSON tree: cJSON, yyjson and Goose

Goose is between the two C libraries. On real GitHub event data, a JSON tree in Goose takes 1.2 to
1.3 times the time of yyjson, the fastest C library. It takes about half the time of cJSON, the
common C library. Goose uses the least memory of the three: 18% less than yyjson and 43% less than
cJSON on the 300 MB file.

The row shows both sides. Goose wins clearly over the common way to write a JSON tree. It loses to an
expert library. It also loses badly on inputs that are mostly decimal numbers, because Goose prints
floats with a slow exact method.

Numbers: `scripts/bench.sh`, in
[results/bench-20261020-0104-table.md](results/bench-20261020-0104-table.md).

## The rows

- **Idiomatic: cJSON** (`6d9f244`). It allocates one block of memory for each value and one more for
  each string, and links children in a list.
- **Expert: yyjson** (`556bf1c`). It keeps all values in one flat array of 16-byte records, and
  leaves strings in its copy of the input.
- **Goose: [goose/json.goose](goose/json.goose).** All values are in one pool, in document order.
  Each value is exactly as large as it must be. Strings sit inside the value. Links are 4 bytes.

The two C rows are our harnesses, [baselines/bench_cjson.c](baselines/bench_cjson.c) and
[baselines/bench_yyjson.c](baselines/bench_yyjson.c), compiled with each library's source.

## The work, the same in every row

```mermaid
flowchart LR
  A[read the file] --> B[parse into a tree]
  B --> C[walk: count, hash]
  C --> D[look up 5 keys in every object]
  D --> E[write minified JSON]
  E --> F[print checksums]
  F --> G[free the tree]
```

The walk counts values by type, adds up string bytes, and hashes every value in order. The lookups
ask each object for the keys `id`, `name`, `type`, `url` and `text`. Goose has no free step: the
pool goes away when the program ends.

## Inputs

| input | size | where it comes from |
|---|---:|---|
| twitter | 0.6 MB | nativejson-benchmark, `data/twitter.json` |
| citm_catalog | 1.7 MB | nativejson-benchmark, `data/citm_catalog.json` |
| canada | 2.3 MB | nativejson-benchmark, `data/canada.json` (map outlines: almost all decimal numbers) |
| gharchive 1m / 30m / 300m | 1.0 / 30.2 / 300.5 MB | GH Archive hour 2024-01-15 15:00, the first 282 / 8,254 / 80,701 events, as one JSON array |
| gen 500 / 14000 / 140000 | 1.1 / 29.7 / 298.5 MB | our generator, [inputs/gen_events.c](inputs/gen_events.c), same shape as the GH Archive data |

[inputs/fetch.sh](inputs/fetch.sh) makes each file. All nine have the same bytes as ours
([inputs/sha256.txt](inputs/sha256.txt)).

## Correctness first

- All three rows print the same counts, string bytes, walk hash and lookup hash, on all 9 inputs.
  `scripts/bench.sh` checks this on every run. The checksum lines are in `results/sums-<row>-<input>.txt`.
- Goose's output text is byte for byte the same as yyjson's on all 9 inputs.
- cJSON's output differs, and on two inputs it is wrong. It stores every number as a double, so the
  large integer ids in twitter lose digits. It also prints some decimals with too few digits, so
  canada does not read back to the same numbers. (Check: Python's `json.load` of each output,
  compared with the input.)

## Results

Command: `scripts/bench.sh` with all rows and inputs. Log
[results/bench-20261020-0104.tsv](results/bench-20261020-0104.tsv), table
[results/bench-20261020-0104-table.md](results/bench-20261020-0104-table.md). 1 warm-up and 5 runs per
row. Wall time is the median. The spread is 2% or less on every input of 1 MB or more. How the times
were taken: [../machine.md](../machine.md).

| input | cJSON | yyjson | Goose | Goose vs yyjson | Goose vs cJSON |
|---|---:|---:|---:|---:|---:|
| twitter | 7.8 ms | 4.1 ms | 5.0 ms | 1.24x | 0.64x |
| citm_catalog | 12.7 ms | 5.7 ms | 6.6 ms | 1.15x | 0.52x |
| canada | 155.3 ms | 13.2 ms | 89.6 ms | **6.79x** | 0.58x |
| gharchive 1m | 13.0 ms | 6.7 ms | 8.1 ms | 1.22x | 0.62x |
| gharchive 30m | 0.343 s | 0.144 s | 0.185 s | 1.28x | 0.54x |
| gharchive 300m | 3.445 s | 1.407 s | 1.811 s | 1.29x | 0.53x |
| gen 500 | 14.6 ms | 7.4 ms | 8.7 ms | 1.17x | 0.60x |
| gen 14000 | 0.344 s | 0.149 s | 0.182 s | 1.22x | 0.53x |
| gen 140000 | 3.424 s | 1.480 s | 1.808 s | 1.22x | 0.53x |

A ratio above 1 means Goose takes longer.

Peak memory, same run:

| input | cJSON | yyjson | Goose |
|---|---:|---:|---:|
| gharchive 30m | 154 MB | 107 MB | 89 MB |
| gharchive 300m | 1,534 MB | 1,056 MB | 871 MB |
| gen 140000 | 1,614 MB | 1,071 MB | 864 MB |

These numbers include the input text and the output text, about 600 MB on the large files. Without
them, the tree itself is about 270 MB in Goose, 450 MB in yyjson (with its copy of the input) and
930 MB in cJSON.

The gap does not grow with size: Goose is 1.22x yyjson at 1 MB and 1.29x at 300 MB on the real data.

## Where the time goes

Each program prints the time of each phase to its error output
(`results/stderr-<row>-<input>.txt`). Seconds per phase, gharchive 30m:

| phase | cJSON | yyjson | Goose |
|---|---:|---:|---:|
| parse | 0.112 | 0.032 | 0.052 |
| walk and lookups | 0.046 | 0.039 | 0.039 |
| write | 0.085 | 0.021 | 0.041 |
| output hash | 0.037 | 0.037 | 0.036 |
| free | 0.048 | 0.005 | 0 |

Profiles: `scripts/profile.sh <input>` (`perf record -e cycles:u`), in
`results/profile-<row>-<input>.txt`.

**The walk costs the same in Goose and yyjson.** The walk spends its time hashing string bytes, and
those bytes are the same in every row. So Goose's small values and 4-byte links do not help here.

**Goose loses on parse and write.** Consider the string scan. Goose reads one byte per step: it loads
a byte, compares it with a quote and a backslash, checks the bound, and stores the position back to
memory. yyjson reads 4 bytes per step through a 256-entry table. The writer has the same difference.

**Goose wins over cJSON on every phase.** cJSON calls `malloc` for each value and each string. The
allocator alone takes about 22% of cJSON's cycles. Then cJSON spends 48 ms to free the tree. Goose
has no allocator and no free step.

**On canada, the float printer is the problem.** canada has 111,126 numbers, most with 15 to 17
digits. Goose's write phase takes 65 ms, and yyjson's 3.5 ms. In the profile, 70% of Goose's cycles
are in the run-time function that finds the shortest digits of a float. It uses exact big-number
arithmetic for every float. yyjson gets the same result with a fast method.

### Which Goose feature makes the difference

Three test versions of the Goose row answer "why". They are not rows. Same command and log; the
checksums of all versions match.

| Goose version | gharchive 300m | vs yyjson | peak memory |
|---|---:|---:|---:|
| the Goose row | 1.811 s | 1.29x | 871 MB |
| no index checks ([scripts/nocheck.sh](scripts/nocheck.sh)) | 1.759 s | 1.25x | 871 MB |
| table scan, 4 bytes per step ([goose/json_fast.goose](goose/json_fast.goose)) | 1.755 s | 1.25x | 871 MB |
| table scan, strings left in the input ([goose/json_view.goose](goose/json_view.goose)) | 1.695 s | 1.20x | 667 MB |

- **Run-time checks cost about 3%.** Goose keeps an index check where it cannot prove the index is in
  range. Removing them all saves 3% of wall time and 6% of instructions.
- **The table scan saves 3%.** An expert C programmer and an expert Goose programmer can both write
  it. Goose does not prevent it.
- **Strings inside the values cost 3% and save memory.** When the tree only points into the input,
  as yyjson's does, parse is 16% faster, but the walk is 5% slower, because the strings are no longer
  next to their values. The memory saving of 23% comes only because the input must then stay in
  memory too. And the tree is then no longer a value of its own: you cannot save it, or send it to
  another thread, as one block.
- **The rest of the gap is yyjson's tuning.** yyjson has hand-unrolled loops, fast paths for each
  kind of number, and a table-driven writer. An expert C programmer writes these by hand, and a Goose
  programmer could too. On this work, Goose's language features give no extra win, and they cost
  little.

### Two smaller findings about Goose

- **The standard float reader is not exact.** Goose's `parse_flt` is exact only for short numbers. On
  canada, 11,975 of 111,080 decimals come out one unit in the last place away from the correct value
  (Python compare). Its own comment says this can happen. So the Goose row reads short decimals
  itself and calls the C library's `strtod` for long ones ([goose/strtod_shim.c](goose/strtod_shim.c)),
  as cJSON does for all numbers. On every input except canada, no number needs `strtod`. The version
  with `parse_flt` only is [goose/json_purefloat.goose](goose/json_purefloat.goose); its canada
  walk hash differs ([results/sums-goose_purefloat-canada.txt](results/sums-goose_purefloat-canada.txt)
against [results/sums-goose-canada.txt](results/sums-goose-canada.txt)).
- **The float printer is slow** (above). A faster method in Goose's run-time, for example Ryu or
  Schubfach, would give the same text and fix the canada result.

## What it means

Goose's design wins clearly over the idiomatic C library. It is about twice as fast as cJSON and uses
43% less memory, with no allocator and nothing to free. The reasons are the ones Goose's design
document gives: one pool, no allocator, no teardown.

Goose does not reach the expert library. yyjson is already a pool design: one flat array of values,
no allocator in the loop, and almost nothing to free. So the two rows use the same idea, and the
difference is how much hand tuning each has. The best Goose version is 1.20x yyjson.

So this row shows "Goose with ordinary code gets most of the expert's speed, with less memory than
both". It does not show "Goose beats expert C". When the expert C already has the right layout,
Goose cannot win on layout.

## How this could become a row in Goose's suite

1. `bench/goose/json.goose`: `goose/json.goose` with the generator built in, so it needs no input file.
2. `bench/cpp/json.cpp`, two variants: cJSON (`VARIANT=0`, about 3,500 lines, MIT) and yyjson
   (`VARIANT=1`, about 20,100 lines, MIT), with their license files. If the suite should hold no
   copied libraries, the C++ rows would be our own code in each style: a node per value with
   `std::string` and `std::vector` children, and a flat value array with strings left in the input.
3. Optional Rust rows: `serde_json::Value` (idiomatic) and a borrowed-string tree (expert).
4. One entry in the suite's benchmark list, with sizes 500, 14,000 and 140,000 events.

The generator, [inputs/gen_events.c](inputs/gen_events.c), writes a JSON array of N events shaped
like a GH Archive dump: push, create, watch, delete, issue, comment and pull request events, with
nested objects, URLs, hashes, and long text with `\n`, `\"`, `\u` escapes and raw UTF-8. It uses the
suite's own random number function, so a Goose copy of it makes the same bytes. Its output gives the
same picture as the real data: Goose is 1.22x yyjson on the generated files and 1.22x to 1.29x on the
real ones. Its shape is close: 24.5 values per KB and 83% string bytes, against 21 per KB and 86% in
the real data.

Licenses: Goose is Apache-2.0. cJSON and yyjson are MIT.

## Run it

From the repository root:

```bash
bin/build-all json                        # cJSON, yyjson, the rows and the test versions
bin/fetch-inputs --size small json        # twitter, citm_catalog, canada, gharchive-1m, gen-500
json/scripts/run.sh small                 # into .out/json/results/
json/scripts/profile.sh gharchive-1m      # optional: the profiles
```

## Files

| path | what |
|---|---|
| `goose/json.goose`, `goose/json.c` | the Goose row and its generated C ([goose/GENERATED.md](goose/GENERATED.md)) |
| `goose/json_{fast,view,purefloat}.*` | the test versions |
| `goose/strtod_shim.c`, `goose/*.build` | the C helper the Goose programs link, and the file that names it |
| `baselines/` | the cJSON and yyjson harnesses and their shared header |
| `inputs/` | the generator, the fetch recipe and the sums |
| `scripts/` | `build.sh`, `bench.sh`, `run.sh`, `table.py`, `nocheck.sh`, `profile.sh` |
| `results/` | the final run (`bench-20261020-0104.*`), checksum lines, phase timers, profiles, the Goose build log |
