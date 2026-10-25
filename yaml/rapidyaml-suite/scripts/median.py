#!/usr/bin/env python3
"""median.py <runs-dir> <out-dir>: fold the repetitions into one json per tree and case.
For each row, it keeps the whole entry of the repetition whose cpu_time is the median, so every
field of that entry comes from one real run. Writes <out-dir>/<tree>/ryml-bm-<cmd>-<case>.json
in the layout of rapidyaml's bm-results folder, which bm_plot_rapidyaml.py reads.
Also writes <out-dir>/runs.csv: every row of every repetition."""
import sys, os, json, glob, csv, statistics
runs, out = sys.argv[1], sys.argv[2]
reps = sorted(glob.glob(f'{runs}/rep*'), key=lambda p: int(p.rsplit('rep', 1)[1]))
rows = []
for tree in ('master', 'grow'):
    os.makedirs(f'{out}/{tree}', exist_ok=True)
    for f in sorted(glob.glob(f'{reps[0]}/{tree}/*.json')):
        name = os.path.basename(f)
        docs = [json.load(open(f'{r}/{tree}/{name}')) for r in reps]
        merged = docs[0]
        merged['context']['repetitions'] = len(docs)
        merged['context']['note'] = 'each entry is the repetition with the median cpu_time, from separate processes'
        entries = []
        for i, e in enumerate(docs[0]['benchmarks']):
            alts = [d['benchmarks'][i] for d in docs]
            assert all(a['name'] == e['name'] for a in alts), name
            for k, (r, a) in enumerate(zip(reps, alts)):
                rows.append([tree, name, e['name'], k + 1, a.get('cpu_time', ''), a.get('real_time', ''),
                             a.get('time_unit', ''), a.get('iterations', ''), docs[k]['context']['mhz_per_cpu'],
                             a.get('error_message', '')])
            if e.get('error_occurred'):
                entries.append(e); continue
            alts.sort(key=lambda a: a['cpu_time'])
            entries.append(alts[len(alts) // 2])
        merged['benchmarks'] = entries
        json.dump(merged, open(f'{out}/{tree}/{name}', 'w'), indent=1)
with open(f'{out}/runs.csv', 'w', newline='') as fo:
    w = csv.writer(fo)
    w.writerow(['tree', 'file', 'row', 'rep', 'cpu_time', 'real_time', 'unit', 'iterations', 'mhz_per_cpu', 'error'])
    w.writerows(rows)
