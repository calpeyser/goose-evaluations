// Goose row: load a build.ninja the way Ninja does, build the graph, then do
// the fixed work of ../README.md and print the same checksum lines as the
// Ninja and n2 harnesses.
//
// The manifest (and each included file) is read once into `text`. A path or
// a binding value with no `$` in it, and already canonical, is a slice of
// that text: nothing is copied. Only evaluated or canonicalized strings go to
// the `strs` arena, once each. The graph is four pools linked by 4-byte
// pool-relative references: a node names its producing edge and the head of
// its consumer list; an edge's inputs are a contiguous run of `uses`, each
// use also the next link in its node's consumer list.
//
// Scope: build, rule, pool, default, include, top-level and edge bindings,
// the `$` escapes, ${name}, $in/$in_newline/$out, Ninja's path
// canonicalization and shell escaping of $in/$out. Not handled: subninja
// (a new scope), dyndep, and Ninja's variable-cycle diagnostics.

import std;
import dictionary;
import os;

struct Node {
    path: const u8[:],
    in_edge: Edge&<u32 in edges>?,
    first_use: Use&<u32 in uses>?,
    nuses: i32,
    depth: i32,
}
struct Use { node: Node&<u32 in nodes>, next: Use&<u32 in uses>? }
struct Bind { name: const u8[:], value: const u8[:] }
struct Rule { bind_start: i32, nbind: i32 }
struct Edge {
    rule: i32,
    bind_start: i32,
    nbind: i32,
    ins_start: i32,
    n_explicit: i32,
    n_implicit: i32,
    n_order: i32,
    outs_start: i32,
    n_outs: i32,
    n_implicit_outs: i32,
}
struct Span { s: i64, e: i64, dollar: bool }

var text: u8[>..] = [];
var strs: u8[>..] = [];
var nodes: Node[>..] = [];
var uses: Use[>..] = [];
var outs: (Node&<u32 in nodes>)[>..] = [];
var edges: Edge[>..] = [];
var rules: Rule[>..] = [];
var rbinds: Bind[>..] = [];
var ebinds: Bind[>..] = [];
var by_path = dictionary<const u8[:], Node&<u32 in nodes>?> {};
var rule_by_name = dictionary<const u8[:], i32> {};
var file_vars = dictionary<const u8[:], const u8[:]> {};
var spans: Span[>..<] = [];
var tmp: u8[>..<] = [];
var canon: u8[>..<] = [];
var cmd: u8[>..<] = [];
var pos = 0;
var lim = 0;

let FILE = 0;
let EDGE = 1;
let CMD = 2;

fn fnv(s: const u8[:]) -> u64 {
    var h: u64 = 1469598103934665603;
    for c in s { h = (h ^ c) * 1099511628211; }
    return h;
}

// --- evaluation --------------------------------------------------------------

fn is_simple(c: u8) -> bool {
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-'
}

fn is_ident(c: u8) -> bool { is_simple(c) || c == '.' }

