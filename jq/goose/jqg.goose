// A jq core in Goose: JSON values, a parser for a subset of the jq language,
// and an evaluator, for the goose-bench comparison against jq and jaq.
//
// Usage: jqg [-o] [-b] '<filter>' < input
//   Each line of standard input holds zero or more JSON values. The filter
//   runs on each value; every output is written compactly with a newline and
//   folded into an FNV-1a hash. At the end three checksum lines are printed.
//   -o also writes the outputs to standard output (for diffs against jq).
//
// Values. Scalars are unboxed in a fixed-mode `Cell` (9 bytes). Strings,
// arrays and objects are variable-mode `Val`s in one grow-only pool, each
// exactly as big as its contents: a string's bytes, an array's cells and an
// object's entries (key bytes inline, then a cell) sit inside the value. The
// pool is cleared after each input value, which frees everything at once.
//
// The evaluator is eager: a filter's outputs for one input are pushed onto a
// global stack of cells, and the caller takes them from there. That suits
// every filter here except infinite generators (`repeat`, `limit` over one),
// which this core does not support.

import std;
import dictionary;
import math;
import os;

// --- values ------------------------------------------------------------------

enum Cell { Null, False, True, Num { v: f64 }, Ref { r: Val..&<u32 in vals> } }
struct Ent { key: u8[varint], val: Cell }
enum Val {
    Str { s: u8[varint] },
    Arr { items: Cell[varint] },
    Obj { ents: Ent[varint] },
}

var vals: Val..[>..] = [];

// Scratch stacks. Every user takes a mark, pushes above it, and resizes back.
var outs: Cell[>..<] = [];          // filter outputs, and array items while parsing
struct KS { cell: Cell, ks: u32, kl: u32 }
var ks: KS[>..<] = [];              // object entries under construction
var keytext: u8[>..<] = [];         // their key bytes
var sb: u8[>..<] = [];              // string bytes under construction

fn num(v: f64) -> Cell { Cell.Num { v: v } }
fn boolc(b: bool) -> Cell { if b { Cell.True } else { Cell.False } }
fn truthy(c: Cell) -> bool { match c { Null, False => false, _ => true } }

fn new_str(s: const u8[:]) -> Cell { Cell.Ref { r: vals.push(Val.Str { s: s }) } }

// The cells of outs[m..], as a new array value.
fn new_arr(m: i64) -> Cell { Cell.Ref { r: vals.push(Val.Arr { items: outs[m..] }) } }

fn mk_ents(m: i64) -> Ent[>..] {
    var r: Ent[>..] = [];
    for i in m..ks.len {
        let k = ks[i];
        let a: i64 = k.ks;
        let b: i64 = a + k.kl;
        r.push(Ent { key: keytext[a..b], val: k.cell });
    }
    r
}

// The entries ks[m..] as a new object value. Later duplicates of a key replace
// the earlier value and keep its position, as in jq.
fn new_obj(m: i64, km: i64) -> Cell {
    if ks.len - m > 1 { dedup_keys(m); }
    let c = Cell.Ref { r: vals.push(Val.Obj { ents: mk_ents(m) }) };
    ks.resize(m);
    keytext.resize(km);
    c
}

fn key_of(k: KS) -> const u8[:] {
    let a: i64 = k.ks;
    let b: i64 = a + k.kl;
    keytext[a..b]
}

fn dedup_keys(m: i64) {
    let n = ks.len - m;
    if n <= 8 {
        var w = m;
        for i in m..ks.len {
            var found = -1;
            for j in m..w { if key_of(ks[j]) == key_of(ks[i]) { found = j; break; } }
            if found >= 0 { ks[found].cell = ks[i].cell; } else { ks[w] = ks[i]; w++; }
        }
        ks.resize(w);
        return;
    }
    var seen = dictionary<u64, i64> {};
    seen.reserve(n);
    var w = m;
    for i in m..ks.len {
        // Keyed by the key's byte span; a hash collision is checked by bytes.
        let h = hash(key_of(ks[i]));
        var found = -1;
        var hh = h;
        loop {
            let at = seen.get(hh);
            guard at else { break; }
            if key_of(ks[at]) == key_of(ks[i]) { found = at; break; }
            hh = hh + 0x9E3779B97F4A7C15;
        }
        if found >= 0 { ks[found].cell = ks[i].cell; }
        else { seen.insert(hh, w); ks[w] = ks[i]; w++; }
    }
    ks.resize(w);
}

fn push_key(k: const u8[:], c: Cell) {
    let a = keytext.len;
    keytext.append(k);
    ks.push(KS { cell: c, ks: a as u32, kl: k.len as u32 });
}

fn kind(c: Cell) -> i64 {
    match c {
        Null => 0, False => 1, True => 2, Num => 3,
        Ref r => match r.r { Str => 4, Arr => 5, Obj => 6 },
    }
}

fn nval(c: Cell) -> f64 { match c { Num n => n.v, _ => abort("number expected") } }

fn sval(c: Cell) -> const u8[:] {
    match c {
        Ref r => match r.r { Str &s => s.s, _ => abort("string expected") },
        _ => abort("string expected"),
    }
}

// --- ordering and equality (jq's: null < false < true < numbers < strings < arrays < objects)

recursive fn cmpv(a: Cell, b: Cell) -> i64 {
    let ka = kind(a);
    let kb = kind(b);
    if ka != kb { return if ka < kb { -1 } else { 1 }; }
    if ka == 3 {
        let x = nval(a);
        let y = nval(b);
        return if x < y { -1 } else if x > y { 1 } else { 0 };
    }
    if ka == 4 { return compare(sval(a), sval(b)); }
    if ka == 5 { return cmp_arr(a, b); }
    if ka == 6 { return cmp_obj(a, b); }
    return 0;
}

recursive fn cmp_arr(a: Cell, b: Cell) -> i64 {
    match a {
        Ref ra => match ra.r {
            Arr &x => match b {
                Ref rb => match rb.r {
                    Arr &y => {
                        let n = min(x.items.len, y.items.len);
                        for i in n {
                            let c = cmpv(x.items[i], y.items[i]);
                            if c != 0 { return c; }
                        }
                        return if x.items.len < y.items.len { -1 } else if x.items.len > y.items.len { 1 } else { 0 };
                    },
                    _ => 0,
                },
                _ => 0,
            },
            _ => 0,
        },
        _ => 0,
    }
}

// Objects compare by their sorted key lists, then by the values in key order.
// Only equality is needed by the filters measured here.
recursive fn cmp_obj(a: Cell, b: Cell) -> i64 {
    match a {
        Ref ra => match ra.r {
            Obj &x => match b {
                Ref rb => match rb.r {
                    Obj &y => {
                        if x.ents.len != y.ents.len { return if x.ents.len < y.ents.len { -1 } else { 1 }; }
                        for e in x.ents {
                            var hit = false;
                            for f in y.ents {
                                if f.key == e.key {
                                    hit = true;
                                    let c = cmpv(e.val, f.val);
                                    if c != 0 { return c; }
                                    break;
                                }
                            }
                            if !hit { abort("ordering of objects with different keys is not supported"); }
                        }
                        return 0;
                    },
                    _ => 0,
                },
                _ => 0,
            },
            _ => 0,
        },
        _ => 0,
    }
}

// --- JSON text in --------------------------------------------------------------

struct JP { src: const u8[:], pos: i64 }

fn ws(p: JP&) {
    while p.pos < p.src.len {
        let c = p.src[p.pos];
        if c == ' ' || c == '\n' || c == '\t' || c == '\r' { p.pos++; } else { break; }
    }
}

// The length of the valid UTF-8 sequence at s[i] (s[i] >= 0x80), as jq checks
// every input string; aborts on an invalid one (jq would substitute U+FFFD).
fn utf8_len(s: const u8[:], i: i64) -> i64 {
    let c = s[i];
    var n = 0;
    var lo: u8 = 0x80;
    var hi: u8 = 0xBF;
    if c >= 0xC2 && c <= 0xDF { n = 2; }
    else if c >= 0xE0 && c <= 0xEF { n = 3; if c == 0xE0 { lo = 0xA0; } if c == 0xED { hi = 0x9F; } }
    else if c >= 0xF0 && c <= 0xF4 { n = 4; if c == 0xF0 { lo = 0x90; } if c == 0xF4 { hi = 0x8F; } }
    else { abort("invalid UTF-8 in input"); }
    guard i + n <= s.len else { abort("invalid UTF-8 in input"); }
    let c1 = s[i + 1];
    guard c1 >= lo && c1 <= hi else { abort("invalid UTF-8 in input"); }
    for k in 2..n { let ck = s[i + k]; guard ck >= 0x80 && ck <= 0xBF else { abort("invalid UTF-8 in input"); } }
    n
}

