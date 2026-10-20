// YAML DOM in Goose: read a multi-document YAML file, build a DOM, walk it
// counting nodes, keys and scalar bytes, emit it as canonical JSON text, and
// print the same ten checksum lines as the yaml-cpp and rapidyaml rows.
//
// The DOM is one grow-only pool of variable-mode enum values. A node is exactly
// as big as its variant: a null is its tag, a string is its tag, a varint length
// and its bytes inline. A collection is its tag and an inline array of 4-byte
// pool-relative links to its children; a map's links alternate key, value.
// Children are pushed before their parent, so every node is complete when it
// is pushed and no link is ever patched. Nothing is freed: the pool goes away
// with the process, which is all a DOM's teardown has to do.
//
// The parser follows PyYAML's scanner for scalar folding, escapes and block
// scalars, over the subset the inputs use: block and flow collections, plain,
// single-quoted, double-quoted, literal and folded scalars, comments, and
// multi-document streams. Anchors, aliases, tags, directives and complex keys
// are not supported (no input file uses them) and abort the run.

import std;
import os;

enum Yaml {
    Null,
    Str { s: u8[varint] },
    Seq { items: (Yaml..&<u32 in pool>)[varint] },
    Map { kv: (Yaml..&<u32 in pool>)[varint] },
}

var text: u8[>..] = [];
var n = 0;              // text.len
var pos = 0;
var ls = 0;             // index of the first byte of the line pos is on

var pool: Yaml..[>..] = [];
var kids: (Yaml..&<u32 in pool>)[>..<] = [];   // children of the collections being parsed
var roots: (Yaml..&<u32 in pool>)[>..] = [];
var sbuf: u8[>..] = [];                         // a scalar that needs folding or unescaping

let MAPVAL = 0;
let SEQITEM = 1;
let DOC = 2;

// --- characters ----------------------------------------------------------------

fn at(i: i64) -> u8 { if i < n { text[i] } else { 0 } }
fn col() -> i64 { pos - ls }
fn is_brk(c: u8) -> bool { c == '\n' || c == '\r' }
fn is_end(c: u8) -> bool { c == ' ' || c == '\n' || c == '\r' || c == 0 || c == '\t' }
fn is_flow_ind(c: u8) -> bool { c == ',' || c == '[' || c == ']' || c == '{' || c == '}' }

// Consume one line break (\n, \r\n or \r) and start a new line.
fn eat_brk() {
    if at(pos) == '\r' && at(pos + 1) == '\n' { pos += 2; } else { pos++; }
    ls = pos;
}

// At column 0, "---" or "..." followed by a blank.
fn is_doc_marker() -> bool {
    guard pos - ls == 0 && pos + 3 <= n else { return false; }
    let c = text[pos];
    guard (c == '-' || c == '.') && text[pos + 1] == c && text[pos + 2] == c else { return false; }
    is_end(at(pos + 3))
}

// Skip spaces, comments and line breaks, up to the next content byte or the end.
fn skip_blank() {
    loop {
        while at(pos) == ' ' || at(pos) == '\t' { pos++; }
        let c = at(pos);
        if c == '#' {
            while pos < n && !is_brk(text[pos]) { pos++; }
            continue;
        }
        if is_brk(c) { eat_brk(); continue; }
        return;
    }
}

// --- nodes ---------------------------------------------------------------------

fn null_node() -> Yaml..& { pool.push(Yaml.Null) }
fn str_node(a: i64, b: i64) -> Yaml..& { pool.push(Yaml.Str { s: text[a..b] }) }
fn sbuf_node() -> Yaml..& { pool.push(Yaml.Str { s: sbuf[0..] }) }

fn is_null_word(a: i64, b: i64) -> bool {
    let l = b - a;
    if l == 0 { return true; }
    if l == 1 { return text[a] == '~'; }
    if l != 4 { return false; }
    let s = text[a..b];
    s == "null" || s == "Null" || s == "NULL"
}

fn seq_node(mark: i64) -> Yaml..& {
    let r .= pool.push(Yaml.Seq { items: kids[mark..] });
    kids.pop_n(kids.len - mark);
    r
}

fn map_node(mark: i64) -> Yaml..& {
    let r .= pool.push(Yaml.Map { kv: kids[mark..] });
    kids.pop_n(kids.len - mark);
    r
}

// --- plain scalars (PyYAML scan_plain / scan_plain_spaces) -----------------------