fn shell_safe(c: u8) -> bool {
    (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')
        || c == '_' || c == '+' || c == '-' || c == '.' || c == '/'
}

// Ninja's GetShellEscapedString: unchanged when every byte is safe.
fn append_escaped(out: u8[>..<]&, p: const u8[:]) {
    var safe = true;
    for c in p { if !shell_safe(c) { safe = false; break; } }
    if safe { out.append(p); return; }
    out.push('\'');
    for c in p {
        if c == '\'' { out.append("'\\''"); } else { out.push(c); }
    }
    out.push('\'');
}

fn append_ins(out: u8[>..<]&, e: Edge&, sep: u8) {
    for k in e.n_explicit {
        if k > 0 { out.push(sep); }
        append_escaped(out, uses[e.ins_start + k].node.path);
    }
}

fn append_outs(out: u8[>..<]&, e: Edge&) {
    for k in e.n_outs - e.n_implicit_outs {
        if k > 0 { out.push(' '); }
        append_escaped(out, outs[e.outs_start + k].path);
    }
}

// Append the value of `name` in scope `mode`: FILE is the top-level scope;
// EDGE adds the bindings ebinds[b0 .. b0+nb] of the edge being parsed; CMD is
// Ninja's EdgeEnv for edge `e`: $in/$out, the edge's bindings, its rule's
// bindings (evaluated here, in this scope), then the top level.
recursive fn lookup_var(out: u8[>..<]&, name: const u8[:], mode: i64, b0: i64, nb: i64, e: i64) {
    if mode == CMD {
        let ed .= edges[e];
        if name == "in" { append_ins(out, ed, ' '); return; }
        if name == "in_newline" { append_ins(out, ed, '\n'); return; }
        if name == "out" { append_outs(out, ed); return; }
        for i in ed.bind_start..ed.bind_start + ed.nbind {
            if ebinds[i].name == name { out.append(ebinds[i].value); return; }
        }
        let r = rules[ed.rule];
        for i in r.bind_start..r.bind_start + r.nbind {
            if rbinds[i].name == name { eval_into(out, rbinds[i].value, CMD, 0, 0, e); return; }
        }
    } else if mode == EDGE {
        for i in b0..b0 + nb {
            if ebinds[i].name == name { out.append(ebinds[i].value); return; }
        }
    }
    let v = file_vars.get(name);
    if v { out.append(v); }
}

recursive fn eval_into(out: u8[>..<]&, raw: const u8[:], mode: i64, b0: i64, nb: i64, e: i64) {
    var i = 0;
    while i < raw.len {
        if raw[i] != '$' {
            var j = i + 1;
            while j < raw.len && raw[j] != '$' { j++; }
            out.append(raw[i..j]);
            i = j;
            continue;
        }
        i++;
        let d = raw[i];
        if d == '$' || d == ' ' || d == ':' { out.push(d); i++; continue; }
        if d == '\n' || d == '\r' {
            i += if d == '\r' { 2 } else { 1 };
            while i < raw.len && raw[i] == ' ' { i++; }
            continue;
        }
        if d == '{' {
            var j = i + 1;
            while raw[j] != '}' { j++; }
            lookup_var(out, raw[i + 1..j], mode, b0, nb, e);
            i = j + 1;
            continue;
        }
        var j = i;
        while j < raw.len && is_simple(raw[j]) { j++; }
        lookup_var(out, raw[i..j], mode, b0, nb, e);
        i = j;
    }
}

// A value: a slice of the text when it has no `$`, else evaluated once into strs.
fn eval_value(sp: Span, mode: i64, b0: i64, nb: i64) -> const u8[:] {
    if !sp.dollar { return text[sp.s..sp.e]; }
    tmp.clear();
    eval_into(tmp, text[sp.s..sp.e], mode, b0, nb, 0);
    let st = strs.len;
    strs.append(tmp);
    return strs[st..];
}

// --- paths -------------------------------------------------------------------

// True when CanonicalizePath would leave p unchanged.
fn is_canonical(p: const u8[:]) -> bool {
    if p.len == 0 { return false; }
    var start = 0;             // start of the current component
    var normal = false;        // a normal component has been seen
    var i = 0;
    while i <= p.len {
        if i == p.len || p[i] == '/' {
            let n = i - start;
            if n == 0 {
                if !(i == 0 && p.len > 1) { return false; }   // "//", a trailing "/"
            } else if n == 1 && p[start] == '.' {
                return false;
            } else if n == 2 && p[start] == '.' && p[start + 1] == '.' {
                if normal { return false; }
            } else {
                normal = true;
            }
            start = i + 1;
        }
        i++;
    }
    return true;
}

// Ninja's CanonicalizePath (POSIX): drop "." and empty components, let ".."
// remove the previous normal component, keep leading "..", "." if empty.
fn canonicalize(p: const u8[:]) {
    canon.clear();
    var marks: i64[..64] = [];
    var i = 0;
    if p.len > 0 && p[0] == '/' { canon.push('/'); i = 1; }
    let root = canon.len;
    while i < p.len {
        var j = i;
        while j < p.len && p[j] != '/' { j++; }
        let n = j - i;
        if n == 0 || (n == 1 && p[i] == '.') {
        } else if n == 2 && p[i] == '.' && p[i + 1] == '.' {
            if marks.len > 0 {
                let m = marks.pop();
                while canon.len > m { canon.pop(); }
            } else {
                canon.append("../");
            }
        } else {
            marks.push(canon.len);
            canon.append(p[i..j]);
            canon.push('/');
        }
        i = j + 1;
    }
    if canon.len > root { canon.pop(); }
    if canon.len == 0 { canon.push('.'); }
}

fn new_node(key: const u8[:]) -> Node& {
    let n .= nodes.push(Node { path: key, nuses: 0, depth: -1, .. });
    by_path.insert(key, n);
    return n;
}

fn intern(sp: Span, b0: i64, nb: i64) -> Node& {
    let raw = text[sp.s..sp.e];
    if !sp.dollar && is_canonical(raw) {
        let f = by_path.get(raw);
        if f { return f; }
        return new_node(raw);
    }
    tmp.clear();
    if sp.dollar { eval_into(tmp, raw, EDGE, b0, nb, 0); } else { tmp.append(raw); }
    canonicalize(tmp);
    let f = by_path.get(canon);
    if f { return f; }
    let st = strs.len;
    strs.append(canon);
    return new_node(strs[st..]);
}

// --- lexing ------------------------------------------------------------------

fn skip_line() {
    while pos < lim && text[pos] != '\n' { pos++; }
    if pos < lim { pos++; }
}

// Skip blank lines and comment lines; stop at the start of a real line.
fn skip_blank_lines() {
    while pos < lim {
        var q = pos;
        while q < lim && text[q] == ' ' { q++; }
        if q < lim && text[q] != '\n' && text[q] != '\r' && text[q] != '#' { return; }
        pos = q;
        skip_line();
    }
}

// At a line start: true, and past the indent, when the next real line is an
// indented binding. Comment lines are skipped; a blank line ends the block.
fn peek_indent() -> bool {
    loop {
        var q = pos;
        while q < lim && text[q] == ' ' { q++; }
        if q < lim && text[q] == '#' { pos = q; skip_line(); continue; }
        if q > pos && q < lim && text[q] != '\n' && text[q] != '\r' { pos = q; return true; }
        return false;
    }
}

fn skip_spaces() {
    loop {
        while pos < lim && text[pos] == ' ' { pos++; }
        if pos + 1 < lim && text[pos] == '$' && text[pos + 1] == '\n' { pos += 2; continue; }
        if pos + 2 < lim && text[pos] == '$' && text[pos + 1] == '\r' { pos += 3; continue; }
        return;
    }
}

fn read_ident() -> const u8[:] {
    let s = pos;
    while pos < lim && is_ident(text[pos]) { pos++; }
    guard pos > s else { abort(str("ninja_load: expected a name at byte ", s)); }
    return text[s..pos];
}

fn expect(c: u8) {
    guard pos < lim && text[pos] == c else { abort(str("ninja_load: expected '", c, "' at byte ", pos)); }
    pos++;
}

fn expect_newline() {
    skip_spaces();
    if pos < lim && text[pos] == '\r' { pos++; }
    if pos < lim { expect('\n'); }
}

// One evaluated string, unevaluated: its span and whether it holds a `$`.
// A path stops at a space, ':' or '|'; a value runs to the end of the line.
fn scan(path: bool) -> Span {
    let s = pos;
    var dollar = false;
    while pos < lim {
        let c = text[pos];
        if c == '$' {
            dollar = true;
            pos += 2;
            if text[pos - 1] == '\n' || text[pos - 1] == '\r' {
                if text[pos - 1] == '\r' { pos++; }
                while pos < lim && text[pos] == ' ' { pos++; }
            }
            continue;
        }
        if c == '\n' || c == '\r' { break; }
        if path && (c == ' ' || c == ':' || c == '|') { break; }
        pos++;
    }
    return Span { s: s, e: pos, dollar: dollar };
}

fn at_path() -> bool {
    pos < lim && text[pos] != ':' && text[pos] != '|' && text[pos] != '\n' && text[pos] != '\r'
}

fn scan_paths() {
    loop {
        skip_spaces();
        guard at_path() else { return; }
        spans.push(scan(true));
    }
}

// `name = value` after the indent (or at a line start).
fn scan_binding() -> const u8[:], Span {
    let name = read_ident();
    skip_spaces();
    expect('=');
    skip_spaces();
    let v = scan(false);
    expect_newline();
    return name, v;
}

// --- statements --------------------------------------------------------------

fn parse_rule() {
    skip_spaces();
    let name = read_ident();
    expect_newline();
    let b0 = rbinds.len;
    while peek_indent() {
        let k, v = scan_binding();
        rbinds.push(Bind { name: k, value: text[v.s..v.e] });
    }
    rule_by_name.insert(name, rules.len as i32);
    rules.push(Rule { bind_start: b0 as i32, nbind: (rbinds.len - b0) as i32 });
}

fn parse_build() {
    spans.clear();
    scan_paths();
    let n_exp_outs = spans.len;
    if pos < lim && text[pos] == '|' { pos++; scan_paths(); }
    let n_outs = spans.len;
    skip_spaces();
    expect(':');
    skip_spaces();
    let rname = read_ident();
    let ri = rule_by_name.get(rname);
    guard ri else { abort(str("ninja_load: unknown rule ", rname)); }
    let rule = ri;
    scan_paths();
    let n_explicit = spans.len - n_outs;
    var n_implicit = 0;
    var n_order = 0;
    if pos + 1 < lim && text[pos] == '|' && text[pos + 1] != '|' && text[pos + 1] != '@' {
        pos++;
        let m = spans.len;
        scan_paths();
        n_implicit = spans.len - m;
    }
    if pos + 1 < lim && text[pos] == '|' && text[pos + 1] == '|' {
        pos += 2;
        let m = spans.len;
        scan_paths();
        n_order = spans.len - m;
    }
    let n_ins = spans.len;
    if pos + 1 < lim && text[pos] == '|' && text[pos + 1] == '@' {
        pos += 2;
        scan_paths();
    }
    expect_newline();

    // Edge bindings are evaluated now, in the top-level scope.
    let b0 = ebinds.len;
    while peek_indent() {
        let k, v = scan_binding();
        ebinds.push(Bind { name: k, value: eval_value(v, FILE, 0, 0) });
    }
    let nb = ebinds.len - b0;

    let ed .= edges.push(Edge {
        rule: rule, bind_start: b0 as i32, nbind: nb as i32,
        ins_start: uses.len as i32, n_explicit: n_explicit as i32,
        n_implicit: n_implicit as i32, n_order: n_order as i32,
        outs_start: outs.len as i32, n_outs: n_outs as i32,
        n_implicit_outs: (n_outs - n_exp_outs) as i32,
    });
    // Paths are evaluated in the edge's scope: its bindings, then the top level.
    for k in n_outs {
        let n .= intern(spans[k], b0, nb);
        guard !n.in_edge else { abort(str("ninja_load: multiple rules generate ", n.path)); }
        n.in_edge .= ed;
        outs.push(n);
    }
    for k in n_outs..n_ins {
        let n .= intern(spans[k], b0, nb);
        let u .= uses.push(Use { node: n, next: n.first_use });
        n.first_use .= u;
        n.nuses++;
    }
    for k in n_ins..spans.len { intern(spans[k], b0, nb); }   // validations: nodes only
}

fn parse_pool() {
    skip_spaces();
    read_ident();
    expect_newline();
    while peek_indent() { scan_binding(); }
}

recursive fn parse_range(s: i64, e: i64) {
    let save_pos = pos;
    let save_lim = lim;
    pos = s;
    lim = e;
    loop {
        skip_blank_lines();
        guard pos < lim else { break; }
        let word = read_ident();
        if word == "build" { parse_build(); }
        else if word == "rule" { parse_rule(); }
        else if word == "pool" { parse_pool(); }
        else if word == "default" { skip_line(); }
        else if word == "subninja" { abort("ninja_load: subninja is not supported"); }
        else if word == "include" {
            skip_spaces();
            let sp = scan(true);
            expect_newline();
            let st = text.len;
            {
                var path: u8[>..] = [];
                path.append(eval_value(sp, FILE, 0, 0));
                guard read_file(path, text) else { abort(str("ninja_load: cannot read ", path)); }
            }
            parse_range(st, text.len);
        } else {
            skip_spaces();
            expect('=');
            skip_spaces();
            let v = scan(false);
            expect_newline();
            file_vars.insert(word, eval_value(v, FILE, 0, 0));
        }
    }
    pos = save_pos;
    lim = save_lim;
}

// --- the work ----------------------------------------------------------------

recursive fn depth(n: Node&) -> i32 {
    if n.depth >= 0 { return n.depth; }
    if n.depth == -2 { return 0; }
    n.depth = -2;
    var best: i32 = 0;
    let ie = n.in_edge;
    if ie {
        let tot = ie.n_explicit + ie.n_implicit + ie.n_order;
        if tot == 0 { best = 1; }
        for k in tot {
            let d = depth(uses[ie.ins_start + k].node) + 1;
            if d > best { best = d; }
        }
    }
    n.depth = best;
    return best;
}

fn main() {
    var path: u8[>..] = [];
    if arg_count() > 1 { arg(1, path); } else { path.append("build.ninja"); }
    guard read_file(path, text) else { print("cannot read ", path); exit(1); }
    rules.push(Rule { bind_start: 0, nbind: 0 });                 // phony
    rule_by_name.insert("phony", 0);
    parse_range(0, text.len);

    print(nodes.len, " ", edges.len);
    if arg_count() > 2 {                     // "load": stop after loading
        var mode: u8[>..] = [];
        arg(2, mode);
        if mode == "load" { return; }
        if mode == "stats" {                 // what the loaded graph holds
            print("text ", text.len, " strs ", strs.len, " nodes ", nodes.len, " uses ", uses.len,
                  " outs ", outs.len, " edges ", edges.len, " ebinds ", ebinds.len,
                  " rbinds ", rbinds.len, " rules ", rules.len, " dict slots ", by_path.slots.len);
            return;
        }
    }
    var ins = 0;
    var nouts = 0;
    for &e in edges {
        ins += e.n_explicit + e.n_implicit + e.n_order;
        nouts += e.n_outs;
    }
    print(ins, " ", nouts);
    var ph: u64 = 0;
    for &n in nodes { ph += fnv(n.path); }
    print(ph);

    var ncmd = 0;
    var cbytes = 0;
    var ch: u64 = 0;
    for i in edges.len {
        cmd.clear();
        lookup_var(cmd, "command", CMD, 0, 0, i);
        if cmd.len > 0 {
            ncmd++;
            cbytes += cmd.len;
            ch += fnv(cmd);
        }
    }
    print(ncmd, " ", cbytes, " ", ch);

    var x: u64 = 88172645463325252;
    var fanin = 0;
    var fanout = 0;
    let ne = edges.len as u64;
    for q in 100000 {
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        let e .= edges[(x % ne) as i64];
        let t = outs[e.outs_start].path;
        let n = by_path.get(t);
        guard n else { abort("lookup failed"); }
        let ie = n.in_edge;
        guard ie else { abort("no producer"); }
        fanin += ie.n_explicit + ie.n_implicit + ie.n_order;
        fanout += n.nuses;
    }
    print(fanin, " ", fanout);

    var sources = 0;
    var maxd = 0;
    var sumd = 0;
    for &n in nodes {
        if !n.in_edge { sources++; }
        let d = depth(n);
        if d > maxd { maxd = d; }
        sumd += d;
    }
    print(sources, " ", maxd, " ", sumd);
}
