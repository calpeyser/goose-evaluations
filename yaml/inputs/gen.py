#!/usr/bin/env python3
"""Generate a Kubernetes-shaped YAML stream from a seed, for a benchmark PR (real files
cannot be committed to Goose's repo). Deterministic: the same xorshift64 the Goose suite
uses (bench/cpp/bench.h), so a Goose or C++ port of this file makes the same bytes.

  gen.py <target-bytes> <out.yaml>

Shape fitted to the real corpus (results/stats-medium.txt): a stream of documents, each a
block map; block maps and block sequences nested up to 14 deep; sequences mostly of maps;
scalars plain (~94%), double-quoted, single-quoted and literal block; empty flow maps
`{}` and short flow sequences; comments; key lengths 3..20; value lengths mostly short
with a long tail (descriptions of 60..400 bytes)."""
import sys

S = [12345]
def nxt():
    x = S[0]
    x ^= (x << 13) & 0xFFFFFFFFFFFFFFFF
    x ^= x >> 7
    x ^= (x << 17) & 0xFFFFFFFFFFFFFFFF
    S[0] = x
    return x
def rnd(k): return nxt() % k

LET = 'abcdefghijklmnopqrstuvwxyz'
def word(lo, hi):
    return ''.join(LET[rnd(26)] for _ in range(lo + rnd(hi - lo + 1)))
def key():
    k = word(3, 10)
    if rnd(3) == 0: k += word(1, 1).upper() + word(2, 8)    # camelCase
    return k
def plain_value():
    r = rnd(100)
    if r < 30: return str(rnd(100000))
    if r < 40: return 'true' if rnd(2) else 'false'
    if r < 96: return '-'.join(word(2, 9) for _ in range(1 + rnd(3)))
    # a description: several words, sometimes with ": "-free punctuation
    return ' '.join(word(1, 10) for _ in range(10 + rnd(50))) + '.'

def scalar(out, ind):
    r = rnd(1000)
    if r < 30: out.append('"' + word(1, 6) + '\\n' + word(1, 20) + ' ' + word(1, 8) + '"')
    elif r < 37: out.append("'" + word(1, 8) + "''s " + word(1, 12) + "'")
    elif r < 57:
        out.append('|')
        for i in range(2 + rnd(15)):
            out.append('\n' + ' ' * (ind + 2) + ' '.join(word(1, 8) for _ in range(1 + rnd(8))))
    elif r < 60: out.append('null' if rnd(2) else '~')
    else: out.append(plain_value())
    out.append('\n')

def value(out, ind, depth):
    """The value after 'key:' on the same line."""
    r = rnd(100)
    pmap = max(8, 36 - 3 * depth)              # nesting thins out with depth
    if depth >= 14 or r < 88 - pmap:
        out.append(' '); scalar(out, ind)
    elif r < 90 - pmap: out.append(' {}\n')
    elif r < 92 - pmap: out.append(' [' + ', '.join(word(2, 8) for _ in range(1 + rnd(4))) + ']\n')
    elif r < 92:
        out.append('\n'); block_map(out, ind + 2, depth + 1, 1 + rnd(6))
    else:
        out.append('\n'); block_seq(out, ind, depth + 1)   # indentless, as kubectl writes

def block_map(out, ind, depth, nkeys, first_inline=False, used=None):
    used = set(used or ())                    # no duplicate keys: yaml-cpp rejects them
    for i in range(nkeys):
        if not (first_inline and i == 0): out.append(' ' * ind)
        if rnd(40) == 0: out.append('# ' + word(3, 30) + '\n' + ' ' * ind)
        k = key()
        while k in used: k = key()
        used.add(k)
        out.append(k + ':')
        value(out, ind, depth)

def block_seq(out, ind, depth):
    for i in range(1 + rnd(4)):
        out.append(' ' * ind + '- ')
        if depth >= 14 or rnd(10) < 2: scalar(out, ind + 2)
        else: block_map(out, ind + 2, depth + 1, 1 + rnd(5), first_inline=True)

def main():
    target, path = int(sys.argv[1]), sys.argv[2]
    out, n = [], 0
    with open(path, 'w') as f:
        while n < target:
            out.clear()
            out.append('---\napiVersion: v1\nkind: ' + word(4, 12).capitalize() + '\nmetadata:\n  name: ' + word(4, 20) + '\n')
            block_map(out, 0, 1, 1 + rnd(4), used=('apiVersion', 'kind', 'metadata'))
            s = ''.join(out); f.write(s); n += len(s)

if __name__ == '__main__':
    main()
