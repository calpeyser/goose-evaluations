// C control for yaml.goose: the same parser, function for function, and the same
// bytes in memory. One pool of packed nodes (tag byte, LEB128 length, then the
// string bytes or 4-byte pool offsets of the children), a scratch stack of child
// offsets, and every growable buffer a big address-space reservation that grows by
// a pointer bump, as Goose's data stacks do. No bounds or overflow checks.
//   gcc -O2 twin.c -o twin
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
static long long now_ns(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1000000000LL + t.tv_nsec; }

typedef struct { uint8_t *p; int64_t len; } Buf;      // grow-only, reserved up front
static void *reserve(size_t n) {
    void *p = mmap(0, n, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, -1, 0);
    if (p == MAP_FAILED) { perror("mmap"); exit(2); }
    return p;
}
#define RESERVE ((size_t)2 << 30)

static uint8_t *text; static int64_t n, pos, ls;
static Buf pool, sbuf, out;
static uint32_t *kids; static int64_t nkids;
static uint32_t *roots; static int64_t nroots;

enum { T_NULL, T_STR, T_SEQ, T_MAP };
enum { MAPVAL, SEQITEM, DOC };

static void fail(const char *m) { fprintf(stderr, "%s\n", m); exit(1); }

static inline uint8_t at(int64_t i) { return i < n ? text[i] : 0; }
static inline int64_t col(void) { return pos - ls; }
static inline int is_brk(uint8_t c) { return c == '\n' || c == '\r'; }
static inline int is_end(uint8_t c) { return c == ' ' || c == '\n' || c == '\r' || c == 0 || c == '\t'; }
static inline int is_flow_ind(uint8_t c) { return c == ',' || c == '[' || c == ']' || c == '{' || c == '}'; }

static inline void push(Buf *b, uint8_t c) { b->p[b->len++] = c; }
static inline void append(Buf *b, const uint8_t *s, int64_t k) { memcpy(b->p + b->len, s, k); b->len += k; }
static inline void put_varint(Buf *b, uint64_t v) {
    while (v >= 0x80) { push(b, (uint8_t)(v | 0x80)); v >>= 7; }
    push(b, (uint8_t)v);
}
static inline uint64_t get_varint(const uint8_t **pp) {
    const uint8_t *p = *pp; uint64_t v = 0; int sh = 0;
    for (;;) { uint8_t b = *p++; v |= (uint64_t)(b & 0x7f) << sh; if (!(b & 0x80)) break; sh += 7; }
    *pp = p; return v;
}

static void eat_brk(void) {
    if (at(pos) == '\r' && at(pos + 1) == '\n') pos += 2; else pos++;
    ls = pos;
}
static int is_doc_marker(void) {
    if (!(pos - ls == 0 && pos + 3 <= n)) return 0;
    uint8_t c = text[pos];
    if (!((c == '-' || c == '.') && text[pos + 1] == c && text[pos + 2] == c)) return 0;
    return is_end(at(pos + 3));
}
static void skip_blank(void) {
    for (;;) {
        while (at(pos) == ' ' || at(pos) == '\t') pos++;
        uint8_t c = at(pos);
        if (c == '#') { while (pos < n && !is_brk(text[pos])) pos++; continue; }
        if (is_brk(c)) { eat_brk(); continue; }
        return;
    }
}

// --- nodes ---
// -DPAD=k adds k zeroed bytes after every node: an experiment that gives this parser
// rapidyaml's node size (144 bytes) without changing anything else.
#ifndef PAD
#define PAD 0
#endif
static inline void pad(void) { if (PAD) { memset(pool.p + pool.len, 0, PAD); pool.len += PAD; } }
static uint32_t null_node(void) { uint32_t r = (uint32_t)pool.len; push(&pool, T_NULL); pad(); return r; }
static uint32_t str_bytes(const uint8_t *s, int64_t k) {
    uint32_t r = (uint32_t)pool.len; push(&pool, T_STR); put_varint(&pool, k); append(&pool, s, k); pad(); return r;
}
static uint32_t str_node(int64_t a, int64_t b) { return str_bytes(text + a, b - a); }
static uint32_t sbuf_node(void) { return str_bytes(sbuf.p, sbuf.len); }
static int is_null_word(int64_t a, int64_t b) {
    int64_t l = b - a;
    if (l == 0) return 1;
    if (l == 1) return text[a] == '~';
    if (l != 4) return 0;
    return !memcmp(text + a, "null", 4) || !memcmp(text + a, "Null", 4) || !memcmp(text + a, "NULL", 4);
}
static uint32_t coll_node(uint8_t tag, int64_t mark) {
    uint32_t r = (uint32_t)pool.len; push(&pool, tag); put_varint(&pool, nkids - mark);
    append(&pool, (const uint8_t *)(kids + mark), (nkids - mark) * 4);
    nkids = mark; pad(); return r;
}