fn hexv(c: u8) -> i64 {
    if c >= '0' && c <= '9' { return c - '0'; }
    if c >= 'a' && c <= 'f' { return c - 'a' + 10; }
    if c >= 'A' && c <= 'F' { return c - 'A' + 10; }
    abort("bad \\u escape")
}

fn hex4(p: JP&) -> i64 {
    guard p.pos + 4 <= p.src.len else { abort("short \\u escape"); }
    var v = 0;
    for i in 4 { v = v * 16 + hexv(p.src[p.pos + i]); }
    p.pos += 4;
    v
}

// Decodes the string at p.pos (just after its opening quote) onto sb[mark..],
// or returns the span of the raw text when it holds no escape.
fn scan_string(p: JP&) -> i64, i64, bool {
    let start = p.pos;
    while p.pos < p.src.len {
        let c = p.src[p.pos];
        if c == '"' { p.pos++; return start, p.pos - 1, false; }
        if c == '\\' { break; }
        if c >= 0x80 { p.pos += utf8_len(p.src, p.pos); continue; }
        p.pos++;
    }
    guard p.pos < p.src.len else { abort("unterminated string"); }
    sb.append(p.src[start..p.pos]);
    loop {
        guard p.pos < p.src.len else { abort("unterminated string"); }
        let c = p.src[p.pos];
        p.pos++;
        if c == '"' { break; }
        if c >= 0x80 {
            let k = utf8_len(p.src, p.pos - 1);
            sb.append(p.src[p.pos - 1..p.pos - 1 + k]);
            p.pos += k - 1;
            continue;
        }
        if c != '\\' { sb.push(c); continue; }
        guard p.pos < p.src.len else { abort("unterminated string"); }
        let e = p.src[p.pos];
        p.pos++;
        match e {
            'n' => sb.push('\n'), 't' => sb.push('\t'), 'r' => sb.push('\r'),
            'b' => sb.push(8), 'f' => sb.push(12),
            'u' => {
                var cp = hex4(p);
                if cp >= 0xD800 && cp < 0xDC00 && p.pos + 1 < p.src.len && p.src[p.pos] == '\\' && p.src[p.pos + 1] == 'u' {
                    p.pos += 2;
                    let lo = hex4(p);
                    if lo >= 0xDC00 && lo < 0xE000 { cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00); }
                    else { push_cp(0xFFFD); cp = lo; }
                }
                if cp >= 0xD800 && cp < 0xE000 { cp = 0xFFFD; }
                push_cp(cp);
            },
            _ => sb.push(e),
        }
    }
    return 0, 0, true;
}

fn push_cp(cp: i64) {
    if cp < 0x80 { sb.push(cp as! u8); }
    else if cp < 0x800 { sb.push((0xC0 | (cp >> 6)) as! u8); sb.push((0x80 | (cp & 63)) as! u8); }
    else if cp < 0x10000 {
        sb.push((0xE0 | (cp >> 12)) as! u8); sb.push((0x80 | ((cp >> 6) & 63)) as! u8); sb.push((0x80 | (cp & 63)) as! u8);
    } else {
        sb.push((0xF0 | (cp >> 18)) as! u8); sb.push((0x80 | ((cp >> 12) & 63)) as! u8);
        sb.push((0x80 | ((cp >> 6) & 63)) as! u8); sb.push((0x80 | (cp & 63)) as! u8);
    }
}

fn parse_str_val(p: JP&) -> Cell {
    let m = sb.len;
    let a, b, esc = scan_string(p);
    if !esc { return new_str(p.src[a..b]); }
    let c = new_str(sb[m..]);
    sb.resize(m);
    c
}

fn parse_num(p: JP&) -> Cell {
    let start = p.pos;
    var neg = false;
    if p.src[p.pos] == '-' { neg = true; p.pos++; }
    var v: i64 = 0;
    var digits = 0;
    while p.pos < p.src.len && p.src[p.pos] >= '0' && p.src[p.pos] <= '9' {
        v = v * 10 + (p.src[p.pos] - '0');
        p.pos++;
        digits++;
    }
    var simple = digits > 0 && digits <= 15;
    while p.pos < p.src.len {
        let c = p.src[p.pos];
        if (c >= '0' && c <= '9') || c == '.' || c == 'e' || c == 'E' || c == '+' || c == '-' { simple = false; p.pos++; }
        else { break; }
    }
    if simple { return num(if neg { -(v as f64) } else { v as f64 }); }
    let f, ok = parse_flt(p.src[start..p.pos]);
    guard ok else { abort("bad number"); }
    num(f)
}

recursive fn parse_value(p: JP&) -> Cell {
    ws(p);
    guard p.pos < p.src.len else { abort("unexpected end of JSON"); }
    let c = p.src[p.pos];
    if c == '{' {
        p.pos++;
        let m = ks.len;
        let km = keytext.len;
        ws(p);
        if p.pos < p.src.len && p.src[p.pos] == '}' { p.pos++; return new_obj(m, km); }
        loop {
            ws(p);
            guard p.pos < p.src.len && p.src[p.pos] == '"' else { abort("object key expected"); }
            p.pos++;
            let ka = keytext.len;
            let sm = sb.len;
            let a, b, esc = scan_string(p);
            if esc { keytext.append(sb[sm..]); sb.resize(sm); } else { keytext.append(p.src[a..b]); }
            let kl = keytext.len - ka;
            ws(p);
            guard p.pos < p.src.len && p.src[p.pos] == ':' else { abort("':' expected"); }
            p.pos++;
            let v = parse_value(p);
            ks.push(KS { cell: v, ks: ka as u32, kl: kl as u32 });
            ws(p);
            guard p.pos < p.src.len else { abort("unterminated object"); }
            if p.src[p.pos] == ',' { p.pos++; continue; }
            if p.src[p.pos] == '}' { p.pos++; break; }
            abort("',' or '}' expected");
        }
        return new_obj(m, km);
    }
    if c == '[' {
        p.pos++;
        let m = outs.len;
        ws(p);
        if p.pos < p.src.len && p.src[p.pos] == ']' { p.pos++; return new_arr(m); }
        loop {
            let v = parse_value(p);
            outs.push(v);
            ws(p);
            guard p.pos < p.src.len else { abort("unterminated array"); }
            if p.src[p.pos] == ',' { p.pos++; continue; }
            if p.src[p.pos] == ']' { p.pos++; break; }
            abort("',' or ']' expected");
        }
        let r = new_arr(m);
        outs.resize(m);
        return r;
    }
    if c == '"' { p.pos++; return parse_str_val(p); }
    if c == 't' { p.pos += 4; return Cell.True; }
    if c == 'f' { p.pos += 5; return Cell.False; }
    if c == 'n' { p.pos += 4; return Cell.Null; }
    return parse_num(p);
}

// --- JSON text out -------------------------------------------------------------

let HEX = "0123456789abcdef";

fn emit_str(out: u8[>..<]&, s: const u8[:]) {
    out.push('"');
    var run = 0;
    for c, i in s {
        if c >= 0x20 && c != '"' && c != '\\' && c != 0x7F { continue; }
        out.append(s[run..i]);
        run = i + 1;
        match c {
            '"' => out.append("\\\""), '\\' => out.append("\\\\"),
            '\n' => out.append("\\n"), '\t' => out.append("\\t"), '\r' => out.append("\\r"),
            8 => out.append("\\b"), 12 => out.append("\\f"),
            _ => { out.append("\\u00"); out.push(HEX[c >> 4]); out.push(HEX[c & 15]); },
        }
    }
    out.append(s[run..]);
    out.push('"');
}

