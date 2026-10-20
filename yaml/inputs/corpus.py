#!/usr/bin/env python3
"""Build the benchmark inputs from the files on which PyYAML, yaml-cpp and rapidyaml agree.
  corpus.py <agree.tsv> <outdir> <large-copies>
small  = the first files (sorted path order) until >= 1 MiB
medium = every agreed file
large  = medium repeated <large-copies> times
Each file is preceded by a '---' line unless its first content line already is one.
Also writes <name>.expect.json, the PyYAML canonical emit, for each input."""
import sys, os
sys.path.insert(0, os.path.dirname(__file__))
import prep
agree, outdir, copies = sys.argv[1], sys.argv[2], int(sys.argv[3])
paths = [l.split('\t')[0] for l in open(agree) if l.rstrip('\n').split('\t')[1:] == ['same', 'same']]
def piece(p):
    t = open(p, 'rb').read()
    if not t.endswith(b'\n'): t += b'\n'
    for ln in t.split(b'\n'):
        s = ln.strip()
        if not s or s.startswith(b'#'): continue
        return t if ln.startswith(b'---') else b'---\n' + t
    return b'---\n' + t
pieces = [piece(p) for p in paths]
small, n = [], 0
for x in pieces:
    small.append(x); n += len(x)
    if n >= 1 << 20: break
os.makedirs(outdir, exist_ok=True)
for name, parts in (('small', small), ('medium', pieces)):
    data = b''.join(parts)
    open(f'{outdir}/{name}.yaml', 'wb').write(data)
    exp = prep.emit_text(data)
    open(f'{outdir}/{name}.expect.json', 'wb').write(exp)
    print(name, len(parts), 'files', len(data), 'bytes')
med = open(f'{outdir}/medium.yaml', 'rb').read(); mexp = open(f'{outdir}/medium.expect.json', 'rb').read()
with open(f'{outdir}/large.yaml', 'wb') as f:
    for i in range(copies): f.write(med)
with open(f'{outdir}/large.expect.json', 'wb') as f:
    for i in range(copies): f.write(mexp)
print('large', copies, 'copies', len(med) * copies, 'bytes')
