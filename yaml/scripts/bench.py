#!/usr/bin/env python3
"""Time the rows: per size, 1 warm-up + N runs, rows interleaved (a, b, c, a, b, c, ...).
Each run is  perf stat -e cycles:u,instructions:u -- /usr/bin/time -f %M -- <row> <input>
Wall clock is measured here around the whole command (so it includes perf's and time's
own start-up; the `floor` row, /bin/true under the same wrappers, shows how much).
Every run's ten checksum lines are compared with the first row's; a mismatch aborts.

  bench.py <out.csv> <sizes,comma> <rows,comma> [runs]
Rows are names of binaries in $OUT/yaml/bin, or `floor`. Inputs: $YAML_INPUTS/<size>.yaml
(set by run.sh to $INPUTS/yaml/real or $INPUTS/yaml/gen)."""
import os, subprocess, sys, time, csv, statistics, tempfile

BIN = os.path.join(os.environ['OUT'], 'yaml', 'bin')
INP = os.environ['YAML_INPUTS']
PERF = os.environ.get('PERF', 'perf')

out, sizes, rows = sys.argv[1], sys.argv[2].split(','), sys.argv[3].split(',')
runs = int(sys.argv[4]) if len(sys.argv) > 4 else 5
tmp = tempfile.mkdtemp(dir=os.environ.get('TMPDIR'))
pf, tf = os.path.join(tmp, 'perf'), os.path.join(tmp, 'time')

def one(row, size):
    exe = '/bin/true' if row == 'floor' else os.path.join(BIN, row)
    cmd = [PERF, 'stat', '-x,', '-o', pf, '-e', 'cycles:u,instructions:u', '--',
           '/usr/bin/time', '-f', '%M', '-o', tf, exe, os.path.join(INP, size + '.yaml')]
    t0 = time.perf_counter()
    cp = subprocess.run(cmd, capture_output=True)
    wall = time.perf_counter() - t0
    if cp.returncode != 0: sys.exit(f'{row} {size} failed: {cp.stderr.decode()[-500:]}')
    ev = {}
    for line in open(pf):
        f = line.strip().split(',')
        if len(f) > 3 and f[2] in ('cycles:u', 'instructions:u'): ev[f[2]] = int(f[0])
    rss = int(open(tf).read().strip().split('\n')[-1])
    return wall, rss, ev.get('cycles:u', 0), ev.get('instructions:u', 0), cp.stdout.decode()

new = not os.path.exists(out)
with open(out, 'a', newline='') as fo:
    w = csv.writer(fo)
    if new: w.writerow(['size', 'row', 'rep', 'wall_s', 'rss_kb', 'cycles_u', 'instr_u', 'checksum'])
    for size in sizes:
        ref = None
        for rep in range(runs + 1):
            for row in rows:
                wall, rss, cyc, ins, so = one(row, size)
                if row != 'floor':
                    if ref is None: ref = so
                    elif so != ref: sys.exit(f'checksum mismatch: {row} {size}\n{so}\nvs\n{ref}')
                w.writerow([size, row, rep, f'{wall:.4f}', rss, cyc, ins, so.strip().split('\n')[-1] if so else ''])
                fo.flush()
                print(size, row, rep, f'{wall:.3f}s', rss, 'KB', cyc, ins, flush=True)
