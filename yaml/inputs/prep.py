#!/usr/bin/env python3
"""Classify the YAML files of a tree against the benchmark subset, and write the
canonical JSON emit that every row must reproduce.

  prep.py classify <root> <out.tsv>          one line per file: path, verdict, docs, bytes
  prep.py emit <file.yaml> [<out.json>]      canonical emit (all documents) via PyYAML compose

Subset: block and flow collections, plain / single / double-quoted / literal / folded
scalars, comments, multi-document streams. Out: anchors, aliases, explicit tags,
directives, non-scalar keys, empty documents, tabs in indentation, non-UTF-8.

Canonical emit, one line per document (the same in every row):
  scalar  -> "..." with \\ and \" escaped and bytes < 0x20 as \\u00xx (lowercase);
             a *plain* scalar that is "", "~", "null", "Null" or "NULL" -> null
  seq     -> [a,b,...]
  map     -> {k:v,...}   (keys emitted the same way as scalars)
"""
import sys, os, yaml

L = yaml.CSafeLoader
NULLS = {"", "~", "null", "Null", "NULL"}


def esc(s: bytes, out: bytearray):
    out += b'"'
    for b in s:
        if b == 0x22: out += b'\\"'
        elif b == 0x5C: out += b'\\\\'
        elif b < 0x20: out += b'\\u00%02x' % b
        else: out.append(b)
    out += b'"'


def emit_node(n, out: bytearray):
    if isinstance(n, yaml.ScalarNode):
        if not n.style and n.value in NULLS: out += b'null'
        else: esc(n.value.encode('utf-8'), out)
    elif isinstance(n, yaml.SequenceNode):
        out += b'['
        for i, c in enumerate(n.value):
            if i: out += b','
            emit_node(c, out)
        out += b']'
    else:
        out += b'{'
        for i, (k, v) in enumerate(n.value):
            if i: out += b','
            emit_node(k, out); out += b':'; emit_node(v, out)
        out += b'}'


def emit_text(text: bytes) -> bytes:
    out = bytearray()
    for d in yaml.compose_all(text, Loader=L):
        emit_node(d, out); out += b'\n'
    return bytes(out)


def verdict(text: bytes):
    try: s = text.decode('utf-8')
    except UnicodeDecodeError: return 'non-utf8', 0
    if '\t' in s: return 'tab', 0
    if s.startswith('﻿'): return 'bom', 0
    try:
        docs = 0
        for ev in yaml.parse(text, Loader=L):
            if isinstance(ev, yaml.AliasEvent): return 'alias', 0
            if isinstance(ev, (yaml.ScalarEvent, yaml.SequenceStartEvent, yaml.MappingStartEvent)):
                if ev.anchor: return 'anchor', 0
                if isinstance(ev, yaml.ScalarEvent):
                    if ev.tag is not None and not (ev.implicit[0] or ev.implicit[1]): return 'tag', 0
                elif ev.tag is not None and not ev.implicit: return 'tag', 0
            if isinstance(ev, yaml.DocumentStartEvent):
                if ev.version or ev.tags: return 'directive', 0
                docs += 1
        nodes = list(yaml.compose_all(text, Loader=L))
        for d in nodes:
            if d is None or (isinstance(d, yaml.ScalarNode) and not d.style and d.value == ''):
                return 'empty-doc', 0
            st = [d]
            while st:
                n = st.pop()
                if isinstance(n, yaml.MappingNode):
                    for k, v in n.value:
                        if not isinstance(k, yaml.ScalarNode): return 'complex-key', 0
                        st.append(v)
                elif isinstance(n, yaml.SequenceNode): st.extend(n.value)
        if not nodes: return 'no-docs', 0
        return 'ok', len(nodes)
    except yaml.YAMLError as e:
        return 'pyyaml-error', 0


def main():
    if sys.argv[1] == 'classify':
        root, out = sys.argv[2], sys.argv[3]
        paths = []
        for dp, dn, fn in os.walk(root):
            dn[:] = sorted(d for d in dn if d != '.git')
            for f in sorted(fn):
                if f.endswith(('.yaml', '.yml')): paths.append(os.path.join(dp, f))
        with open(out, 'w') as o:
            for p in paths:
                if os.path.islink(p) or not os.path.isfile(p): continue
                t = open(p, 'rb').read()
                v, d = verdict(t)
                o.write(f'{os.path.relpath(p, root)}\t{v}\t{d}\t{len(t)}\n')
    elif sys.argv[1] == 'emit':
        r = emit_text(open(sys.argv[2], 'rb').read())
        if len(sys.argv) > 3: open(sys.argv[3], 'wb').write(r)
        else: sys.stdout.buffer.write(r)


if __name__ == '__main__':
    main()
