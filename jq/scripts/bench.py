#!/usr/bin/env python3
"""Benchmark the jq rows: python3 bench.py <out.json> [case-name-prefix ...]

Rows (all read the input on standard input):
  jq      harness_jq   libjq 1.8.2 behind the shared harness (idiomatic row)
  jaq     harness_jaq  jaq's library crates behind the shared harness (expert row)
  goose   jqg          the Goose jq core
  jq-cli  the jq command, -c, output to /dev/null (to check the harness is fair)
  jaq-cli the jaq command, -c, output to /dev/null

For each case and row: 1 warm-up, then 5 timed runs with the rows in turn
(jq, jaq, goose, jq-cli, jaq-cli, jq, ...). Wall time from perf_counter around
the process, user/sys time and peak RSS from wait4. Then one run per row under
`perf stat -e cycles:u,instructions:u`. Every harness run's four checksum lines
must equal the jq row's, or the case is marked FAIL.

Paths come from bin/env.sh: rows in $OUT/jq/bin, inputs in $INPUTS/jq, jaq's filters
in $DEPS/jaq/examples/benches. BENCH_SIZES=s (or m, l, or several) keeps only the cases
of those sizes, plus `empty`.
"""
import json, os, subprocess, sys, time

B = os.path.join(os.environ["OUT"], "jq", "bin")
PERF = os.environ.get("PERF", "perf")
BENCHES = os.path.join(os.environ["DEPS"], "jaq", "examples", "benches")
INP = os.path.join(os.environ["INPUTS"], "jq")

ROWS = {
    "jq": [f"{B}/harness_jq"],
    "jaq": [f"{B}/harness_jaq"],
    "goose": [f"{B}/jqg"],
    "jq-cli": [f"{B}/jq", "-c"],
    "jq-nodec": [f"{B}/harness_jq_nodec"],  # libjq built with --disable-decnum (extra row, BENCH_ROWS only; EXTRA=1 build)
    "goose-bulk": [f"{B}/jqg", "-b"],       # Goose reading all of stdin at once (extra row, BENCH_ROWS only)
    "jaq-cli": [f"{B}/jaq", "-c"],
}
HARNESS = ["jq", "jaq", "goose", "jq-nodec", "goose-bulk"]
DEFAULT_ROWS = ["jq", "jaq", "goose", "jq-cli", "jaq-cli"]

REAL = [
    ("gh-reemit", "."),
    ("gh-select", 'select(.type == "PushEvent") | {repo: .repo.name, actor: .actor.login, n: (.payload.commits | length)}'),
    ("gh-strings", "[.. | strings | length] | add"),
]

# jaq's own benchmarks that the Goose core supports, with three sizes each.
# The large size is the n of jaq's README table, except where noted.
MICRO = [
    ("reverse", [65536, 262144, 1048576]),
    ("sort", [65536, 262144, 1048576]),
    ("group-by", [65536, 262144, 1048576]),
    ("min-max", [65536, 262144, 1048576]),
    ("add", [65536, 262144, 1048576]),
    ("kv", [8192, 32768, 131072]),
    ("cumsum", [65536, 262144, 1048576]),
    ("cumsum-xy", [65536, 262144, 1048576]),
    ("last", [65536, 262144, 1048576]),
    ("to-fromjson", [4096, 16384, 65536]),
    ("ack", [5, 6, 7]),
    ("upto", [2048, 4096, 8192]),
    ("str-slice", [2048, 4096, 8192]),
    ("range-prop", [32, 64, 128]),
]


def cases():
    out = []
    for name, f in REAL:
        for sz in "sml":
            out.append((f"{name}-{sz}", f, f"{INP}/gh-{sz}.ndjson"))
    # The same filters over gen_events.py output (400 / 12,000 / 120,000 events).
    for name, f in REAL:
        for sz in "sml":
            out.append((name.replace("gh-", "gen-") + f"-{sz}", f, f"{INP}/gen-{sz}.ndjson"))
    for name, ns in MICRO:
        f = open(f"{BENCHES}/{name}.jq").read()
        for sz, n in zip("sml", ns):
            path = f"{INP}/n-{n}.txt"
            if not os.path.exists(path):
                open(path, "w").write(f"{n}\n")
            out.append((f"{name}-{sz}", f, path))
    # Start-up cost: one process that does nothing (jaq's `empty`).
    open(f"{INP}/null.txt", "w").write("null\n")
    out.append(("empty", "empty", f"{INP}/null.txt"))
    return out


