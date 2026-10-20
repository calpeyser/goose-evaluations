// VARIANT (A/B only): strings stay in the input buffer; nodes hold a u32 offset and a varint
// length instead of the bytes, as yyjson does. Otherwise json_fast.goose.
// Goose row: a JSON DOM in one pool. read -> parse -> walk (counts, string bytes, hash)
// -> key queries on every object -> minified print -> checksum. No teardown: the pool
// is released when the program ends, as everything in Goose is.
//
// Layout. Every value is one `Node` in a single grow-only pool, in document order
// (a container before its children). A node is a 4-byte link to its next sibling,
// its key as inline bytes behind a varint length (empty for array elements), then
// the value as a variable-mode enum: a null or bool is one tag byte, an integer
// 8 bytes, a string its bytes inline, a container one 4-byte link to its first child.
// Links are pool-relative, so the parser can patch them as children arrive.

import std;
import os;

enum Json {
    Null,
    False,
    True,
    Int { v: i64 },
    Num { v: f64 },
    Str { off: u32, len: varint },
    Arr { first: Node&<u32 in pool>? },
    Obj { first: Node&<u32 in pool>? },
}

struct Node { next: Node&<u32 in pool>?, koff: u32, klen: varint, val: Json.. }

var pool: Node[>..] = [];
var text: u8[>..] = [];
var out: u8[>..] = [];
var pos = 0;
var slow_floats = 0;
var sbeg = 0;   // where the last parse_string result starts in text

extern "json_strtod" fn c_strtod(s: const u8[:]) -> f64;
extern "json_f64_bits" fn f64_bits(d: f64) -> u64;
extern "json_now" fn now_s() -> f64;   // phase timers, stderr only

// --- parsing -------------------------------------------------------------------

fn fail(msg: u8[:]) { abort(str("parse error at ", pos, ": ", msg)); }

fn skip_ws() {
    while pos < text.len {
        let c = text[pos];
        if c != ' ' && c != '\n' && c != '\r' && c != '\t' { break; }
        pos++;
    }
}

fn hexval(c: u8) -> i64 {
    if c >= '0' && c <= '9' { return c - '0'; }
    if c >= 'a' && c <= 'f' { return c - 'a' + 10; }
    if c >= 'A' && c <= 'F' { return c - 'A' + 10; }
    fail("bad hex digit");
}

fn hex4(at: i64) -> i64 {
    guard at + 4 <= text.len else { fail("short \\u escape"); }
    (hexval(text[at]) << 12) | (hexval(text[at + 1]) << 8) | (hexval(text[at + 2]) << 4) | hexval(text[at + 3])
}

// A string starting after its opening quote. Escapes are decoded in place, over the
// input itself (decoded text is never longer), so the result is always a slice of
// `text` and no scratch buffer is needed. Leaves pos after the closing quote.
// 1 for a byte that needs no attention inside a string (not '"', not '\\'), as yyjson's
// char table. Control bytes are let through, as the other parsers here also accept them.
const plain: u8[256] = block {
    var t: u8[256] = [1; 256];
    t['"'] = 0;
    t['\\'] = 0;
    t
};

fn parse_string() -> u8[:] {
    let start = pos;
    sbeg = start;
    // The scan works on a local cursor (one store of the global at the end, not one per
    // byte) and tests four bytes per step through the table.
    var p = pos;
    let n = text.len;
    while p + 4 <= n && plain[text[p]] & plain[text[p + 1]] & plain[text[p + 2]] & plain[text[p + 3]] != 0 { p += 4; }
    while p < n && plain[text[p]] != 0 { p++; }
    pos = p;
    if pos < n && text[pos] == '"' { pos++; return text[start..pos - 1]; }
    var w = pos;
    while pos < text.len {
        let c = text[pos];
        if c == '"' { pos++; return text[start..w]; }
        if c != '\\' { text[w] = c; w++; pos++; continue; }
        guard pos + 1 < text.len else { fail("unterminated escape"); }
        let e = text[pos + 1];
        pos += 2;
        match e {
            '"' => { text[w] = '"'; w++; },
            '\\' => { text[w] = '\\'; w++; },
            '/' => { text[w] = '/'; w++; },
            'b' => { text[w] = 8; w++; },
            'f' => { text[w] = 12; w++; },
            'n' => { text[w] = '\n'; w++; },
            'r' => { text[w] = '\r'; w++; },
            't' => { text[w] = '\t'; w++; },
            'u' => {
                var cp = hex4(pos);
                pos += 4;
                if cp >= 0xD800 && cp < 0xDC00 {
                    guard pos + 6 <= text.len && text[pos] == '\\' && text[pos + 1] == 'u' else { fail("lone surrogate"); }
                    let lo = hex4(pos + 2);
                    guard lo >= 0xDC00 && lo < 0xE000 else { fail("bad low surrogate"); }
                    cp = 0x10000 + ((cp - 0xD800) << 10) + (lo - 0xDC00);
                    pos += 6;
                }
                if cp < 0x80 { text[w] = cp as! u8; w++; }
                else if cp < 0x800 {
                    text[w] = (0xC0 | (cp >> 6)) as! u8; text[w + 1] = (0x80 | (cp & 0x3F)) as! u8; w += 2;
                } else if cp < 0x10000 {
                    text[w] = (0xE0 | (cp >> 12)) as! u8; text[w + 1] = (0x80 | ((cp >> 6) & 0x3F)) as! u8;
                    text[w + 2] = (0x80 | (cp & 0x3F)) as! u8; w += 3;
                } else {
                    text[w] = (0xF0 | (cp >> 18)) as! u8; text[w + 1] = (0x80 | ((cp >> 12) & 0x3F)) as! u8;
                    text[w + 2] = (0x80 | ((cp >> 6) & 0x3F)) as! u8; text[w + 3] = (0x80 | (cp & 0x3F)) as! u8;
                    w += 4;
                }
            },
            _ => fail("bad escape"),
        }
    }
    fail("unterminated string");
}