// Whitespace and line breaks after a word of a plain scalar. Returns how the
// gap folds: -1 = the scalar ends here, 0 = the spaces themselves (a, b),
// 1 = one space, 2 + k = k line breaks. The caller appends it only if another
// word follows.
fn plain_gap(indent: i64, flow: bool) -> i64, i64, i64 {
    let ws = pos;
    while at(pos) == ' ' || at(pos) == '\t' { pos++; }
    let we = pos;
    guard is_brk(at(pos)) else {
        if we > ws { return 0, ws, we; }
        return -1, 0, 0;
    }
    eat_brk();
    if is_doc_marker() { return -1, 0, 0; }
    var breaks = 0;
    loop {
        while at(pos) == ' ' { pos++; }
        guard is_brk(at(pos)) else { break; }
        eat_brk();
        breaks++;
        if is_doc_marker() { return -1, 0, 0; }
    }
    if at(pos) == '#' || (!flow && col() < indent) { return -1, 0, 0; }
    if breaks == 0 { return 1, 0, 0; }
    return 2 + breaks, 0, 0;
}

// A plain scalar starting at pos. `indent` is the least column a continuation
// line may start at. Single-line, single-word scalars, the common case, are
// copied straight from the input into the node.
fn scan_plain(indent: i64, flow: bool) -> Yaml..& {
    let start = pos;
    var end = pos;
    var words = 0;
    var gk = 0;
    var ga = 0;
    var gb = 0;
    loop {
        if at(pos) == '#' { break; }
        let w0 = pos;
        loop {
            let c = at(pos);
            if is_end(c) { break; }
            if c == ':' {
                let d = at(pos + 1);
                if is_end(d) || (flow && is_flow_ind(d)) { break; }
            }
            if flow && is_flow_ind(c) { break; }
            pos++;
        }
        if pos == w0 { break; }
        if words == 1 {
            // A second word: from here the text is built in sbuf.
            sbuf.clear();
            sbuf.append(text[start..end]);
        }
        if words >= 1 {
            if gk == 0 { sbuf.append(text[ga..gb]); }
            else if gk == 1 { sbuf.push(' '); }
            else { for k in gk - 2 { sbuf.push('\n'); } }
            sbuf.append(text[w0..pos]);
        }
        end = pos;
        words++;
        let k, a, b = plain_gap(indent, flow);
        if k < 0 { break; }
        gk = k; ga = a; gb = b;
    }
    if words <= 1 {
        if is_null_word(start, end) { return null_node(); }
        return str_node(start, end);
    }
    sbuf_node()
}

// --- quoted scalars (PyYAML scan_flow_scalar) ------------------------------------

fn hexval(c: u8) -> i64 {
    if c >= '0' && c <= '9' { return c - '0'; }
    if c >= 'a' && c <= 'f' { return c - 'a' + 10; }
    if c >= 'A' && c <= 'F' { return c - 'A' + 10; }
    abort("bad hex digit in escape");
}

fn put_utf8(cp: i64) {
    if cp < 0x80 { sbuf.push(cp as! u8); }
    else if cp < 0x800 {
        sbuf.push((0xC0 | (cp >> 6)) as! u8);
        sbuf.push((0x80 | (cp & 0x3F)) as! u8);
    } else if cp < 0x10000 {
        sbuf.push((0xE0 | (cp >> 12)) as! u8);
        sbuf.push((0x80 | ((cp >> 6) & 0x3F)) as! u8);
        sbuf.push((0x80 | (cp & 0x3F)) as! u8);
    } else {
        sbuf.push((0xF0 | (cp >> 18)) as! u8);
        sbuf.push((0x80 | ((cp >> 12) & 0x3F)) as! u8);
        sbuf.push((0x80 | ((cp >> 6) & 0x3F)) as! u8);
        sbuf.push((0x80 | (cp & 0x3F)) as! u8);
    }
}

// Empty lines inside a quoted scalar after a break: each adds a newline.
fn quoted_breaks() {
    loop {
        while at(pos) == ' ' || at(pos) == '\t' { pos++; }
        guard is_brk(at(pos)) else { return; }
        eat_brk();
        sbuf.push('\n');
    }
}

