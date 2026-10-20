# Print the shape of a CMake build.ninja: per rule kind, edge count, mean
# explicit/implicit/order-only inputs, outputs, bindings and binding bytes.
import sys, re, collections
kinds = collections.defaultdict(lambda: collections.Counter())
cur = None
lines = open(sys.argv[1], 'rb').read().decode('utf-8', 'replace').split('\n')
i = 0
def toks(s):  # split on unescaped spaces
    return [t for t in re.split(r'(?<!\$) +', s.strip()) if t]
for ln in lines:
    if ln.startswith('build '):
        head = ln[6:]
        # outs : rule ins | imp || ord
        m = re.match(r'(.*?)(?<!\$):\s*(\S+)\s*(.*)$', head)
        outs, rule, rest = m.group(1), m.group(2), m.group(3)
        k = re.sub(r'__.*', '', rule)
        c = kinds[k]
        c['edges'] += 1
        o = outs.split(' | ')
        c['outs'] += len(toks(o[0])); c['impouts'] += len(toks(o[1])) if len(o) > 1 else 0
        oo = rest.split(' || ')
        ex = oo[0].split(' | ')
        c['ins'] += len(toks(ex[0])); c['imp'] += len(toks(ex[1])) if len(ex) > 1 else 0
        c['ord'] += len(toks(oo[1])) if len(oo) > 1 else 0
        c['pathbytes'] += len(head)
        cur = c
    elif ln.startswith('  ') and cur is not None:
        cur['binds'] += 1; cur['bindbytes'] += len(ln)
    else:
        cur = None
print('%-28s %7s %6s %6s %6s %6s %6s %6s %6s %8s' % ('kind','edges','outs','impo','ins','imp','ord','binds','B/bind','headB'))
for k, c in sorted(kinds.items(), key=lambda kv: -kv[1]['edges']):
    e = c['edges']
    print('%-28s %7d %6.1f %6.1f %6.1f %6.1f %6.1f %6.1f %6.0f %8.0f' % (k, e, c['outs']/e, c['impouts']/e, c['ins']/e, c['imp']/e, c['ord']/e, c['binds']/e, c['bindbytes']/max(1,c['binds']), c['pathbytes']/e))