const pow10: f64[23] = [1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9, 1e10, 1e11,
                        1e12, 1e13, 1e14, 1e15, 1e16, 1e17, 1e18, 1e19, 1e20, 1e21, 1e22];

// A number. Integers of up to 18 digits stay exact as i64 (as yyjson keeps them).
// Other numbers take Clinger's exact fast path when the digits fit 2^53 and the
// power of ten is exact, else the C library's correctly rounded strtod.
fn push_number(ko: u32, kl: i64) -> Node& {
    let start = pos;
    var neg = false;
    if text[pos] == '-' { neg = true; pos++; }
    var mant: u64 = 0;
    var digits = 0;
    while pos < text.len {
        let d = text[pos] - '0';
        if d >= 10 { break; }
        mant = mant * 10 + d;
        digits++;
        pos++;
    }
    guard digits > 0 else { fail("bad number"); }
    var exp10 = 0;
    var is_int = true;
    if pos < text.len && text[pos] == '.' {
        is_int = false;
        pos++;
        let fstart = pos;
        while pos < text.len {
            let d = text[pos] - '0';
            if d >= 10 { break; }
            mant = mant * 10 + d;
            pos++;
        }
        guard pos > fstart else { fail("bad fraction"); }
        exp10 = fstart - pos;
        digits += pos - fstart;
    }
    if pos < text.len && (text[pos] == 'e' || text[pos] == 'E') {
        is_int = false;
        pos++;
        var eneg = false;
        if pos < text.len && (text[pos] == '-' || text[pos] == '+') { eneg = text[pos] == '-'; pos++; }
        var e = 0;
        let estart = pos;
        while pos < text.len && text[pos] >= '0' && text[pos] <= '9' {
            if e < 100000 { e = e * 10 + (text[pos] - '0'); }
            pos++;
        }
        guard pos > estart else { fail("bad exponent"); }
        exp10 += if eneg { -e } else { e };
    }
    if is_int && digits <= 18 {
        let v = mant as! i64;
        return pool.push(Node { koff: ko, klen: kl, val: Json.Int { v: if neg { -v } else { v } } });
    }
    var f = 0.0;
    if digits <= 19 && mant < 9007199254740992 && exp10 >= -22 && exp10 <= 22 {
        f = mant;
        if exp10 < 0 { f /= pow10[-exp10]; } else { f *= pow10[exp10]; }
        if neg { f = -f; }
    } else {
        slow_floats++;
        f = c_strtod(text[start..pos]);
    }
    return pool.push(Node { koff: ko, klen: kl, val: Json.Num { v: f } });
}

fn expect_word(w: u8[:]) {
    guard pos + w.len <= text.len && text[pos..pos + w.len] == w else { fail("bad literal"); }
    pos += w.len;
}

fn link_after(prev: Node&?, n: Node&) {
    guard prev else { return; }
    prev.next .= n;
}