// --- plain scalars ---
static int64_t plain_gap(int64_t indent, int flow, int64_t *ga, int64_t *gb) {
    int64_t ws = pos;
    while (at(pos) == ' ' || at(pos) == '\t') pos++;
    int64_t we = pos;
    if (!is_brk(at(pos))) {
        if (we > ws) { *ga = ws; *gb = we; return 0; }
        return -1;
    }
    eat_brk();
    if (is_doc_marker()) return -1;
    int64_t breaks = 0;
    for (;;) {
        while (at(pos) == ' ') pos++;
        if (!is_brk(at(pos))) break;
        eat_brk(); breaks++;
        if (is_doc_marker()) return -1;
    }
    if (at(pos) == '#' || (!flow && col() < indent)) return -1;
    return breaks == 0 ? 1 : 2 + breaks;
}
static uint32_t scan_plain(int64_t indent, int flow) {
    int64_t start = pos, end = pos, words = 0, gk = 0, ga = 0, gb = 0;
    for (;;) {
        if (at(pos) == '#') break;
        int64_t w0 = pos;
        for (;;) {
            uint8_t c = at(pos);
            if (is_end(c)) break;
            if (c == ':') { uint8_t d = at(pos + 1); if (is_end(d) || (flow && is_flow_ind(d))) break; }
            if (flow && is_flow_ind(c)) break;
            pos++;
        }
        if (pos == w0) break;
        if (words == 1) { sbuf.len = 0; append(&sbuf, text + start, end - start); }
        if (words >= 1) {
            if (gk == 0) append(&sbuf, text + ga, gb - ga);
            else if (gk == 1) push(&sbuf, ' ');
            else for (int64_t k = 0; k < gk - 2; k++) push(&sbuf, '\n');
            append(&sbuf, text + w0, pos - w0);
        }
        end = pos; words++;
        int64_t a = 0, b = 0, k = plain_gap(indent, flow, &a, &b);
        if (k < 0) break;
        gk = k; ga = a; gb = b;
    }
    if (words <= 1) return is_null_word(start, end) ? null_node() : str_node(start, end);
    return sbuf_node();
}

// --- quoted scalars ---
static int64_t hexval(uint8_t c) {
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    fail("bad hex digit in escape"); return 0;
}
static void put_utf8(int64_t cp) {
    if (cp < 0x80) push(&sbuf, (uint8_t)cp);
    else if (cp < 0x800) { push(&sbuf, 0xC0 | (cp >> 6)); push(&sbuf, 0x80 | (cp & 0x3F)); }
    else if (cp < 0x10000) { push(&sbuf, 0xE0 | (cp >> 12)); push(&sbuf, 0x80 | ((cp >> 6) & 0x3F)); push(&sbuf, 0x80 | (cp & 0x3F)); }
    else { push(&sbuf, 0xF0 | (cp >> 18)); push(&sbuf, 0x80 | ((cp >> 12) & 0x3F)); push(&sbuf, 0x80 | ((cp >> 6) & 0x3F)); push(&sbuf, 0x80 | (cp & 0x3F)); }
}
static void quoted_breaks(void) {
    for (;;) {
        while (at(pos) == ' ' || at(pos) == '\t') pos++;
        if (!is_brk(at(pos))) return;
        eat_brk(); push(&sbuf, '\n');
    }
}
static uint32_t scan_quoted(void) {
    uint8_t q = text[pos]; int dq = q == '"';
    pos++;
    int64_t s0 = pos;
    while (pos < n && text[pos] != q && text[pos] != '\\' && !is_brk(text[pos])) pos++;
    if (at(pos) == q && (dq || at(pos + 1) != '\'')) { pos++; return str_node(s0, pos - 1); }
    sbuf.len = 0; append(&sbuf, text + s0, pos - s0);
    for (;;) {
        if (pos >= n) fail("unterminated quoted scalar");
        uint8_t c = text[pos];
        if (c == q) {
            if (!dq && at(pos + 1) == '\'') { push(&sbuf, '\''); pos += 2; continue; }
            pos++; break;
        }
        if (dq && c == '\\') {
            uint8_t e = at(pos + 1);
            pos += 2;
            if (is_brk(e)) { pos--; eat_brk(); quoted_breaks(); continue; }
            switch (e) {
            case '0': push(&sbuf, 0); break;
            case 'a': push(&sbuf, 7); break;
            case 'b': push(&sbuf, 8); break;
            case 't': case '\t': push(&sbuf, 9); break;
            case 'n': push(&sbuf, 10); break;
            case 'v': push(&sbuf, 11); break;
            case 'f': push(&sbuf, 12); break;
            case 'r': push(&sbuf, 13); break;
            case 'e': push(&sbuf, 27); break;
            case ' ': push(&sbuf, ' '); break;
            case '"': push(&sbuf, '"'); break;
            case '\\': push(&sbuf, '\\'); break;
            case '/': push(&sbuf, '/'); break;
            case 'N': put_utf8(0x85); break;
            case '_': put_utf8(0xA0); break;
            case 'L': put_utf8(0x2028); break;
            case 'P': put_utf8(0x2029); break;
            case 'x': case 'u': case 'U': {
                int k = e == 'x' ? 2 : e == 'u' ? 4 : 8;
                int64_t cp = 0;
                for (int i = 0; i < k; i++) cp = cp * 16 + hexval(at(pos + i));
                pos += k; put_utf8(cp); break;
            }
            default: fail("unknown escape in double-quoted scalar");
            }
            continue;
        }
        if (c == ' ' || c == '\t' || is_brk(c)) {
            int64_t ws = pos;
            while (at(pos) == ' ' || at(pos) == '\t') pos++;
            if (is_brk(at(pos))) {
                eat_brk();
                int64_t before = sbuf.len;
                quoted_breaks();
                if (sbuf.len == before) push(&sbuf, ' ');
            } else append(&sbuf, text + ws, pos - ws);
            continue;
        }
        push(&sbuf, c); pos++;
    }
    return sbuf_node();
}

