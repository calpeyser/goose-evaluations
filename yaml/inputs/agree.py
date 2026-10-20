#!/usr/bin/env python3
"""Per-file agreement: for every file the classifier accepted, compare the canonical
emit of PyYAML (reference) with each row binary given on the command line.
  agree.py <out.tsv> <row-bin>... < list-of-files
Writes: path, then one verdict per row (same / differs / fails)."""
import sys, subprocess, os
sys.path.insert(0, os.path.dirname(__file__))
import prep
out, rows = sys.argv[1], sys.argv[2:]
tmp = os.environ.get('TMPDIR', '/tmp') + '/agree.%d.json' % os.getpid()
with open(out, 'w') as o:
    for line in sys.stdin:
        p = line.rstrip('\n')
        ref = prep.emit_text(open(p, 'rb').read())
        vs = []
        for r in rows:
            try:
                cp = subprocess.run([r, p, tmp], capture_output=True, timeout=60)
                if cp.returncode != 0: vs.append('fails'); continue
                vs.append('same' if open(tmp, 'rb').read() == ref else 'differs')
            except subprocess.TimeoutExpired: vs.append('timeout')
        o.write(p + '\t' + '\t'.join(vs) + '\n')