fn emit_num(out: u8[>..<]&, v: f64) {
    if v == floor(v) && v < 1e17 && v > -1e17 {
        let i = v as i64;
        if i == 0 && 1.0 / v < 0 { out.append("-0"); return; }
        format_int(out, i, 10, 0, ' ');
        return;
    }
    if is_nan(v) { out.append("null"); return; }
    if is_inf(v) { out.append(if v > 0 { "1.7976931348623157e+308" } else { "-1.7976931348623157e+308" }); return; }
    format(out, v);
}

recursive fn emit(out: u8[>..<]&, c: Cell) {
    match c {
        Null => out.append("null"),
        False => out.append("false"),
        True => out.append("true"),
        Num n => emit_num(out, n.v),
        Ref r => match r.r {
            Str &s => emit_str(out, s.s),
            Arr &a => {
                out.push('[');
                for x, i in a.items { if i > 0 { out.push(','); } emit(out, x); }
                out.push(']');
            },
            Obj &o => {
                out.push('{');
                var first = true;
                for e in o.ents {
                    if !first { out.push(','); }
                    first = false;
                    emit_str(out, e.key);
                    out.push(':');
                    emit(out, e.val);
                }
                out.push('}');
            },
        },
    }
}

// --- the filter language: syntax tree ------------------------------------------

// Builtins implemented natively.
let B_LENGTH = 0; let B_NOT = 1; let B_EMPTY = 2; let B_RANGE1 = 3; let B_RANGE2 = 4;
let B_REVERSE = 5; let B_SORT = 6; let B_MIN = 7; let B_MAX = 8; let B_ADD = 9;
let B_TOSTRING = 10; let B_TOJSON = 11; let B_FROMJSON = 12; let B_JOIN = 13; let B_LAST = 14;
let B_GROUP_BY = 15; let B_TYPE = 16; let B_SELECT = 17; let B_STRINGS = 18; let B_NUMBERS = 19;
let B_RECURSE = 20; let B_FIRST = 21; let B_RANGE3 = 22; let B_CEIL = 23; let B_FLOOR = 24;
let B_KEYS = 25; let B_ARRAYS = 26; let B_OBJECTS = 27;

struct OE { k: Ast..&<u32 in ast>, v: Ast..&<u32 in ast> }

enum Ast {
    Ident,
    Recurse,
    Lit { c: Cell },                                   // null, true, false, numbers
    LitStr { s: u8[varint] },
    Field { t: Ast..&<u32 in ast>, name: u8[varint] },
    Index { t: Ast..&<u32 in ast>, i: Ast..&<u32 in ast> },
    Slice { t: Ast..&<u32 in ast>, a: Ast..&<u32 in ast>?, b: Ast..&<u32 in ast>? },
    Iter { t: Ast..&<u32 in ast> },
    Pipe { l: Ast..&<u32 in ast>, r: Ast..&<u32 in ast> },
    Comma { l: Ast..&<u32 in ast>, r: Ast..&<u32 in ast> },
    Neg { e: Ast..&<u32 in ast> },
    Bin { op: u8, l: Ast..&<u32 in ast>, r: Ast..&<u32 in ast> },
    And { l: Ast..&<u32 in ast>, r: Ast..&<u32 in ast> },
    Or { l: Ast..&<u32 in ast>, r: Ast..&<u32 in ast> },
    Alt { l: Ast..&<u32 in ast>, r: Ast..&<u32 in ast> },
    Collect { e: Ast..&<u32 in ast> },
    ObjCons { ents: OE[varint] },
    If { c: Ast..&<u32 in ast>, t: Ast..&<u32 in ast>, e: Ast..&<u32 in ast> },
    Reduce { src: Ast..&<u32 in ast>, vid: i32, init: Ast..&<u32 in ast>, upd: Ast..&<u32 in ast> },
    Foreach { src: Ast..&<u32 in ast>, vid: i32, init: Ast..&<u32 in ast>, upd: Ast..&<u32 in ast>,
              ext: Ast..&<u32 in ast>? },
    As { src: Ast..&<u32 in ast>, vid: i32, body: Ast..&<u32 in ast> },
    Var { id: i32 },
    Call { fid: i32, args: (Ast..&<u32 in ast>)[varint] },
    Builtin { id: i32, args: (Ast..&<u32 in ast>)[varint] },
}

var ast: Ast..[>..] = [];
var astk: (Ast..&<u32 in ast>)[>..<] = [];    // argument lists under construction
var oes: OE[>..<] = [];

struct Def { np: i32, p: i32[8], body: Ast..&<u32 in ast>? }
var defs: Def[>..] = [];
var nvars: i32 = 0;

// Names in scope while parsing: variables (kind 0) and definitions (kind 1).
struct Sc { name: u8[..32], kind: u8, id: i32, arity: i32 }
var scope: Sc[>..<] = [];

// --- the filter language: parser -----------------------------------------------

var src: u8[>..] = [];
var sp = 0;

fn fail(what: const u8[:]) { abort(str("filter syntax: ", what, " at byte ", sp, " in: ", src)); }

fn skipws() {
    while sp < src.len {
        let c = src[sp];
        if c == ' ' || c == '\n' || c == '\t' || c == '\r' { sp++; }
        else if c == '#' { while sp < src.len && src[sp] != '\n' { sp++; } }
        else { break; }
    }
}

