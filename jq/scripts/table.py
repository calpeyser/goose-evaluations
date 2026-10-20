#!/usr/bin/env python3
"""Fold bench.py results into markdown: python3 table.py bench.json > bench-table.md

Per case: median and best wall time per row, spread ((max-min)/median of the 5 runs),
peak RSS (one /usr/bin/time -f %M run, see rss.py), user cycles and instructions (one perf stat run), and
the ratio of each row's median to the Goose row's median.
"""
import json, sys

ROWS = ["jq", "jaq", "goose", "jq-cli", "jaq-cli", "jq-nodec", "goose-bulk"]


def med(xs):
    xs = sorted(xs)
    return xs[len(xs) // 2] if xs else None


def fmt_t(s):
    if s is None:
        return "-"
    return f"{s * 1000:.1f} ms" if s < 1 else f"{s:.3f} s"


def main():
    res = json.load(open(sys.argv[1]))
    print("| case | row | median | best | spread | peak RSS | cycles:u | instr:u | / goose |")
    print("|---|---|---:|---:|---:|---:|---:|---:|---:|")
    for name, c in res.items():
        g = med(c["rows"]["goose"]["wall"])
        for i, r in enumerate([r for r in ROWS if r in c["rows"]]):
            d = c["rows"][r]
            m = med(d["wall"])
            spread = (max(d["wall"]) - min(d["wall"])) / m * 100 if m else None
            perf = d.get("perf", {})
            cyc = perf.get("cycles")
            ins = perf.get("instructions")
            ratio = f"{m / g:.2f}x" if m and g else "-"
            label = name + ("" if c["ok"] else " **FAIL**") if i == 0 else ""
            print(f"| {label} | {r} | {fmt_t(m)} | {fmt_t(min(d['wall']) if d['wall'] else None)} | "
                  f"{spread:.1f}% | {d.get('rss_time_kb', max(d['rss_kb'])) / 1024:.1f} MB | "
                  f"{cyc / 1e9:.3f} G | {ins / 1e9:.3f} G | {ratio} |" if m else f"| {label} | {r} | - | | | | | | |")


if __name__ == "__main__":
    main()