// --- block scalars ---
static int64_t block_breaks(int64_t indent) {
    int64_t k = 0;
    while (col() < indent && at(pos) == ' ') pos++;
    while (is_brk(at(pos))) {
        eat_brk(); k++;
        while (col() < indent && at(pos) == ' ') pos++;
    }
    return k;
}
static uint32_t scan_block(int64_t pind) {
    int folded = text[pos] == '>';
    pos++;
    int chomp = 0; int64_t inc = 0;
    for (;;) {
        uint8_t c = at(pos);
        if (c == '-') { chomp = -1; pos++; }
        else if (c == '+') { chomp = 1; pos++; }
        else if (c >= '1' && c <= '9') { inc = c - '0'; pos++; }
        else break;
    }
    while (at(pos) == ' ' || at(pos) == '\t') pos++;
    if (at(pos) == '#') while (pos < n && !is_brk(text[pos])) pos++;
    if (is_brk(at(pos))) eat_brk();
    int64_t min_indent = pind + 1; if (min_indent < 1) min_indent = 1;
    int64_t indent, breaks = 0;
    if (inc == 0) {
        int64_t max_indent = 0;
        for (;;) {
            uint8_t c = at(pos);
            if (c == ' ') { pos++; if (col() > max_indent) max_indent = col(); }
            else if (is_brk(c)) { eat_brk(); breaks++; }
            else break;
        }
        indent = max_indent > min_indent ? max_indent : min_indent;
    } else {
        indent = min_indent + inc - 1;
        breaks = block_breaks(indent);
    }
    sbuf.len = 0;
    int brk = 0;
    while (col() == indent && pos < n) {
        for (int64_t k = 0; k < breaks; k++) push(&sbuf, '\n');
        int lead_ns = at(pos) != ' ' && at(pos) != '\t';
        int64_t a = pos;
        while (pos < n && !is_brk(text[pos])) pos++;
        append(&sbuf, text + a, pos - a);
        brk = is_brk(at(pos));
        if (brk) eat_brk();
        breaks = block_breaks(indent);
        if (col() == indent && pos < n) {
            if (folded && brk && lead_ns && at(pos) != ' ' && at(pos) != '\t') { if (breaks == 0) push(&sbuf, ' '); }
            else if (brk) push(&sbuf, '\n');
        } else break;
    }
    if (chomp >= 0 && brk) push(&sbuf, '\n');
    if (chomp == 1) for (int64_t k = 0; k < breaks; k++) push(&sbuf, '\n');
    return sbuf_node();
}

// --- block structure ---
static int unsupported(uint8_t c) { return c == '&' || c == '*' || c == '!' || c == '%' || c == '@' || c == '`'; }
static uint32_t parse_seq(int64_t ind);
static uint32_t parse_map(int64_t ind, uint32_t first);
static uint32_t parse_flow(void);

