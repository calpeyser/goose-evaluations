#!/usr/bin/env python3
"""Fold a bench.csv into the results table (markdown). Rep 0 is the warm-up and is dropped.
spread = (max - min) / median of wall time. Ratios are medians against the Goose row.
  table.py <bench.csv> [goose-row-name]"""
import csv, sys, statistics as S, collections
rows = collections.defaultdict(list)
for r in csv.DictReader(open(sys.argv[1])):
    if r['rep'] != '0': rows[(r['size'], r['row'])].append(r)
g = sys.argv[2] if len(sys.argv) > 2 else 'yaml_goose'
names = {'yamlcpp_row': 'yaml-cpp (idiomatic)', 'ryml_row': 'rapidyaml (expert)',
         'ryml_reserve_row': 'rapidyaml, reserved', 'yaml_goose': 'Goose', 'c_twin': 'C twin of Goose',
         'yaml_goose_gen': 'Goose', 'floor': 'start-up floor', 'c_twin_pad133': 'C twin, 144-byte nodes', 'yaml_goose_sa': 'Goose, one C file'}
print('| size | row | best s | median s | spread | vs Goose | cycles:u (G) | instr:u (G) | peak RSS MB |')
print('|---|---|---:|---:|---:|---:|---:|---:|---:|')
order = ['yamlcpp_row', 'ryml_row', 'ryml_reserve_row', 'yaml_goose', 'yaml_goose_sa', 'c_twin', 'c_twin_pad133', 'floor']
for size in ('small', 'medium', 'large'):
    gm = S.median(float(x['wall_s']) for x in rows.get((size, g), [{'wall_s': 'nan'}]))
    for row in order:
        rs = rows.get((size, row))
        if not rs: continue
        w = [float(x['wall_s']) for x in rs]
        med = S.median(w)
        cyc = S.median(int(x['cycles_u']) for x in rs) / 1e9
        ins = S.median(int(x['instr_u']) for x in rs) / 1e9
        rss = S.median(int(x['rss_kb']) for x in rs) / 1024
        ratio = '' if row in (g, 'floor') else f'{med / gm:.2f}x'
        print(f'| {size} | {names.get(row, row)} | {min(w):.3f} | {med:.3f} | {(max(w) - min(w)) / med * 100:.1f}% | {ratio} | {cyc:.3f} | {ins:.3f} | {rss:.1f} |')