recursive fn parse_value(ko: u32, kl: i64) -> Node& {
    skip_ws();
    guard pos < text.len else { fail("unexpected end"); }
    let c = text[pos];
    if c == '{' {
        pos++;
        let obj .= pool.push(Node { koff: ko, klen: kl, val: Json.Obj { first: null } });
        skip_ws();
        if pos < text.len && text[pos] == '}' { pos++; return obj; }
        var last: Node&? = null;
        loop {
            skip_ws();
            guard pos < text.len && text[pos] == '"' else { fail("expected key"); }
            pos++;
            let k = parse_string();
            let kb = sbeg as u32;
            skip_ws();
            guard pos < text.len && text[pos] == ':' else { fail("expected colon"); }
            pos++;
            let child .= parse_value(kb, k.len);
            if last { link_after(last, child); } else { set_first(obj, child); }
            last .= child;
            skip_ws();
            guard pos < text.len else { fail("unclosed object"); }
            if text[pos] == ',' { pos++; continue; }
            guard text[pos] == '}' else { fail("expected , or }"); }
            pos++;
            return obj;
        }
    }
    if c == '[' {
        pos++;
        let arr .= pool.push(Node { koff: ko, klen: kl, val: Json.Arr { first: null } });
        skip_ws();
        if pos < text.len && text[pos] == ']' { pos++; return arr; }
        var last: Node&? = null;
        loop {
            let child .= parse_value(0, 0);
            if last { link_after(last, child); } else { set_first(arr, child); }
            last .= child;
            skip_ws();
            guard pos < text.len else { fail("unclosed array"); }
            if text[pos] == ',' { pos++; continue; }
            guard text[pos] == ']' else { fail("expected , or ]"); }
            pos++;
            return arr;
        }
    }
    if c == '"' {
        pos++;
        let s = parse_string();
        return pool.push(Node { koff: ko, klen: kl, val: Json.Str { off: sbeg as u32, len: s.len } });
    }
    if c == 't' { expect_word("true"); return pool.push(Node { koff: ko, klen: kl, val: Json.True }); }
    if c == 'f' { expect_word("false"); return pool.push(Node { koff: ko, klen: kl, val: Json.False }); }
    if c == 'n' { expect_word("null"); return pool.push(Node { koff: ko, klen: kl, val: Json.Null }); }
    return push_number(ko, kl);
}

fn set_first(parent: Node&, child: Node&) {
    match parent.val {
        Arr &a => { a.first .= child; },
        Obj &o => { o.first .= child; },
        _ => {},
    }
}

// --- walk, queries -------------------------------------------------------------

let FNV_PRIME: u64 = 1099511628211;
let FNV_BASIS: u64 = 14695981039346656037;

fn mix(h: u64, x: u64) -> u64 { (h ^ x) * FNV_PRIME }
fn mix_bytes(h: u64, s: u8[:]) -> u64 {
    var r = h;
    for b in s { r = (r ^ b) * FNV_PRIME; }
    mix(r, s.len as u64)
}

struct Sums {
    count: i64[8] = [0; 8],
    strbytes: i64 = 0,
    walk: u64,
    qhits: i64 = 0,
    qhash: u64,
}

var S = Sums { walk: FNV_BASIS, qhash: FNV_BASIS };

fn tag(v: Json..&) -> i64 {
    match v { Null => 1, False => 2, True => 3, Int => 4, Num => 4, Str => 5, Arr => 6, Obj => 7 }
}

fn query(first: Node&?) {
    const keys = ["id", "name", "type", "url", "text"];
    for q in 5 {
        var c = first;
        var found = false;
        while c {
            let n .= c;
            if text[n.koff..n.koff + n.klen] == keys[q] {
                S.qhits++;
                S.qhash = mix(S.qhash, (q * 16 + tag(n.val)) as u64);
                found = true;
                break;
            }
            c .= n.next;
        }
        if !found { S.qhash = mix(S.qhash, 255); }
    }
}

recursive fn walk(n: Node&) {
    match n.val {
        Null => { S.count[1]++; S.walk = mix(S.walk, 1); },
        False => { S.count[2]++; S.walk = mix(S.walk, 2); },
        True => { S.count[3]++; S.walk = mix(S.walk, 3); },
        Int &i => { S.count[4]++; S.walk = mix(mix(S.walk, 4), f64_bits(i.v)); },
        Num &f => { S.count[4]++; S.walk = mix(mix(S.walk, 4), f64_bits(f.v)); },
        Str &s => { S.count[5]++; S.strbytes += s.len; S.walk = mix_bytes(mix(S.walk, 5), text[s.off..s.off + s.len]); },
        Arr &a => {
            S.count[6]++;
            S.walk = mix(S.walk, 6);
            var c = a.first;
            while c { let k .= c; walk(k); c .= k.next; }
            S.walk = mix(S.walk, 8);
        },
        Obj &o => {
            S.count[7]++;
            S.walk = mix(S.walk, 7);
            var c = o.first;
            while c {
                let k .= c;
                S.strbytes += k.klen;
                S.walk = mix_bytes(S.walk, text[k.koff..k.koff + k.klen]);
                walk(k);
                c .= k.next;
            }
            S.walk = mix(S.walk, 8);
            query(o.first);
        },
    }
}