static uint32_t parse_here(int64_t pind) {
    uint8_t c = text[pos];
    if (c == '-' && is_end(at(pos + 1))) return parse_seq(col());
    if (c == '|' || c == '>') return scan_block(pind);
    if (c == '[' || c == '{') return parse_flow();
    if ((c == '?' && is_end(at(pos + 1))) || unsupported(c)) fail("unsupported YAML construct");
    int64_t kcol = col();
    if (c == '"' || c == '\'') {
        uint32_t k = scan_quoted();
        while (at(pos) == ' ' || at(pos) == '\t') pos++;
        if (at(pos) == ':' && is_end(at(pos + 1))) return parse_map(kcol, k);
        return k;
    }
    uint32_t k = scan_plain(pind + 1, 0);
    if (at(pos) == ':' && is_end(at(pos + 1))) return parse_map(kcol, k);
    return k;
}
static uint32_t parse_value(int64_t pind, int ctx) {
    while (at(pos) == ' ' || at(pos) == '\t') pos++;
    uint8_t c = at(pos);
    if (pos >= n || is_brk(c) || c == '#') {
        skip_blank();
        if (pos >= n || is_doc_marker()) return null_node();
        int64_t ind = col();
        if (ind > pind) return parse_here(pind);
        if (ctx == MAPVAL && ind == pind && text[pos] == '-' && is_end(at(pos + 1))) return parse_seq(ind);
        return null_node();
    }
    return parse_here(pind);
}
static uint32_t parse_seq(int64_t ind) {
    int64_t mark = nkids;
    for (;;) {
        pos++;
        uint32_t v = parse_value(ind, SEQITEM);
        kids[nkids++] = v;
        skip_blank();
        if (!(pos < n && col() == ind && text[pos] == '-' && is_end(at(pos + 1)) && !is_doc_marker())) break;
    }
    return coll_node(T_SEQ, mark);
}
static uint32_t parse_map(int64_t ind, uint32_t first) {
    int64_t mark = nkids;
    kids[nkids++] = first;
    for (;;) {
        pos++;
        uint32_t v = parse_value(ind, MAPVAL);
        kids[nkids++] = v;
        skip_blank();
        if (!(pos < n && col() == ind && !is_doc_marker())) break;
        uint8_t c = text[pos];
        if ((c == '?' && is_end(at(pos + 1))) || unsupported(c) || c == '[' || c == '{') fail("unsupported YAML construct");
        if (c == '-' && is_end(at(pos + 1))) fail("sequence entry where a key was expected");
        uint32_t k = (c == '"' || c == '\'') ? scan_quoted() : scan_plain(ind + 1, 0);
        kids[nkids++] = k;
        while (at(pos) == ' ' || at(pos) == '\t') pos++;
        if (at(pos) != ':') fail("expected ':' after a mapping key");
    }
    return coll_node(T_MAP, mark);
}
static uint32_t parse_flow(void) {
    skip_blank();
    uint8_t c = at(pos);
    if (c == '[') {
        pos++;
        int64_t mark = nkids;
        for (;;) {
            skip_blank();
            if (at(pos) == ']') { pos++; break; }
            uint32_t v = parse_flow(); kids[nkids++] = v;
            skip_blank();
            if (at(pos) == ':') fail("single-pair mapping in a flow sequence");
            if (at(pos) == ',') pos++;
            else if (at(pos) != ']') fail("expected ',' or ']'");
        }
        return coll_node(T_SEQ, mark);
    }
    if (c == '{') {
        pos++;
        int64_t mark = nkids;
        for (;;) {
            skip_blank();
            if (at(pos) == '}') { pos++; break; }
            uint32_t k = parse_flow(); kids[nkids++] = k;
            skip_blank();
            if (at(pos) == ':') {
                pos++; skip_blank();
                uint32_t v = (at(pos) == ',' || at(pos) == '}') ? null_node() : parse_flow();
                kids[nkids++] = v;
            } else { uint32_t v = null_node(); kids[nkids++] = v; }
            skip_blank();
            if (at(pos) == ',') pos++;
            else if (at(pos) != '}') fail("expected ',' or '}'");
        }
        return coll_node(T_MAP, mark);
    }
    if (c == '"' || c == '\'') return scan_quoted();
    if (unsupported(c)) fail("unsupported YAML construct");
    return scan_plain(0, 1);
}
static void parse_all(void) {
    for (;;) {
        skip_blank();
        if (pos >= n) break;
        if (is_doc_marker()) {
            int dash = text[pos] == '-';
            pos += 3;
            if (dash) { uint32_t v = parse_value(-1, DOC); roots[nroots++] = v; }
            continue;
        }
        if (text[pos] == '%') fail("directives are not supported");
        uint32_t v = parse_here(-1); roots[nroots++] = v;
    }
}

