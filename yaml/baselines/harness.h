// Shared by the C++ rows: read the whole input, the canonical emit helpers, the
// checksum lines. Every row (C++ and Goose) prints the same ten lines.
#pragma once
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>
#include <time.h>

// Phase timer, printed to stderr only (the checksum lines are on stdout).
static inline long long now_ns() { timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1000000000LL + t.tv_nsec; }
static void phases(long long t0, long long t1, long long t2, long long t3, long long t4, long long t5) {
    fprintf(stderr, "phases_ms read %.1f parse %.1f walk_emit %.1f teardown %.1f hash %.1f\n",
            (t1 - t0) / 1e6, (t2 - t1) / 1e6, (t3 - t2) / 1e6, (t4 - t3) / 1e6, (t5 - t4) / 1e6);
}

static std::string read_all(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); exit(2); }
    std::string s;
    fseek(f, 0, SEEK_END); s.reserve((size_t)ftell(f)); fseek(f, 0, SEEK_SET);
    char buf[1 << 16];
    size_t n;
    while ((n = fread(buf, 1, sizeof buf, f)) > 0) s.append(buf, n);
    fclose(f);
    return s;
}

struct Counts {
    long long docs = 0, maps = 0, seqs = 0, scalars = 0, nulls = 0, keys = 0, bytes = 0;
};

// A scalar as a JSON string: \" and \\ escaped, bytes below 0x20 as \u00xx.
static inline void emit_str(std::string &out, const char *p, size_t n) {
    static const char hex[] = "0123456789abcdef";
    out.push_back('"');
    for (size_t i = 0; i < n; i++) {
        unsigned char c = (unsigned char)p[i];
        if (c == '"') out.append("\\\"", 2);
        else if (c == '\\') out.append("\\\\", 2);
        else if (c < 0x20) { char e[6] = {'\\', 'u', '0', '0', hex[c >> 4], hex[c & 15]}; out.append(e, 6); }
        else out.push_back((char)c);
    }
    out.push_back('"');
}

static inline uint64_t fnv1a(const std::string &s) {
    uint64_t h = 14695981039346656037ull;
    for (unsigned char c : s) { h ^= c; h *= 1099511628211ull; }
    return h;
}

static void print_counts(const Counts &c, const std::string &out) {
    printf("%lld\n%lld\n%lld\n%lld\n%lld\n%lld\n%lld\n%lld\n%zu\n%llu\n",
           c.docs, c.maps + c.seqs + c.scalars, c.maps, c.seqs, c.scalars, c.nulls, c.keys, c.bytes,
           out.size(), (unsigned long long)fnv1a(out));
}
