#!/usr/bin/env python3
"""Shape of a YAML stream: scalar styles, flow vs block collections, key and value
lengths, depth, children per collection. Used to fit the generator.  stats.py <file>"""
import sys, yaml, collections
L = yaml.CSafeLoader
st = collections.Counter(); klen = []; vlen = []; depth = collections.Counter(); kids = collections.Counter()
def go(n, d, iskey=False):
    depth[min(d, 12)] += 1
    if isinstance(n, yaml.ScalarNode):
        st['scalar:' + (n.style or 'plain')] += 1
        (klen if iskey else vlen).append(len(n.value.encode()))
    elif isinstance(n, yaml.SequenceNode):
        st['seq:' + ('flow' if n.flow_style else 'block')] += 1; kids['seq:' + str(min(len(n.value), 10))] += 1
        for c in n.value: go(c, d + 1)
    else:
        st['map:' + ('flow' if n.flow_style else 'block')] += 1; kids['map:' + str(min(len(n.value), 10))] += 1
        for k, v in n.value: go(k, d + 1, True); go(v, d + 1)
docs = 0
for doc in yaml.compose_all(open(sys.argv[1], 'rb').read(), Loader=L):
    docs += 1; go(doc, 0)
print('docs', docs); print(dict(st))
import statistics as S
for name, a in (('key', klen), ('value', vlen)):
    a.sort(); print(name, 'n', len(a), 'mean %.1f' % S.mean(a), 'p50', a[len(a)//2], 'p90', a[len(a)*9//10], 'p99', a[len(a)*99//100], 'max', a[-1])
print('depth', sorted(depth.items())); print('children', sorted(kids.items()))