fn scan_quoted() -> Yaml..& {
    let q = text[pos];
    let dq = q == '"';
    pos++;
    // Fast path: no escape, no line break before the closing quote.
    let s0 = pos;
    while pos < n && text[pos] != q && text[pos] != '\\' && !is_brk(text[pos]) { pos++; }
    if at(pos) == q && (dq || at(pos + 1) != '\'') {
        pos++;
        return str_node(s0, pos - 1);
    }
    sbuf.clear();
    sbuf.append(text[s0..pos]);
    loop {
        guard pos < n else { abort("unterminated quoted scalar"); }
        let c = text[pos];
        if c == q {
            if !dq && at(pos + 1) == '\'' { sbuf.push('\''); pos += 2; continue; }
            pos++;
            break;
        }
        if dq && c == '\\' {
            let e = at(pos + 1);
            pos += 2;
            if is_brk(e) {
                pos--;
                eat_brk();
                quoted_breaks();
                continue;
            }
            match e {
                '0' => sbuf.push(0),
                'a' => sbuf.push(7),
                'b' => sbuf.push(8),
                't', '\t' => sbuf.push(9),
                'n' => sbuf.push(10),
                'v' => sbuf.push(11),
                'f' => sbuf.push(12),
                'r' => sbuf.push(13),
                'e' => sbuf.push(27),
                ' ' => sbuf.push(' '),
                '"' => sbuf.push('"'),
                '\\' => sbuf.push('\\'),
                '/' => sbuf.push('/'),
                'N' => put_utf8(0x85),
                '_' => put_utf8(0xA0),
                'L' => put_utf8(0x2028),
                'P' => put_utf8(0x2029),
                'x', 'u', 'U' => {
                    let k = if e == 'x' { 2 } else if e == 'u' { 4 } else { 8 };
                    var cp = 0;
                    for i in k { cp = cp * 16 + hexval(at(pos + i)); }
                    pos += k;
                    put_utf8(cp);
                },
                _ => abort("unknown escape in double-quoted scalar"),
            }
            continue;
        }
        if c == ' ' || c == '\t' || is_brk(c) {
            let ws = pos;
            while at(pos) == ' ' || at(pos) == '\t' { pos++; }
            if is_brk(at(pos)) {
                eat_brk();
                let before = sbuf.len;
                quoted_breaks();
                if sbuf.len == before { sbuf.push(' '); }
            } else {
                sbuf.append(text[ws..pos]);
            }
            continue;
        }
        sbuf.push(c);
        pos++;
    }
    sbuf_node()
}

// --- block scalars (PyYAML scan_block_scalar) -------------------------------------

// Empty lines before content at `indent`: spaces up to the indent are skipped,
// each break is counted. Returns the number of breaks.
fn block_breaks(indent: i64) -> i64 {
    var k = 0;
    while col() < indent && at(pos) == ' ' { pos++; }
    while is_brk(at(pos)) {
        eat_brk();
        k++;
        while col() < indent && at(pos) == ' ' { pos++; }
    }
    k
}

fn scan_block(pind: i64) -> Yaml..& {
    let folded = text[pos] == '>';
    pos++;
    var chomp = 0;       // 0 clip, -1 strip, 1 keep
    var inc = 0;
    loop {
        let c = at(pos);
        if c == '-' { chomp = -1; pos++; }
        else if c == '+' { chomp = 1; pos++; }
        else if c >= '1' && c <= '9' { inc = c - '0'; pos++; }
        else { break; }
    }
    while at(pos) == ' ' || at(pos) == '\t' { pos++; }
    if at(pos) == '#' { while pos < n && !is_brk(text[pos]) { pos++; } }
    if is_brk(at(pos)) { eat_brk(); }
    var min_indent = pind + 1;
    if min_indent < 1 { min_indent = 1; }
    var indent = 0;
    var breaks = 0;
    if inc == 0 {
        // Find the indentation: the deepest column among leading blank lines and
        // the first content line.
        var max_indent = 0;
        loop {
            let c = at(pos);
            if c == ' ' { pos++; if col() > max_indent { max_indent = col(); } }
            else if is_brk(c) { eat_brk(); breaks++; }
            else { break; }
        }
        indent = if max_indent > min_indent { max_indent } else { min_indent };
    } else {
        indent = min_indent + inc - 1;
        breaks = block_breaks(indent);
    }
    sbuf.clear();
    var brk = false;      // a line break followed the last content line
    while col() == indent && pos < n {
        for k in breaks { sbuf.push('\n'); }
        let lead_ns = at(pos) != ' ' && at(pos) != '\t';
        let a = pos;
        while pos < n && !is_brk(text[pos]) { pos++; }
        sbuf.append(text[a..pos]);
        brk = is_brk(at(pos));
        if brk { eat_brk(); }
        breaks = block_breaks(indent);
        if col() == indent && pos < n {
            if folded && brk && lead_ns && at(pos) != ' ' && at(pos) != '\t' {
                if breaks == 0 { sbuf.push(' '); }
            } else if brk {
                sbuf.push('\n');
            }
        } else {
            break;
        }
    }
    if chomp >= 0 && brk { sbuf.push('\n'); }
    if chomp == 1 { for k in breaks { sbuf.push('\n'); } }
    // The scanner may have stopped part way into the next line's indentation;
    // the caller's skip_blank finds the content and its column from `ls`.
    sbuf_node()
}