// --- minified writer -------------------------------------------------------------

// 1 for a byte the writer copies unchanged: not a control byte, '"' or '\\'.
const clean: u8[256] = block {
    var t: u8[256] = [1; 256];
    for c in 32 { t[c] = 0; }
    t['"'] = 0;
    t['\\'] = 0;
    t
};

fn emit_string(s: u8[:]) {
    out.push('"');
    var run = 0;
    var i = 0;
    let n = s.len;
    loop {
        while i + 4 <= n && clean[s[i]] & clean[s[i + 1]] & clean[s[i + 2]] & clean[s[i + 3]] != 0 { i += 4; }
        while i < n && clean[s[i]] != 0 { i++; }
        if i >= n { break; }
        let b = s[i];
        out.append(s[run..i]);
        i++;
        run = i;
        match b {
            '"' => out.append("\\\""),
            '\\' => out.append("\\\\"),
            8 => out.append("\\b"),
            12 => out.append("\\f"),
            '\n' => out.append("\\n"),
            '\r' => out.append("\\r"),
            '\t' => out.append("\\t"),
            _ => {
                const hex = "0123456789ABCDEF";
                out.append("\\u00");
                out.push(hex[(b >> 4) as i64]);
                out.push(hex[(b & 15) as i64]);
            },
        }
    }
    out.append(s[run..]);
    out.push('"');
}

recursive fn emit(n: Node&) {
    match n.val {
        Null => out.append("null"),
        False => out.append("false"),
        True => out.append("true"),
        Int &i => format_int(out, i.v, 10, 0, ' '),
        Num &f => format(out, f.v),
        Str &s => emit_string(text[s.off..s.off + s.len]),
        Arr &a => {
            out.push('[');
            var c = a.first;
            var sep = false;
            while c {
                let k .= c;
                if sep { out.push(','); }
                sep = true;
                emit(k);
                c .= k.next;
            }
            out.push(']');
        },
        Obj &o => {
            out.push('{');
            var c = o.first;
            var sep = false;
            while c {
                let k .= c;
                if sep { out.push(','); }
                sep = true;
                emit_string(text[k.koff..k.koff + k.klen]);
                out.push(':');
                emit(k);
                c .= k.next;
            }
            out.push('}');
        },
    }
}

fn main() {
    let a = args();
    guard a.len >= 2 else { abort("usage: json file.json [out.json]"); }
    let t0 = now_s();
    guard read_file(a[1], text) else { abort("cannot read input"); }
    let t1 = now_s();
    let root .= parse_value(0, 0);
    skip_ws();
    guard pos == text.len else { fail("trailing data"); }
    let t2 = now_s();
    walk(root);
    let t3 = now_s();
    emit(root);
    let t4 = now_s();
    var oh = FNV_BASIS;
    for b in out { oh = (oh ^ b) * FNV_PRIME; }
    if a.len >= 3 { write_file(a[2], out); }
    const names = ["", "null", "false", "true", "number", "string", "array", "object"];
    var total = 0;
    for t in 1..8 { print(names[t], " ", S.count[t]); total += S.count[t]; }
    print("nodes ", total);
    print("strbytes ", S.strbytes);
    var line: u8[>..] = [];
    line.append("walk "); format_uint(line, S.walk, 16, 16, '0'); print(line);
    print("qhits ", S.qhits);
    line.clear(); line.append("qhash "); format_uint(line, S.qhash, 16, 16, '0'); print(line);
    print("outlen ", out.len);
    line.clear(); line.append("outhash "); format_uint(line, oh, 16, 16, '0'); print(line);
    let t6 = now_s();
    var ph: u8[>..] = [];
    ph.append("phase read "); format_flt(ph, t1 - t0, 4); ph.append(" parse "); format_flt(ph, t2 - t1, 4);
    ph.append(" walk "); format_flt(ph, t3 - t2, 4); ph.append(" emit "); format_flt(ph, t4 - t3, 4);
    ph.append(" hash "); format_flt(ph, t6 - t4, 4); ph.append(" free 0.0000\n");
    write_stderr(ph);
    write_stderr(str("pool_nodes ", pool.len, " slow_floats ", slow_floats, "\n"));
}