fn is_id0(c: u8) -> bool { (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' }
fn is_id(c: u8) -> bool { is_id0(c) || (c >= '0' && c <= '9') }

fn peekc() -> u8 { skipws(); if sp < src.len { src[sp] } else { 0 } }
fn peek2() -> u8 { if sp + 1 < src.len { src[sp + 1] } else { 0 } }

fn eat(s: const u8[:]) -> bool {
    skipws();
    if sp + s.len <= src.len && src[sp..sp + s.len] == s { sp += s.len; return true; }
    return false;
}

fn expect(s: const u8[:]) { if !eat(s) { fail(str("expected '", s, "'")); } }

// The identifier at sp, without consuming it; empty if none.
fn ident_at() -> const u8[:] {
    skipws();
    guard sp < src.len && is_id0(src[sp]) else { return src[sp..sp]; }
    var e = sp + 1;
    while e < src.len && is_id(src[e]) { e++; }
    src[sp..e]
}

fn eat_kw(k: const u8[:]) -> bool {
    let w = ident_at();
    if w == k { sp += k.len; return true; }
    return false;
}

fn take_ident() -> u8[..32] {
    let w = ident_at();
    guard w.len > 0 && w.len <= 32 else { fail("identifier expected"); }
    sp += w.len;
    var n: u8[..32] = [];
    n.append(w);
    n
}

fn take_var() -> u8[..32] {
    skipws();
    guard sp < src.len && src[sp] == '$' else { fail("'$name' expected"); }
    sp++;
    take_ident()
}

fn bind_var(name: u8[..32]) -> i32 {
    let id = nvars;
    nvars += 1;
    scope.push(Sc { name: name, kind: 0, id: id, arity: 0 });
    id
}

fn lookup(name: const u8[:], kind: u8, arity: i32) -> i32 {
    var i = scope.len - 1;
    while i >= 0 {
        let s = scope[i];
        if s.kind == kind && s.arity == arity && s.name == name { return s.id; }
        i--;
    }
    return -1;
}

fn node(a: Ast..&) -> Ast..& { a }

fn lit_string() -> Ast..& {
    // At an opening quote: a plain string literal, no interpolation.
    sp++;
    let m = sb.len;
    var p = JP { src: src[..], pos: sp };
    let a, b, esc = scan_string(p);
    sp = p.pos;
    if !esc { return ast.push(Ast.LitStr { s: src[a..b] }); }
    let r .= ast.push(Ast.LitStr { s: sb[m..] });
    sb.resize(m);
    r
}

struct BI { name: u8[..12], arity: i32, id: i32 }
let BUILTINS: BI[28] = [
    BI { "length", 0, B_LENGTH }, BI { "not", 0, B_NOT }, BI { "empty", 0, B_EMPTY },
    BI { "range", 1, B_RANGE1 }, BI { "range", 2, B_RANGE2 }, BI { "range", 3, B_RANGE3 },
    BI { "reverse", 0, B_REVERSE }, BI { "sort", 0, B_SORT }, BI { "min", 0, B_MIN },
    BI { "max", 0, B_MAX }, BI { "add", 0, B_ADD }, BI { "tostring", 0, B_TOSTRING },
    BI { "tojson", 0, B_TOJSON }, BI { "fromjson", 0, B_FROMJSON }, BI { "join", 1, B_JOIN },
    BI { "last", 1, B_LAST }, BI { "first", 1, B_FIRST }, BI { "group_by", 1, B_GROUP_BY },
    BI { "type", 0, B_TYPE }, BI { "select", 1, B_SELECT }, BI { "strings", 0, B_STRINGS },
    BI { "numbers", 0, B_NUMBERS }, BI { "arrays", 0, B_ARRAYS }, BI { "objects", 0, B_OBJECTS },
    BI { "recurse", 0, B_RECURSE }, BI { "ceil", 0, B_CEIL }, BI { "floor", 0, B_FLOOR },
    BI { "keys", 0, B_KEYS },
];

recursive fn p_pipe() -> Ast..& {
    if eat_kw("def") {
        let name = take_ident();
        var d = Def { np: 0, p: [0; 8], body: null };
        let sm = scope.len;
        var params: u8[..32][..8] = [];
        if eat("(") {
            loop {
                params.push(take_var());
                if eat(";") { continue; }
                expect(")");
                break;
            }
        }
        let fid = defs.len as i32;
        d.np = params.len as i32;
        defs.push(d);
        // The definition is visible in its own body (recursion) and after it.
        scope.push(Sc { name: name, kind: 1, id: fid, arity: d.np });
        let inner = scope.len;
        for pn, i in params { defs[fid].p[i] = bind_var(pn); }
        expect(":");
        let body .= p_pipe();
        expect(";");
        defs[fid].body .= body;
        scope.resize(inner);
        let rest .= p_pipe();
        scope.resize(sm);
        return rest;
    }
    // `Term as $x | body`
    let save = sp;
    if peekc() == '-' { return p_pipe_rest(); }
    let t .= p_postfix();
    if eat_kw("as") {
        let sm = scope.len;
        let name = take_var();
        let id = bind_var(name);
        expect("|");
        let body .= p_pipe();
        scope.resize(sm);
        return ast.push(Ast.As { src: t, vid: id, body: body });
    }
    sp = save;
    return p_pipe_rest();
}

recursive fn p_pipe_rest() -> Ast..& {
    let l .= p_comma();
    if peekc() == '|' && peek2() != '=' {
        sp++;
        let r .= p_pipe();
        return ast.push(Ast.Pipe { l: l, r: r });
    }
    return l;
}

recursive fn p_comma() -> Ast..& {
    var l .= p_alt();
    while peekc() == ',' {
        sp++;
        let r .= p_alt();
        l .= ast.push(Ast.Comma { l: l, r: r });
    }
    return l;
}

recursive fn p_alt() -> Ast..& {
    let l .= p_or();
    if eat("//") {
        let r .= p_alt();
        return ast.push(Ast.Alt { l: l, r: r });
    }
    return l;
}

recursive fn p_or() -> Ast..& {
    var l .= p_and();
    while eat_kw("or") {
        let r .= p_and();
        l .= ast.push(Ast.Or { l: l, r: r });
    }
    return l;
}

recursive fn p_and() -> Ast..& {
    var l .= p_cmp();
    while eat_kw("and") {
        let r .= p_cmp();
        l .= ast.push(Ast.And { l: l, r: r });
    }
    return l;
}

recursive fn p_cmp() -> Ast..& {
    let l .= p_add();
    var op: u8 = 0;
    if eat("==") { op = 'e'; }
    else if eat("!=") { op = 'n'; }
    else if eat("<=") { op = 'l'; }
    else if eat(">=") { op = 'g'; }
    else if peekc() == '<' { sp++; op = '<'; }
    else if peekc() == '>' { sp++; op = '>'; }
    if op == 0 { return l; }
    let r .= p_add();
    return ast.push(Ast.Bin { op: op, l: l, r: r });
}

recursive fn p_add() -> Ast..& {
    var l .= p_mul();
    loop {
        let c = peekc();
        if (c == '+' || c == '-') && peek2() != '=' {
            sp++;
            let r .= p_mul();
            l .= ast.push(Ast.Bin { op: c, l: l, r: r });
        } else { break; }
    }
    return l;
}

recursive fn p_mul() -> Ast..& {
    var l .= p_unary();
    loop {
        let c = peekc();
        if (c == '*' || c == '%' || (c == '/' && peek2() != '/')) && peek2() != '=' {
            sp++;
            let r .= p_unary();
            l .= ast.push(Ast.Bin { op: c, l: l, r: r });
        } else { break; }
    }
    return l;
}

recursive fn p_unary() -> Ast..& {
    if peekc() == '-' {
        sp++;
        let e .= p_postfix();
        return ast.push(Ast.Neg { e: e });
    }
    return p_postfix();
}

// After `[` of an index: `]`, `e]`, `e:]`, `:e]`, `e:e]`.
recursive fn p_bracket(t: Ast..&) -> Ast..& {
    if eat("]") { return ast.push(Ast.Iter { t: t }); }
    if eat(":") {
        let b .= p_pipe();
        expect("]");
        return ast.push(Ast.Slice { t: t, a: null, b: b });
    }
    let i .= p_pipe();
    if eat(":") {
        if eat("]") { return ast.push(Ast.Slice { t: t, a: i, b: null }); }
        let b .= p_pipe();
        expect("]");
        return ast.push(Ast.Slice { t: t, a: i, b: b });
    }
    expect("]");
    return ast.push(Ast.Index { t: t, i: i });
}

recursive fn p_postfix() -> Ast..& {
    var t .= p_primary();
    loop {
        let c = peekc();
        if c == '[' { sp++; t .= p_bracket(t); continue; }
        if c == '.' && sp + 1 < src.len && src[sp + 1] == '[' { sp += 2; t .= p_bracket(t); continue; }
        if c == '.' && sp + 1 < src.len && (is_id0(src[sp + 1]) || src[sp + 1] == '"') {
            sp++;
            t .= p_field(t);
            continue;
        }
        if c == '?' { fail("'?' is not supported"); }
        break;
    }
    return t;
}

// After the `.` of `.name` or `."name"`.
fn p_field(t: Ast..&) -> Ast..& {
    if sp < src.len && src[sp] == '"' {
        sp++;
        let m = sb.len;
        var p = JP { src: src[..], pos: sp };
        let a, b, esc = scan_string(p);
        sp = p.pos;
        if !esc { return ast.push(Ast.Field { t: t, name: src[a..b] }); }
        let r .= ast.push(Ast.Field { t: t, name: sb[m..] });
        sb.resize(m);
        return r;
    }
    let w = ident_at();
    sp += w.len;
    return ast.push(Ast.Field { t: t, name: w });
}

recursive fn p_args(n: i64) -> i64 {
    // Parses `(a; b; ...)` if present, pushing each onto astk; returns the count.
    if !eat("(") { return 0; }
    var k = 0;
    loop {
        let a .= p_pipe();
        astk.push(a);
        k++;
        if eat(";") { continue; }
        expect(")");
        break;
    }
    return k + n - n;
}

recursive fn p_object() -> Ast..& {
    let m = oes.len;
    if eat("}") { return ast.push(Ast.ObjCons { ents: oes[m..] }); }
    loop {
        let k, v = p_entry();
        oes.push(OE { k: k, v: v });
        if eat(",") { continue; }
        expect("}");
        break;
    }
    let r .= ast.push(Ast.ObjCons { ents: oes[m..] });
    oes.resize(m);
    return r;
}

// An object value: alternatives joined by pipes, but no commas.
recursive fn p_objval() -> Ast..& {
    var v .= p_alt();
    while peekc() == '|' && peek2() != '=' {
        sp++;
        let r .= p_alt();
        v .= ast.push(Ast.Pipe { l: v, r: r });
    }
    return v;
}

recursive fn p_entry() -> Ast..&, Ast..& {
    skipws();
    if sp < src.len && src[sp] == '"' {
        let k .= lit_string();
        if eat(":") { let v .= p_objval(); return k, v; }
        let v .= ast.push(Ast.Field { t: ident_node(), name: litstr_text(k) });
        return k, v;
    }
    if sp < src.len && src[sp] == '(' {
        sp++;
        let k .= p_pipe();
        expect(")");
        expect(":");
        let v .= p_objval();
        return k, v;
    }
    if sp < src.len && src[sp] == '$' {
        let name = take_var();
        let id = lookup(name, 0, 0);
        if id < 0 { fail("unknown variable"); }
        let k .= ast.push(Ast.LitStr { s: name });
        let v .= ast.push(Ast.Var { id: id });
        return k, v;
    }
    let w = take_ident();
    let k .= ast.push(Ast.LitStr { s: w });
    if eat(":") { let v .= p_objval(); return k, v; }
    let v .= ast.push(Ast.Field { t: ident_node(), name: w });
    return k, v;
}

fn litstr_text(k: Ast..&) -> const u8[:] {
    match k { LitStr &s => s.s, _ => abort("string literal expected") }
}

var ident_cache: Ast..&<u32 in ast>? = null;
fn ident_node() -> Ast..& {
    let c: Ast..? = ident_cache;
    guard c else { abort("no identity node"); }
    return c;
}

recursive fn p_primary() -> Ast..& {
    let c = peekc();
    if c == '.' {
        sp++;
        if sp < src.len && src[sp] == '.' { sp++; return ast.push(Ast.Recurse); }
        if sp < src.len && (is_id0(src[sp]) || src[sp] == '"') { return p_field(ident_node()); }
        return ident_node();
    }
    if c >= '0' && c <= '9' {
        let start = sp;
        while sp < src.len && (is_id(src[sp]) || src[sp] == '.' ||
                               ((src[sp] == '+' || src[sp] == '-') && (src[sp - 1] == 'e' || src[sp - 1] == 'E'))) { sp++; }
        let f, ok = parse_flt(src[start..sp]);
        if !ok { fail("bad number"); }
        return ast.push(Ast.Lit { c: num(f) });
    }
    if c == '"' { return lit_string(); }
    if c == '$' {
        let name = take_var();
        let id = lookup(name, 0, 0);
        if id < 0 { fail("unknown variable"); }
        return ast.push(Ast.Var { id: id });
    }
    if c == '(' {
        sp++;
        let e .= p_pipe();
        expect(")");
        return e;
    }
    if c == '[' {
        sp++;
        if eat("]") {
            let m = astk.len;
            let e .= ast.push(Ast.Builtin { id: B_EMPTY, args: astk[m..] });
            return ast.push(Ast.Collect { e: e });
        }
        let e .= p_pipe();
        expect("]");
        return ast.push(Ast.Collect { e: e });
    }
    if c == '{' { sp++; return p_object(); }
    if eat_kw("if") {
        let cnd .= p_pipe();
        if !eat_kw("then") { fail("'then' expected"); }
        let t .= p_pipe();
        return p_if_rest(cnd, t);
    }
    if eat_kw("reduce") {
        let s .= p_postfix();
        if !eat_kw("as") { fail("'as' expected"); }
        let sm = scope.len;
        let id = bind_var(take_var());
        expect("(");
        let init .= p_pipe();
        expect(";");
        let upd .= p_pipe();
        expect(")");
        scope.resize(sm);
        return ast.push(Ast.Reduce { src: s, vid: id, init: init, upd: upd });
    }
    if eat_kw("foreach") {
        let s .= p_postfix();
        if !eat_kw("as") { fail("'as' expected"); }
        let sm = scope.len;
        let id = bind_var(take_var());
        expect("(");
        let init .= p_pipe();
        expect(";");
        let upd .= p_pipe();
        if eat(";") {
            let ext .= p_pipe();
            expect(")");
            scope.resize(sm);
            return ast.push(Ast.Foreach { src: s, vid: id, init: init, upd: upd, ext: ext });
        }
        expect(")");
        scope.resize(sm);
        return ast.push(Ast.Foreach { src: s, vid: id, init: init, upd: upd, ext: null });
    }
    if eat_kw("null") { return ast.push(Ast.Lit { c: Cell.Null }); }
    if eat_kw("true") { return ast.push(Ast.Lit { c: Cell.True }); }
    if eat_kw("false") { return ast.push(Ast.Lit { c: Cell.False }); }
    let w = ident_at();
    if w.len == 0 { fail("term expected"); }
    let name = take_ident();
    let m = astk.len;
    let n = p_args(0);
    if name == "map" && n == 1 {
        // map(f) is [.[] | f]
        let f .= astk[m];
        astk.resize(m);
        let it .= ast.push(Ast.Iter { t: ident_node() });
        let pf .= ast.push(Ast.Pipe { l: it, r: f });
        return ast.push(Ast.Collect { e: pf });
    }
    let fid = lookup(name, 1, n as i32);
    if fid >= 0 {
        let r .= ast.push(Ast.Call { fid: fid, args: astk[m..] });
        astk.resize(m);
        return r;
    }
    for b in BUILTINS {
        if b.name == name && b.arity == n {
            let r .= ast.push(Ast.Builtin { id: b.id, args: astk[m..] });
            astk.resize(m);
            return r;
        }
    }
    fail(str("unknown function ", name, "/", n))
}

recursive fn p_if_rest(cnd: Ast..&, t: Ast..&) -> Ast..& {
    if eat_kw("elif") {
        let c2 .= p_pipe();
        if !eat_kw("then") { fail("'then' expected"); }
        let t2 .= p_pipe();
        let e .= p_if_rest(c2, t2);
        return ast.push(Ast.If { c: cnd, t: t, e: e });
    }
    if eat_kw("else") {
        let e .= p_pipe();
        if !eat_kw("end") { fail("'end' expected"); }
        return ast.push(Ast.If { c: cnd, t: t, e: e });
    }
    if !eat_kw("end") { fail("'end' expected"); }
    return ast.push(Ast.If { c: cnd, t: t, e: ident_node() });
}

// --- the evaluator --------------------------------------------------------------

var envid: i32[>..<] = [];
var envval: Cell[>..<] = [];

fn getvar(id: i32) -> Cell {
    var i = envid.len - 1;
    while i >= 0 { if envid[i] == id { return envval[i]; } i--; }
    abort("unbound variable")
}

// Moves outs[from..] down to outs[m..].
fn collapse(m: i64, from: i64) {
    if from == m { return; }
    var k = m;
    for i in from..outs.len { outs[k] = outs[i]; k++; }
    outs.resize(k);
}

var tb: u8[>..<] = [];             // text scratch: tojson, join, concatenation

fn concat_str(a: const u8[:], b: const u8[:]) -> Cell {
    let m = tb.len;
    tb.append(a);
    tb.append(b);
    let c = new_str(tb[m..]);
    tb.resize(m);
    c
}

fn arr_items(c: Cell) -> const Cell[:] {
    match c {
        Ref r => match r.r { Arr &a => a.items, _ => abort("array expected") },
        _ => abort("array expected"),
    }
}

fn is_arr(c: Cell) -> bool { kind(c) == 5 }
fn is_obj(c: Cell) -> bool { kind(c) == 6 }

// Appends the entries of object c onto ks/keytext.
fn push_ents(c: Cell) {
    match c {
        Ref r => match r.r { Obj &o => { for e in o.ents { push_key(e.key, e.val); } }, _ => abort("object expected") },
        _ => abort("object expected"),
    }
}

fn arith(op: u8, a: Cell, b: Cell) -> Cell {
    let ka = kind(a);
    let kb = kind(b);
    if op == '+' {
        if ka == 0 { return b; }
        if kb == 0 { return a; }
        if ka == 3 && kb == 3 { return num(nval(a) + nval(b)); }
        if ka == 4 && kb == 4 { return concat_str(sval(a), sval(b)); }
        if ka == 5 && kb == 5 {
            let m = outs.len;
            for x in arr_items(a) { outs.push(x); }
            for x in arr_items(b) { outs.push(x); }
            let r = new_arr(m);
            outs.resize(m);
            return r;
        }
        if ka == 6 && kb == 6 {
            let m = ks.len;
            let km = keytext.len;
            push_ents(a);
            push_ents(b);
            return new_obj(m, km);
        }
        abort("cannot add these types");
    }
    if op == '*' && ka == 4 && kb == 3 {
        let n = nval(b);
        if n <= 0 { return Cell.Null; }
        let m = tb.len;
        let s = sval(a);
        let k = ceil(n) as i64;
        for i in k { tb.append(s); }
        let c = new_str(tb[m..]);
        tb.resize(m);
        return c;
    }
    guard ka == 3 && kb == 3 else { abort(str("cannot apply ", op, " to these types")); }
    let x = nval(a);
    let y = nval(b);
    match op {
        '-' => num(x - y),
        '*' => num(x * y),
        '/' => { if y == 0 { abort("division by zero"); } num(x / y) },
        '%' => {
            let xi = x as i64;
            let yi = y as i64;
            if yi == 0 { abort("modulo by zero"); }
            let q = xi / yi;
            num(xi - q * yi)
        },
        _ => abort("bad operator"),
    }
}

fn compare_op(op: u8, a: Cell, b: Cell) -> Cell {
    let c = cmpv(a, b);
    boolc(match op {
        'e' => c == 0, 'n' => c != 0, '<' => c < 0, 'l' => c <= 0, '>' => c > 0, 'g' => c >= 0,
        _ => false,
    })
}

fn index_cell(t: Cell, i: Cell) -> Cell {
    let kt = kind(t);
    if kt == 0 { return Cell.Null; }
    if kt == 6 {
        let k = sval(i);
        match t {
            Ref r => match r.r { Obj &o => { for e in o.ents { if e.key == k { return e.val; } } }, _ => {} },
            _ => {},
        }
        return Cell.Null;
    }
    if kt == 5 {
        let items = arr_items(t);
        var j = floor(nval(i)) as i64;
        if j < 0 { j += items.len; }
        if j < 0 || j >= items.len { return Cell.Null; }
        return items[j];
    }
    abort("cannot index this value")
}

fn field(t: Cell, k: const u8[:]) -> Cell {
    match t {
        Null => Cell.Null,
        Ref r => match r.r {
            Obj &o => { for e in o.ents { if e.key == k { return e.val; } } Cell.Null },
            _ => abort(str("cannot index with \"", k, "\"")),
        },
        _ => abort(str("cannot index with \"", k, "\"")),
    }
}

fn clampi(v: i64, n: i64) -> i64 { if v < 0 { max(0, v + n) } else { min(v, n) } }

fn slice_cell(t: Cell, a: Cell, hasa: bool, b: Cell, hasb: bool) -> Cell {
    let kt = kind(t);
    if kt == 0 { return Cell.Null; }
    var n = 0;
    if kt == 4 { n = sval(t).len; } else if kt == 5 { n = arr_items(t).len; } else { abort("cannot slice"); }
    var lo = 0;
    var hi = n;
    if hasa && kind(a) == 3 { lo = clampi(floor(nval(a)) as i64, n); }
    if hasb && kind(b) == 3 { hi = clampi(ceil(nval(b)) as i64, n); }
    if hi < lo { hi = lo; }
    if kt == 4 { return new_str(sval(t)[lo..hi]); }
    return Cell.Ref { r: vals.push(Val.Arr { items: arr_items(t)[lo..hi] }) };
}

fn length_of(c: Cell) -> Cell {
    match c {
        Null => num(0),
        Num n => num(abs(n.v)),
        Ref r => match r.r {
            Str &s => { var k = 0; for b in s.s { if (b & 0xC0) != 0x80 { k++; } } num(k) },
            Arr &a => num(a.items.len),
            Obj &o => { var k = 0; for e in o.ents { k++; } num(k) },
        },
        _ => abort("boolean has no length"),
    }
}

fn type_name(c: Cell) -> const u8[:] {
    match kind(c) { 0 => "null", 1, 2 => "boolean", 3 => "number", 4 => "string", 5 => "array", _ => "object" }
}

fn tojson_cell(c: Cell) -> Cell {
    let m = tb.len;
    emit(tb, c);
    let r = new_str(tb[m..]);
    tb.resize(m);
    r
}

fn fromjson_cell(c: Cell) -> Cell {
    var p = JP { src: sval(c), pos: 0 };
    let v = parse_value(p);
    ws(p);
    if p.pos != p.src.len { abort("fromjson: trailing text"); }
    v
}

fn join_cell(c: Cell, sep: Cell) -> Cell {
    let s = sval(sep);
    let m = tb.len;
    for x, i in arr_items(c) {
        if i > 0 { tb.append(s); }
        match kind(x) {
            0 => {},
            4 => tb.append(sval(x)),
            3 => emit_num(tb, nval(x)),
            1 => tb.append("false"),
            2 => tb.append("true"),
            _ => abort("join: cannot join arrays or objects"),
        }
    }
    let r = new_str(tb[m..]);
    tb.resize(m);
    r
}

fn reverse_cell(c: Cell) -> Cell {
    if kind(c) == 0 { let m = outs.len; return new_arr(m); }
    if kind(c) == 4 {
        let m = tb.len;
        let s = sval(c);
        var i = s.len;
        while i > 0 {
            var j = i - 1;
            while j > 0 && (s[j] & 0xC0) == 0x80 { j--; }
            tb.append(s[j..i]);
            i = j;
        }
        let r = new_str(tb[m..]);
        tb.resize(m);
        return r;
    }
    let m = outs.len;
    let items = arr_items(c);
    var i = items.len;
    while i > 0 { i--; outs.push(items[i]); }
    let r = new_arr(m);
    outs.resize(m);
    r
}

fn all_nums(xs: const Cell[:]) -> bool {
    for x in xs { match x { Num => {}, _ => return false } }
    true
}

fn sort_cell(c: Cell) -> Cell {
    let m = outs.len;
    for x in arr_items(c) { outs.push(x); }
    let s = outs[m..];
    if all_nums(s) { stable_sort(s) { a, b => nval(a) < nval(b) }; }
    else { stable_sort(s) { a, b => cmpv(a, b) < 0 }; }
    let r = new_arr(m);
    outs.resize(m);
    r
}

fn minmax_cell(c: Cell, want_max: bool) -> Cell {
    let items = arr_items(c);
    if items.len == 0 { return Cell.Null; }
    var best = items[0];
    for x in items[1..] {
        let k = cmpv(x, best);
        if want_max { if k >= 0 { best = x; } } else { if k < 0 { best = x; } }
    }
    best
}

fn add_cell(c: Cell) -> Cell {
    let items = arr_items(c);
    if items.len == 0 { return Cell.Null; }
    if all_nums(items) {
        var t = 0.0;
        for x in items { t += nval(x); }
        return num(t);
    }
    // The first non-null item decides the kind; the rest join it in one pass.
    var k0 = 0;
    for x in items { k0 = kind(x); if k0 != 0 { break; } }
    if k0 == 0 { return Cell.Null; }
    if k0 == 5 {
        let m = outs.len;
        for x in items { if kind(x) == 5 { for y in arr_items(x) { outs.push(y); } } else if kind(x) != 0 { abort("cannot add") } }
        let r = new_arr(m);
        outs.resize(m);
        return r;
    }
    if k0 == 6 {
        let m = ks.len;
        let km = keytext.len;
        for x in items { if kind(x) == 6 { push_ents(x); } else if kind(x) != 0 { abort("cannot add") } }
        return new_obj(m, km);
    }
    if k0 == 4 {
        let m = tb.len;
        for x in items { if kind(x) == 4 { tb.append(sval(x)); } else if kind(x) != 0 { abort("cannot add") } }
        let r = new_str(tb[m..]);
        tb.resize(m);
        return r;
    }
    var acc = Cell.Null;
    for x in items { acc = arith('+', acc, x); }
    acc
}

fn keys_cell(c: Cell) -> Cell {
    let m = outs.len;
    match c {
        Ref r => match r.r { Obj &o => { for e in o.ents { { let c_ = new_str(e.key); outs.push(c_); } } }, _ => abort("keys: object expected") },
        _ => abort("keys: object expected"),
    }
    let s = outs[m..];
    stable_sort(s) { a, b => compare(sval(a), sval(b)) < 0 };
    let r = new_arr(m);
    outs.resize(m);
    r
}

recursive fn recurse_cell(c: Cell) {
    outs.push(c);
    match c {
        Ref r => match r.r {
            Arr &a => { for x in a.items { recurse_cell(x); } },
            Obj &o => { for e in o.ents { recurse_cell(e.val); } },
            _ => {},
        },
        _ => {},
    }
}

struct Pair { k: Cell, v: Cell }
var pairs: Pair[>..<] = [];

// One case function per syntax-tree variant: `ev(n, x)` on an `Ast..` dispatches
// on the tag, and each case keeps only its own locals in its native frame.
recursive fn ev(n: Ast.Ident&, x: Cell) {
    outs.push(x);
}

recursive fn ev(n: Ast.Recurse&, x: Cell) {
    recurse_cell(x);
}

recursive fn ev(l: Ast.Lit&, x: Cell) {
    outs.push(l.c);
}

recursive fn ev(s: Ast.LitStr&, x: Cell) {
    outs.push(new_str(s.s));
}

recursive fn ev(f: Ast.Field&, x: Cell) {
    let m = outs.len;
    ev(f.t, x);
    let e = outs.len;
    for i in m..e { { let c_ = field(outs[i], f.name); outs.push(c_); } }
    collapse(m, e);
}

recursive fn ev(f: Ast.Index&, x: Cell) {
    let m = outs.len;
    ev(f.i, x);
    let e1 = outs.len;
    ev(f.t, x);
    let e2 = outs.len;
    for j in m..e1 { for i in e1..e2 { { let c_ = index_cell(outs[i], outs[j]); outs.push(c_); } } }
    collapse(m, e2);
}

recursive fn ev(f: Ast.Slice&, x: Cell) {
    let m = outs.len;
    ev(f.t, x);
    let e1 = outs.len;
    var ca: Cell = Cell.Null;
    var cb: Cell = Cell.Null;
    let fa = f.a;
    if fa { ev(fa, x); ca = outs[outs.len - 1]; }
    let fb = f.b;
    if fb { ev(fb, x); cb = outs[outs.len - 1]; }
    let e2 = outs.len;
    let hasa = fa != null;
    let hasb = fb != null;
    for i in m..e1 { let c_ = slice_cell(outs[i], ca, hasa, cb, hasb); outs.push(c_); }
    collapse(m, e2);
}

recursive fn ev(f: Ast.Iter&, x: Cell) {
    let m = outs.len;
    ev(f.t, x);
    let e = outs.len;
    for i in m..e {
        let t = outs[i];
        match t {
            Ref r => match r.r {
                Arr &a => { for y in a.items { outs.push(y); } },
                Obj &o => { for en in o.ents { outs.push(en.val); } },
                _ => abort("cannot iterate over a string"),
            },
            _ => abort(str("cannot iterate over ", type_name(t))),
        }
    }
    collapse(m, e);
}

recursive fn ev(p: Ast.Pipe&, x: Cell) {
    let m = outs.len;
    ev(p.l, x);
    let e = outs.len;
    for i in m..e { ev(p.r, outs[i]); }
    collapse(m, e);
}

recursive fn ev(p: Ast.Comma&, x: Cell) {
    ev(p.l, x); ev(p.r, x);
}

recursive fn ev(g: Ast.Neg&, x: Cell) {
    let m = outs.len;
    ev(g.e, x);
    for i in m..outs.len { outs[i] = num(0.0 - nval(outs[i])); }   // jq: -0 of 0 is 0
}

recursive fn ev(b: Ast.Bin&, x: Cell) {
    let m = outs.len;
    ev(b.r, x);
    let e1 = outs.len;
    ev(b.l, x);
    let e2 = outs.len;
    let cmpop = b.op == 'e' || b.op == 'n' || b.op == '<' || b.op == '>' || b.op == 'l' || b.op == 'g';
    for j in m..e1 {
        for i in e1..e2 {
            let c_ = if cmpop { compare_op(b.op, outs[i], outs[j]) } else { arith(b.op, outs[i], outs[j]) }; outs.push(c_);
        }
    }
    collapse(m, e2);
}

recursive fn ev(a: Ast.And&, x: Cell) {
    let m = outs.len;
    ev(a.l, x);
    let e = outs.len;
    for i in m..e {
        if !truthy(outs[i]) { outs.push(Cell.False); continue; }
        let r0 = outs.len;
        ev(a.r, x);
        for j in r0..outs.len { outs[j] = boolc(truthy(outs[j])); }
    }
    collapse(m, e);
}

recursive fn ev(a: Ast.Or&, x: Cell) {
    let m = outs.len;
    ev(a.l, x);
    let e = outs.len;
    for i in m..e {
        if truthy(outs[i]) { outs.push(Cell.True); continue; }
        let r0 = outs.len;
        ev(a.r, x);
        for j in r0..outs.len { outs[j] = boolc(truthy(outs[j])); }
    }
    collapse(m, e);
}

recursive fn ev(a: Ast.Alt&, x: Cell) {
    let m = outs.len;
    ev(a.l, x);
    var k = m;
    for i in m..outs.len { if truthy(outs[i]) { outs[k] = outs[i]; k++; } }
    outs.resize(k);
    if k == m { ev(a.r, x); }
}

recursive fn ev(c: Ast.Collect&, x: Cell) {
    let m = outs.len;
    ev(c.e, x);
    let r = new_arr(m);
    outs.resize(m);
    outs.push(r);
}

recursive fn ev(o: Ast.ObjCons&, x: Cell) {
    // Each entry's key outputs and value outputs, then one object per
    // combination, in jq's order.
    let m = outs.len;
    let sm = spans.len;
    for en in o.ents {
        let a = outs.len;
        ev(en.k, x);
        let b = outs.len;
        ev(en.v, x);
        spans.push(Span { at: a, nk: b - a, nv: outs.len - b });
    }
    let e = outs.len;
    obj_rec(sm, sm, ks.len);
    spans.resize(sm);
    collapse(m, e);
}

recursive fn ev(f: Ast.If&, x: Cell) {
    let m = outs.len;
    ev(f.c, x);
    let e = outs.len;
    for i in m..e { if truthy(outs[i]) { ev(f.t, x); } else { ev(f.e, x); } }
    collapse(m, e);
}

recursive fn ev(r: Ast.Reduce&, x: Cell) {
    let m = outs.len;
    ev(r.init, x);
    guard outs.len == m + 1 else { abort("reduce: the initial value must have exactly one output"); }
    ev(r.src, x);
    let e = outs.len;
    var acc = outs[m];
    for i in m + 1..e {
        envid.push(r.vid);
        envval.push(outs[i]);
        let r0 = outs.len;
        ev(r.upd, acc);
        acc = if outs.len > r0 { outs[outs.len - 1] } else { Cell.Null };
        outs.resize(r0);
        envid.pop();
        envval.pop();
    }
    outs.resize(m);
    outs.push(acc);
}

recursive fn ev(r: Ast.Foreach&, x: Cell) {
    let m = outs.len;
    ev(r.init, x);
    guard outs.len == m + 1 else { abort("foreach: the initial value must have exactly one output"); }
    ev(r.src, x);
    let e = outs.len;
    var acc = outs[m];
    let ext = r.ext;
    for i in m + 1..e {
        envid.push(r.vid);
        envval.push(outs[i]);
        let r0 = outs.len;
        ev(r.upd, acc);
        let r1 = outs.len;
        for j in r0..r1 {
            acc = outs[j];
            if ext { ev(ext, acc); } else { outs.push(acc); }
        }
        collapse(r0, r1);
        envid.pop();
        envval.pop();
    }
    collapse(m, e);
}

recursive fn ev(a: Ast.As&, x: Cell) {
    let m = outs.len;
    ev(a.src, x);
    let e = outs.len;
    for i in m..e {
        envid.push(a.vid);
        envval.push(outs[i]);
        ev(a.body, x);
        envid.pop();
        envval.pop();
    }
    collapse(m, e);
}

recursive fn ev(v: Ast.Var&, x: Cell) {
    outs.push(getvar(v.id));
}

recursive fn ev(c: Ast.Call&, x: Cell) {
    let d = defs[c.fid];
    if d.np == 0 {
        let b = d.body;
        if b { ev(b, x); }
        return;
    }
    let m = outs.len;
    for a in c.args { ev(a, x); outs.push(Cell.Null); }
    // Single outputs per argument (the common case) bind directly.
    var single = outs.len - m == 2 * c.args.len;
    let e = outs.len;
    if !single { abort("arguments with several outputs are not supported"); }
    for k in c.args.len { envid.push(d.p[k]); envval.push(outs[m + 2 * k]); }
    let b = d.body;
    if b { ev(b, x); }
    envid.pop_n(c.args.len);
    envval.pop_n(c.args.len);
    collapse(m, e);
}

recursive fn ev(b: Ast.Builtin&, x: Cell) {
    builtin(b, x);
}

struct Span { at: i64, nk: i64, nv: i64 }
var spans: Span[>..<] = [];

// Chooses a key and a value for entry k, then the rest; at the end, copies the
// chosen entries ks[ksm..] into a new object.
recursive fn obj_rec(k: i64, sm: i64, ksm: i64) {
    if k == spans.len {
        let m2 = ks.len;
        let km2 = keytext.len;
        for i in ksm..m2 { let q = ks[i]; let a: i64 = q.ks; push_key_copy(a, a + q.kl, q.cell); }
        { let c_ = new_obj(m2, km2); outs.push(c_); }
        return;
    }
    let sp1 = spans[k];
    for i in sp1.nk {
        let key = outs[sp1.at + i];
        if kind(key) != 4 { abort("object keys must be strings"); }
        for j in sp1.nv {
            let v = outs[sp1.at + sp1.nk + j];
            let m = ks.len;
            let kmm = keytext.len;
            push_key(sval(key), v);
            obj_rec(k + 1, sm, ksm);
            ks.resize(m);
            keytext.resize(kmm);
        }
    }
}

fn push_key_copy(a: i64, b: i64, c: Cell) {
    let s = keytext.len;
    for i in a..b { keytext.push(keytext[i]); }
    ks.push(KS { cell: c, ks: s as u32, kl: (b - a) as u32 });
}

fn builtin(b: Ast.Builtin&, x: Cell) {
    let id = b.id;
    if id == B_EMPTY { return; }
    if id == B_LENGTH { { let c_ = length_of(x); outs.push(c_); } return; }
    if id == B_NOT { outs.push(boolc(!truthy(x))); return; }
    if id == B_REVERSE { { let c_ = reverse_cell(x); outs.push(c_); } return; }
    if id == B_SORT { { let c_ = sort_cell(x); outs.push(c_); } return; }
    if id == B_MIN { { let c_ = minmax_cell(x, false); outs.push(c_); } return; }
    if id == B_MAX { { let c_ = minmax_cell(x, true); outs.push(c_); } return; }
    if id == B_ADD { { let c_ = add_cell(x); outs.push(c_); } return; }
    if id == B_TOSTRING { let c_ = if kind(x) == 4 { x } else { tojson_cell(x) }; outs.push(c_); return; }
    if id == B_TOJSON { { let c_ = tojson_cell(x); outs.push(c_); } return; }
    if id == B_FROMJSON { { let c_ = fromjson_cell(x); outs.push(c_); } return; }
    if id == B_TYPE { { let c_ = new_str(type_name(x)); outs.push(c_); } return; }
    if id == B_CEIL { outs.push(num(ceil(nval(x)))); return; }
    if id == B_FLOOR { outs.push(num(floor(nval(x)))); return; }
    if id == B_KEYS { { let c_ = keys_cell(x); outs.push(c_); } return; }
    if id == B_STRINGS { if kind(x) == 4 { outs.push(x); } return; }
    if id == B_NUMBERS { if kind(x) == 3 { outs.push(x); } return; }
    if id == B_ARRAYS { if kind(x) == 5 { outs.push(x); } return; }
    if id == B_OBJECTS { if kind(x) == 6 { outs.push(x); } return; }
    if id == B_RECURSE { recurse_cell(x); return; }
    builtin_f(b, x);
}

recursive fn builtin_f(b: Ast.Builtin&, x: Cell) {
    let id = b.id;
    let m = outs.len;
    if id == B_RANGE1 {
        ev(b.args[0], x);
        let e = outs.len;
        for i in m..e {
            let n = nval(outs[i]);
            var v = 0.0;
            while v < n { outs.push(num(v)); v += 1; }
        }
        collapse(m, e);
        return;
    }
    if id == B_RANGE2 || id == B_RANGE3 {
        ev(b.args[0], x);
        let e1 = outs.len;
        ev(b.args[1], x);
        let e2 = outs.len;
        if id == B_RANGE3 { ev(b.args[2], x); }
        let e3 = outs.len;
        for i in m..e1 {
            for j in e1..e2 {
                let lo = nval(outs[i]);
                let hi = nval(outs[j]);
                if id == B_RANGE2 {
                    var v = lo;
                    while v < hi { outs.push(num(v)); v += 1; }
                } else {
                    for k in e2..e3 {
                        let by = nval(outs[k]);
                        var v = lo;
                        if by > 0 { while v < hi { outs.push(num(v)); v += by; } }
                        else if by < 0 { while v > hi { outs.push(num(v)); v += by; } }
                    }
                }
            }
        }
        collapse(m, e3);
        return;
    }
    if id == B_SELECT {
        ev(b.args[0], x);
        let e = outs.len;
        for i in m..e { if truthy(outs[i]) { outs.push(x); } }
        collapse(m, e);
        return;
    }
    if id == B_LAST || id == B_FIRST {
        ev(b.args[0], x);
        if outs.len > m {
            let c = if id == B_LAST { outs[outs.len - 1] } else { outs[m] };
            outs.resize(m);
            outs.push(c);
        }
        return;
    }
    if id == B_JOIN {
        ev(b.args[0], x);
        let e = outs.len;
        for i in m..e { { let c_ = join_cell(x, outs[i]); outs.push(c_); } }
        collapse(m, e);
        return;
    }
    if id == B_GROUP_BY {
        let items = arr_items(x);
        let pm = pairs.len;
        for it in items {
            let r0 = outs.len;
            ev(b.args[0], it);
            guard outs.len == r0 + 1 else { abort("group_by: the key must have exactly one output"); }
            pairs.push(Pair { k: outs[r0], v: it });
            outs.resize(r0);
        }
        let ps = pairs[pm..];
        if all_keys_num(ps) { stable_sort(ps) { p, q => nval(p.k) < nval(q.k) }; }
        else { stable_sort(ps) { p, q => cmpv(p.k, q.k) < 0 }; }
        var i = pm;
        while i < pairs.len {
            var j = i + 1;
            while j < pairs.len && cmpv(pairs[j].k, pairs[i].k) == 0 { j++; }
            let g0 = outs.len;
            for k in i..j { outs.push(pairs[k].v); }
            let g = new_arr(g0);
            outs.resize(g0);
            outs.push(g);
            i = j;
        }
        pairs.resize(pm);
        let r = new_arr(m);
        outs.resize(m);
        outs.push(r);
        return;
    }
    abort("unknown builtin")
}

fn all_keys_num(ps: const Pair[:]) -> bool {
    for p in ps { match p.k { Num => {}, _ => return false } }
    true
}

// --- driver --------------------------------------------------------------------

var ob: u8[>..<] = [];
var line: u8[>..] = [];

fn main() {
    let av = args();
    var show = false;
    var bulk = false;
    var fi = 1;
    while av.len > fi && (av[fi] == "-o" || av[fi] == "-b") {
        if av[fi] == "-o" { show = true; } else { bulk = true; }
        fi++;
    }
    guard av.len > fi else { abort("usage: jqg [-o] '<filter>' < input"); }
    src.append(av[fi]);
    ident_cache .= ast.push(Ast.Ident);
    let root .= p_pipe();
    skipws();
    if sp != src.len { fail("unexpected text"); }

    var h: u64 = 14695981039346656037;
    var nout = 0;
    var nbytes = 0;
    var nin = 0;
    // -b: read all of standard input at once (64 KB freads) instead of line by
    // line (the stdlib's read_line takes one fgetc per byte).
    if bulk { read_stdin(line); }
    while (bulk && line.len > 0) || (!bulk && read_line(line)) {
        var p = JP { src: line[..], pos: 0 };
        loop {
            ws(p);
            if p.pos >= p.src.len { break; }
            let v = parse_value(p);
            nin++;
            ev(root, v);
            for c in outs {
                emit(ob, c);
                ob.push('\n');
                nout++;
            }
            outs.clear();
            for c in ob { h = (h ^ c) * 1099511628211; }
            nbytes += ob.len;
            if show { write_stdout(ob); }
            ob.clear();
            vals.clear();
        }
        line.clear();
        if bulk { break; }
    }
    print("inputs ", nin);
    print("outputs ", nout);
    print("bytes ", nbytes);
    print("fnv ", h);
}