// --- block structure ----------------------------------------------------------------

fn unsupported(c: u8) -> bool { c == '&' || c == '*' || c == '!' || c == '%' || c == '@' || c == '`' }

// A node whose first byte is at pos. `pind` is the indent of the enclosing block
// collection (-1 at document level).
recursive fn parse_here(pind: i64) -> Yaml..& {
    let c = text[pos];
    if c == '-' && is_end(at(pos + 1)) { return parse_seq(col()); }
    if c == '|' || c == '>' { return scan_block(pind); }
    if c == '[' || c == '{' { return parse_flow(); }
    if (c == '?' && is_end(at(pos + 1))) || unsupported(c) { abort("unsupported YAML construct"); }
    let kcol = col();
    if c == '"' || c == '\'' {
        let k .= scan_quoted();
        while at(pos) == ' ' || at(pos) == '\t' { pos++; }
        if at(pos) == ':' && is_end(at(pos + 1)) { return parse_map(kcol, k); }
        return k;
    }
    let k .= scan_plain(pind + 1, false);
    if at(pos) == ':' && is_end(at(pos + 1)) { return parse_map(kcol, k); }
    k
}

// After "key:" or "- " or "---": the value on this line, or on the lines below.
recursive fn parse_value(pind: i64, ctx: i64) -> Yaml..& {
    while at(pos) == ' ' || at(pos) == '\t' { pos++; }
    let c = at(pos);
    if pos >= n || is_brk(c) || c == '#' {
        skip_blank();
        if pos >= n || is_doc_marker() { return null_node(); }
        let ind = col();
        if ind > pind { return parse_here(pind); }
        if ctx == MAPVAL && ind == pind && text[pos] == '-' && is_end(at(pos + 1)) { return parse_seq(ind); }
        return null_node();
    }
    parse_here(pind)
}

// A block sequence whose dashes are at column `ind`; pos is on the first dash.
recursive fn parse_seq(ind: i64) -> Yaml..& {
    let mark = kids.len;
    loop {
        pos++;
        kids.push(parse_value(ind, SEQITEM));
        skip_blank();
        guard pos < n && col() == ind && text[pos] == '-' && is_end(at(pos + 1)) && !is_doc_marker() else { break; }
    }
    seq_node(mark)
}

// A block mapping whose keys are at column `ind`; the first key is parsed and pos
// is on its ':'.
recursive fn parse_map(ind: i64, first: Yaml..&) -> Yaml..& {
    let mark = kids.len;
    kids.push(first);
    loop {
        pos++;                                          // the ':'
        kids.push(parse_value(ind, MAPVAL));
        skip_blank();
        guard pos < n && col() == ind && !is_doc_marker() else { break; }
        let c = text[pos];
        if (c == '?' && is_end(at(pos + 1))) || unsupported(c) || c == '[' || c == '{' { abort("unsupported YAML construct"); }
        if c == '-' && is_end(at(pos + 1)) { abort("sequence entry where a key was expected"); }
        if c == '"' || c == '\'' { kids.push(scan_quoted()); } else { kids.push(scan_plain(ind + 1, false)); }
        while at(pos) == ' ' || at(pos) == '\t' { pos++; }
        guard at(pos) == ':' else { abort("expected ':' after a mapping key"); }
    }
    map_node(mark)
}

// --- flow collections --------------------------------------------------------------