def run_rusage(row, filt, path):
    cmd = ROWS[row] + [filt]
    with open(path, "rb") as inp:
        out = subprocess.DEVNULL if row.endswith("-cli") else subprocess.PIPE
        r, w = os.pipe()
        t0 = time.perf_counter()
        pid = os.fork()
        if pid == 0:
            os.dup2(inp.fileno(), 0)
            if out == subprocess.DEVNULL:
                fd = os.open(os.devnull, os.O_WRONLY)
                os.dup2(fd, 1)
            else:
                os.dup2(w, 1)
            os.close(r)
            os.execv(cmd[0], cmd)
        os.close(w)
        chunks = []
        while True:
            b = os.read(r, 1 << 16)
            if not b:
                break
            chunks.append(b)
        os.close(r)
        _, status, ru = os.wait4(pid, 0)
        t1 = time.perf_counter()
    code = os.waitstatus_to_exitcode(status)
    return code, t1 - t0, ru.ru_utime, ru.ru_stime, ru.ru_maxrss, b"".join(chunks)


def perf_run(row, filt, path):
    cmd = [PERF, "stat", "-x", ",", "-e", "cycles:u,instructions:u", "-o", "/dev/stderr", "--"] + ROWS[row] + [filt]
    with open(path, "rb") as inp:
        p = subprocess.run(cmd, stdin=inp, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
    vals = {}
    for line in p.stderr.decode().splitlines():
        parts = line.split(",")
        if len(parts) > 2 and parts[2] in ("cycles:u", "instructions:u"):
            vals[parts[2].split(":")[0]] = int(parts[0]) if parts[0].isdigit() else None
    return vals


def main():
    outp = sys.argv[1]
    prefixes = sys.argv[2:]
    results = json.load(open(outp)) if os.path.exists(outp) else {}
    sizes = os.environ.get("BENCH_SIZES", "sml")
    for name, filt, path in cases():
        if prefixes and not any(name.startswith(x) for x in prefixes):
            continue
        if name != "empty" and name[-1] not in sizes:
            continue
        rows = os.environ.get("BENCH_ROWS", ",".join(DEFAULT_ROWS)).split(",")
        res = {r: {"wall": [], "user": [], "sys": [], "rss_kb": []} for r in rows}
        ref = None
        ok = True
        note = ""
        for it in range(6):
            for r in rows:
                code, wall, ut, st, rss, out = run_rusage(r, filt, path)
                if code != 0:
                    ok = False
                    note += f"{r} exit {code}; "
                    continue
                if r in HARNESS:
                    lines = out.decode().splitlines()[-4:]
                    if ref is None:
                        ref = lines
                    elif lines != ref:
                        ok = False
                        note += f"{r} checksum {lines} != {ref}; "
                if it == 0:
                    continue          # warm-up
                res[r]["wall"].append(wall)
                res[r]["user"].append(ut)
                res[r]["sys"].append(st)
                res[r]["rss_kb"].append(rss)
        for r in rows:
            res[r]["perf"] = perf_run(r, filt, path)
        results[name] = {"filter": filt, "input": os.path.basename(path), "ok": ok, "note": note,
                         "checksum": ref, "rows": res}
        med = {r: sorted(res[r]["wall"])[2] if len(res[r]["wall"]) == 5 else None for r in rows}
        print(name, "OK" if ok else "FAIL " + note, " ".join(f"{r}={med[r]:.3f}" if med[r] else f"{r}=-" for r in rows),
              flush=True)
        json.dump(results, open(outp, "w"), indent=1)


if __name__ == "__main__":
    main()
