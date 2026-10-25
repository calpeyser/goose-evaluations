#!/usr/bin/env python3
"""compare.py <runs.csv> <cases-dir> <out-dir>: master against branch, per case and per row.
time = the median cpu_time of the repetitions, in microseconds. ratio = branch / master.
spread = (slowest - fastest) / median, over the repetitions of one tree.
Writes compare.csv, compare-parse.md, compare-emit.md and summary.md in <out-dir>."""
import sys, os, csv, math, statistics
from collections import defaultdict
src, casedir, out = sys.argv[1:4]
UNIT = {'ns': 1e-3, 'us': 1.0, 'ms': 1e3, 's': 1e6}
t = defaultdict(list)
for r in csv.DictReader(open(src)):
    if r['error'] or not r['cpu_time']:
        continue
    t[(r['file'], r['row'], r['tree'])].append(float(r['cpu_time']) * UNIT[r['unit']])
cases = [l.strip() for l in open(f'{casedir}/cases.txt') if l.strip()]
def kind(row):
    lib = row.split('_')[1]
    if lib in ('ryml', 'rymlints', 'libyaml'):
        return lib
    return 'other'
# bm_ryml_yaml_arena_reuse_nofilter does not pass the reused tree to parse_in_arena (bm_parse.cpp at
# c42152f2), so it parses into a new tree each time. It is counted with the new-tree rows.
def reused(row):
    return '_reuse' in row and row != 'bm_ryml_yaml_arena_reuse_nofilter'
def gm(xs):
    return math.exp(sum(map(math.log, xs)) / len(xs)) if xs else float('nan')
res = []
for cmd in ('parse', 'emit'):
    for c in cases:
        f = f'ryml-bm-{cmd}-{c.split(".")[0]}.json'
        rows = sorted({k[1] for k in t if k[0] == f})
        for row in rows:
            m, g = t.get((f, row, 'master')), t.get((f, row, 'grow'))
            if not m or not g:
                continue
            mm, gg = statistics.median(m), statistics.median(g)
            res.append(dict(cmd=cmd, case=c, size=os.path.getsize(f'{casedir}/{c}'), row=row, kind=kind(row),
                            master_us=mm, branch_us=gg, ratio=gg / mm,
                            master_spread=(max(m) - min(m)) / mm, branch_spread=(max(g) - min(g)) / gg, reps=min(len(m), len(g))))
with open(f'{out}/compare.csv', 'w', newline='') as fo:
    w = csv.DictWriter(fo, fieldnames=list(res[0].keys())); w.writeheader()
    for r in res:
        w.writerow({k: (f'{v:.4f}' if isinstance(v, float) else v) for k, v in r.items()})
def us(x):
    return f'{x:,.1f}' if x < 1e4 else f'{x:,.0f}'
for cmd in ('parse', 'emit'):
    with open(f'{out}/compare-{cmd}.md', 'w') as fo:
        print(f'# bm_{cmd}: master against branch, every case and row\n', file=fo)
        print('Times are the median CPU time of 5 repetitions, in microseconds. Ratio is branch / master: below 1 '
              'is faster. Spread is (slowest - fastest) / median over the 5 repetitions. Source: `compare.csv`.\n', file=fo)
        for c in cases:
            rs = [r for r in res if r['cmd'] == cmd and r['case'] == c]
            if not rs:
                continue
            print(f'## {c} ({rs[0]["size"]:,} bytes)\n', file=fo)
            print('| row | master us | branch us | ratio | master spread | branch spread |', file=fo)
            print('|---|---:|---:|---:|---:|---:|', file=fo)
            for r in rs:
                print(f'| {r["row"]} | {us(r["master_us"])} | {us(r["branch_us"])} | {r["ratio"]:.3f} | '
                      f'{100*r["master_spread"]:.1f}% | {100*r["branch_spread"]:.1f}% |', file=fo)
            print(file=fo)
with open(f'{out}/summary.md', 'w') as fo:
    print('# Summary: geometric mean of branch / master time, per case and kind of row\n', file=fo)
    print('`ryml` = the `bm_ryml_*` rows: into a new tree or into a reused tree (`_reuse`), reserved before the timer or not (`_reserve`). '
          '`ints` = `bm_rymlints_*`. `libyaml` = libyaml, which builds a rapidyaml tree. '
          '`others` = libfyaml, yaml-cpp and the JSON libraries, which this change cannot touch. '
          'Each cell is the geometric mean of the ratios, with the number of rows in brackets. '
          '`bm_ryml_yaml_arena_reuse_nofilter` counts as a new-tree row: it does not pass the reused tree to the parser.\n', file=fo)
    def cell(rs):
        return f'{gm([r["ratio"] for r in rs]):.3f} ({len(rs)})' if rs else '-'
    for cmd in ('parse', 'emit'):
        print(f'## bm_{cmd}\n', file=fo)
        if cmd == 'parse':
            print('| case | bytes | ryml, new tree | ryml, new tree, `_reserve` | ryml, `_reuse` | ryml, `_reuse` + `_reserve` | ints | libyaml | others |', file=fo)
            print('|---|---:|---:|---:|---:|---:|---:|---:|---:|', file=fo)
        else:
            print('| case | bytes | ryml | others |', file=fo)
            print('|---|---:|---:|---:|', file=fo)
        for c in cases:
            rs = [r for r in res if r['cmd'] == cmd and r['case'] == c]
            ry = [r for r in rs if r['kind'] == 'ryml']
            if cmd == 'parse':
                grp = lambda reuse, resv: [r for r in ry if reused(r['row']) == reuse and r['row'].endswith('_reserve') == resv]
                print(f'| {c} | {rs[0]["size"]:,} | {cell(grp(False, False))} | {cell(grp(False, True))} | '
                      f'{cell(grp(True, False))} | {cell(grp(True, True))} | '
                      f'{cell([r for r in rs if r["kind"] == "rymlints"])} | {cell([r for r in rs if r["kind"] == "libyaml"])} | '
                      f'{cell([r for r in rs if r["kind"] == "other"])} |', file=fo)
            else:
                print(f'| {c} | {rs[0]["size"]:,} | {cell(ry)} | {cell([r for r in rs if r["kind"] == "other"])} |', file=fo)
        print(file=fo)