recursive fn parse_flow() -> Yaml..& {
    skip_blank();
    let c = at(pos);
    if c == '[' {
        pos++;
        let mark = kids.len;
        loop {
            skip_blank();
            if at(pos) == ']' { pos++; break; }
            kids.push(parse_flow());
            skip_blank();
            if at(pos) == ':' { abort("single-pair mapping in a flow sequence"); }
            if at(pos) == ',' { pos++; }
            else if at(pos) != ']' { abort("expected ',' or ']'"); }
        }
        return seq_node(mark);
    }
    if c == '{' {
        pos++;
        let mark = kids.len;
        loop {
            skip_blank();
            if at(pos) == '}' { pos++; break; }
            kids.push(parse_flow());
            skip_blank();
            if at(pos) == ':' {
                pos++;
                skip_blank();
                if at(pos) == ',' || at(pos) == '}' { kids.push(null_node()); }
                else { kids.push(parse_flow()); }
            } else {
                kids.push(null_node());
            }
            skip_blank();
            if at(pos) == ',' { pos++; }
            else if at(pos) != '}' { abort("expected ',' or '}'"); }
        }
        return map_node(mark);
    }
    if c == '"' || c == '\'' { return scan_quoted(); }
    if unsupported(c) { abort("unsupported YAML construct"); }
    scan_plain(0, true)
}

// --- documents ------------------------------------------------------------------------

fn parse_all() {
    loop {
        skip_blank();
        guard pos < n else { break; }
        if is_doc_marker() {
            let dash = text[pos] == '-';
            pos += 3;
            if dash { roots.push(parse_value(-1, DOC)); }
            continue;
        }
        if text[pos] == '%' { abort("directives are not supported"); }
        roots.push(parse_here(-1));
    }
}

// --- walk and emit -----------------------------------------------------------------------

struct Counts { maps: i64, seqs: i64, scalars: i64, nulls: i64, keys: i64, bytes: i64 }

fn emit_str(out: u8[>..]&, s: u8[:]) {
    out.push('"');
    for c in s {
        if c == '"' { out.append("\\\""); }
        else if c == '\\' { out.append("\\\\"); }
        else if c < 0x20 {
            out.append("\\u00");
            out.push("0123456789abcdef"[c >> 4]);
            out.push("0123456789abcdef"[c & 15]);
        } else { out.push(c); }
    }
    out.push('"');
}

recursive fn walk(n: Yaml.Null&, c: Counts&, out: u8[>..]&) { c.scalars++; c.nulls++; out.append("null"); }
recursive fn walk(n: Yaml.Str&, c: Counts&, out: u8[>..]&) {
    c.scalars++;
    c.bytes += n.s.len;
    emit_str(out, n.s);
}
recursive fn walk(n: Yaml.Seq&, c: Counts&, out: u8[>..]&) {
    c.seqs++;
    out.push('[');
    for e, i in n.items {
        if i > 0 { out.push(','); }
        walk(e, c, out);
    }
    out.push(']');
}
recursive fn walk(n: Yaml.Map&, c: Counts&, out: u8[>..]&) {
    c.maps++;
    out.push('{');
    for e, i in n.kv {
        if i % 2 == 0 {
            if i > 0 { out.push(','); }
            c.keys++;
            match e {
                Str s => { c.bytes += s.s.len; emit_str(out, s.s); },
                _ => out.append("null"),
            }
            out.push(':');
        } else {
            walk(e, c, out);
        }
    }
    out.push('}');
}

fn main() {
    let t0 = clock_ns();
    let a = args();
    guard a.len >= 2 else { abort("usage: yaml <in.yaml> [<out.json>]"); }
    if !read_file(a[1], text) { abort("cannot read input"); }
    n = text.len;
    let t1 = clock_ns();
    parse_all();
    let t2 = clock_ns();
    var c = Counts { 0, 0, 0, 0, 0, 0 };
    var out: u8[>..] = [];
    for r in roots {
        walk(r, c, out);
        out.push('\n');
    }
    let t3 = clock_ns();
    if a.len >= 3 { if !write_file(a[2], out) { abort("cannot write output"); } }
    var h: u64 = 14695981039346656037;
    for b in out { h = (h ^ b) * 1099511628211; }
    let t5 = clock_ns();
    // Phase times go to stderr; the checksum lines below are on stdout.
    write_stderr(str("phases_ms read ", (t1 - t0) / 100000 / 10.0, " parse ", (t2 - t1) / 100000 / 10.0,
                     " walk_emit ", (t3 - t2) / 100000 / 10.0, " teardown 0.0 hash ", (t5 - t3) / 100000 / 10.0, "\n"));
    print(roots.len);
    print(c.maps + c.seqs + c.scalars);
    print(c.maps);
    print(c.seqs);
    print(c.scalars);
    print(c.nulls);
    print(c.keys);
    print(c.bytes);
    print(out.len);
    print(h);
}
