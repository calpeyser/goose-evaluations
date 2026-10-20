#!/usr/bin/env python3
"""table.py <bench.tsv> -> markdown: best/median wall, spread, median cycles/instr, max RSS,
and median wall vs the yyjson row."""
import sys, csv, statistics as st
from collections import defaultdict
rows = defaultdict(list)
for r in csv.DictReader(open(sys.argv[1]), delimiter="\t"):
    rows[(r["file"], r["row"])].append(r)
files = list(dict.fromkeys(f for f, _ in rows))
print("| input | row | best s | median s | spread | wall vs yyjson | cycles vs yyjson | cycles G | instr G | IPC | peak RSS MB |")
print("|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|")
for f in files:
    ref = st.median(float(x["wall_s"]) for x in rows[(f, "yyjson")]) if (f, "yyjson") in rows else None
    refc = st.median(int(x["cycles_u"]) for x in rows[(f, "yyjson")])
    for (ff, r), xs in rows.items():
        if ff != f: continue
        w = sorted(float(x["wall_s"]) for x in xs)
        c = st.median(int(x["cycles_u"]) for x in xs); i = st.median(int(x["instr_u"]) for x in xs)
        rss = max(int(x["rss_kb"]) for x in xs) / 1024
        med = st.median(w)
        spread = (w[-1] - w[0]) / med * 100 if med else 0
        print(f"| {f} | {r} | {w[0]:.4f} | {med:.4f} | {spread:.0f}% | {med / ref:.2f}x | {c / refc:.2f}x | {c/1e9:.3f} | {i/1e9:.3f} | {i/c:.2f} | {rss:.0f} |")