// --- walk and emit ---
typedef struct { int64_t maps, seqs, scalars, nulls, keys, bytes; } Counts;
static void emit_str(const uint8_t *s, int64_t k) {
    static const char hex[] = "0123456789abcdef";
    push(&out, '"');
    for (int64_t i = 0; i < k; i++) {
        uint8_t c = s[i];
        if (c == '"') append(&out, (const uint8_t *)"\\\"", 2);
        else if (c == '\\') append(&out, (const uint8_t *)"\\\\", 2);
        else if (c < 0x20) { append(&out, (const uint8_t *)"\\u00", 4); push(&out, hex[c >> 4]); push(&out, hex[c & 15]); }
        else push(&out, c);
    }
    push(&out, '"');
}
static void walk(uint32_t r, Counts *c) {
    const uint8_t *p = pool.p + r;
    uint8_t tag = *p++;
    if (tag == T_NULL) { c->scalars++; c->nulls++; append(&out, (const uint8_t *)"null", 4); return; }
    uint64_t k = get_varint(&p);
    if (tag == T_STR) { c->scalars++; c->bytes += k; emit_str(p, k); return; }
    const uint32_t *ch = (const uint32_t *)p;   // unaligned on purpose, as in Goose's packed layout
    if (tag == T_SEQ) {
        c->seqs++; push(&out, '[');
        for (uint64_t i = 0; i < k; i++) { uint32_t e; memcpy(&e, ch + i, 4); if (i) push(&out, ','); walk(e, c); }
        push(&out, ']');
        return;
    }
    c->maps++; push(&out, '{');
    for (uint64_t i = 0; i < k; i++) {
        uint32_t e; memcpy(&e, ch + i, 4);
        if (i % 2 == 0) {
            if (i) push(&out, ',');
            c->keys++;
            const uint8_t *q = pool.p + e;
            if (*q++ == T_STR) { uint64_t l = get_varint(&q); c->bytes += l; emit_str(q, l); }
            else append(&out, (const uint8_t *)"null", 4);
            push(&out, ':');
        } else walk(e, c);
    }
    push(&out, '}');
}

int main(int argc, char **argv) {
    if (argc < 2) fail("usage: twin <in.yaml> [<out.json>]");
    long long t0 = now_ns();
    FILE *f = fopen(argv[1], "rb");
    if (!f) fail("cannot read input");
    text = reserve(RESERVE);
    size_t got; while ((got = fread(text + n, 1, 1 << 16, f)) > 0) n += got;
    fclose(f);
    pool.p = reserve(RESERVE); sbuf.p = reserve(RESERVE); out.p = reserve(RESERVE);
    kids = reserve(RESERVE); roots = reserve(RESERVE);
    long long t1 = now_ns();
    parse_all();
    long long t2 = now_ns();
    if (getenv("ROW_INFO")) fprintf(stderr, "pool bytes %lld input %lld\n", (long long)pool.len, (long long)n);
    Counts c = {0};
    for (int64_t i = 0; i < nroots; i++) { walk(roots[i], &c); push(&out, '\n'); }
    long long t3 = now_ns();
    if (argc > 2) { FILE *o = fopen(argv[2], "wb"); fwrite(out.p, 1, out.len, o); fclose(o); }
    uint64_t h = 14695981039346656037ull;
    for (int64_t i = 0; i < out.len; i++) { h ^= out.p[i]; h *= 1099511628211ull; }
    long long t5 = now_ns();
    fprintf(stderr, "phases_ms read %.1f parse %.1f walk_emit %.1f teardown 0.0 hash %.1f\n",
            (t1 - t0) / 1e6, (t2 - t1) / 1e6, (t3 - t2) / 1e6, (t5 - t3) / 1e6);
    printf("%lld\n%lld\n%lld\n%lld\n%lld\n%lld\n%lld\n%lld\n%lld\n%llu\n", (long long)nroots,
           (long long)(c.maps + c.seqs + c.scalars), (long long)c.maps, (long long)c.seqs, (long long)c.scalars,
           (long long)c.nulls, (long long)c.keys, (long long)c.bytes, (long long)out.len, (unsigned long long)h);
}
