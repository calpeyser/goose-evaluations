#!/usr/bin/env python3
"""Time the three rows on every input.

    bench.py [--runs 5] [--mode full|load] [inputs...]

For each input, the rows run in turn (ninja, n2, goose, ninja, ...): one
warm-up each, then RUNS timed runs each. Wall clock is perf_counter around
fork+exec+wait; peak RSS is the child's own ru_maxrss from wait4. Every run's
stdout is checked against the first row's. Then `perf stat -r RUNS -e
cycles:u,instructions:u` per row. Writes $OUT/ninja/results/bench-<mode>.json and prints a
markdown table. Paths come from bin/env.sh: the rows in $OUT/ninja/bin, the
inputs in $INPUTS/ninja/<name>/.
"""
import json
import os
import statistics
import subprocess
import sys
import time

BIN = os.path.join(os.environ["OUT"], "ninja", "bin")
RES = os.path.join(os.environ["OUT"], "ninja", "results")
INP = os.path.join(os.environ["INPUTS"], "ninja")
PERF = os.environ.get("PERF", "perf")
ROWS = ["ninja_harness", "n2_harness", "goose_load"]
INPUTS = ["small", "medium", "large", "gen-small", "gen-medium", "gen-large"]


def run_once(exe, args, cwd):
    out = os.path.join(RES, "out.txt")
    with open(out, "wb") as f:
        t0 = time.perf_counter()
        pid = os.fork()
        if pid == 0:
            os.chdir(cwd)
            os.dup2(f.fileno(), 1)
            os.execv(exe, [exe] + args)
        _, status, ru = os.wait4(pid, 0)
        t1 = time.perf_counter()
    assert status == 0, (exe, cwd, status)
    return t1 - t0, ru.ru_maxrss, open(out, "rb").read()


def perf_stat(exe, args, cwd, runs):
    r = subprocess.run([PERF, "stat", "-x,", "-r", str(runs), "-e", "cycles:u,instructions:u",
                        exe] + args, cwd=cwd, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE,
                       text=True, check=True)
    vals = {}
    for line in r.stderr.splitlines():
        p = line.split(",")
        if len(p) > 3 and p[2].startswith(("cycles", "instructions")):
            vals[p[2].split(":")[0]] = (float(p[0]), p[3])
    return vals


def main():
    argv = sys.argv[1:]
    runs, mode = 5, "full"
    if "--runs" in argv:
        i = argv.index("--runs"); runs = int(argv[i + 1]); del argv[i:i + 2]
    if "--mode" in argv:
        i = argv.index("--mode"); mode = argv[i + 1]; del argv[i:i + 2]
    inputs = argv or INPUTS
    os.makedirs(RES, exist_ok=True)
    args = ["build.ninja"] + (["load"] if mode == "load" else [])
    results = {}
    for inp in inputs:
        cwd = os.path.join(INP, inp)
        exes = {r: os.path.join(BIN, r) for r in ROWS}
        ref = None
        times = {r: [] for r in ROWS}
        rss = {r: [] for r in ROWS}
        for k in range(runs + 1):
            for r in ROWS:
                t, m, out = run_once(exes[r], args, cwd)
                if ref is None:
                    ref = out
                assert out == ref, ("checksum differs", r, inp)
                if k > 0:
                    times[r].append(t); rss[r].append(m)
        res = {}
        for r in ROWS:
            ps = perf_stat(exes[r], args, cwd, runs)
            ts = times[r]
            res[r] = {"best": min(ts), "median": statistics.median(ts), "max": max(ts),
                      "spread": (max(ts) - min(ts)) / min(ts), "rss_kb": max(rss[r]),
                      "cycles": ps["cycles"][0], "cycles_var": ps["cycles"][1],
                      "instructions": ps["instructions"][0], "times": ts}
        results[inp] = {"checksum": ref.decode(), "rows": res}
        print(f"\n### {inp} ({mode})")
        print("| row | best s | median s | spread | cycles:u (G) | instr:u (G) | peak RSS MB |")
        print("|---|---:|---:|---:|---:|---:|---:|")
        for r in ROWS:
            x = res[r]
            print(f"| {r} | {x['best']:.4f} | {x['median']:.4f} | {100*x['spread']:.1f}% | "
                  f"{x['cycles']/1e9:.3f} ±{x['cycles_var']} | {x['instructions']/1e9:.3f} | "
                  f"{x['rss_kb']/1024:.1f} |")
        sys.stdout.flush()
    with open(os.path.join(RES, f"bench-{mode}.json"), "w") as f:
        json.dump(results, f, indent=1)


if __name__ == "__main__":
    main()
