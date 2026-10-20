/* Shared by the C rows: file read, FNV-style mixing, timing-free checksum print. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static double now_s(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec + t.tv_nsec * 1e-9; }

#define FNV_PRIME 1099511628211ULL
#define FNV_BASIS 14695981039346656037ULL
static inline uint64_t mix(uint64_t h, uint64_t x) { return (h ^ x) * FNV_PRIME; }
static inline uint64_t mix_bytes(uint64_t h, const char *s, size_t n) {
    for (size_t i = 0; i < n; i++) h = mix(h, (unsigned char)s[i]);
    return mix(h, n);
}
static inline uint64_t mix_dbl(uint64_t h, double d) {
    uint64_t b; memcpy(&b, &d, 8); return mix(h, b);
}
/* tags: 1 null 2 false 3 true 4 number 5 string 6 array 7 object; 8 = end of container */
enum { T_NULL = 1, T_FALSE, T_TRUE, T_NUM, T_STR, T_ARR, T_OBJ, T_END };

typedef struct {
    long count[8];
    long strbytes;
    uint64_t walk;
    long qhits;
    uint64_t qhash;
    long outlen;
    uint64_t outhash;
} Sums;

static const char *QKEYS[5] = {"id", "name", "type", "url", "text"};

static char *read_all(const char *path, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) { perror(path); exit(1); }
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    char *buf = malloc(n + 1);
    if (fread(buf, 1, n, f) != (size_t)n) { perror("read"); exit(1); }
    buf[n] = 0; fclose(f); *len = n; return buf;
}

static void print_sums(const Sums *s) {
    static const char *names[8] = {"", "null", "false", "true", "number", "string", "array", "object"};
    long total = 0;
    for (int t = 1; t <= 7; t++) { printf("%s %ld\n", names[t], s->count[t]); total += s->count[t]; }
    printf("nodes %ld\n", total);
    printf("strbytes %ld\n", s->strbytes);
    printf("walk %016llx\n", (unsigned long long)s->walk);
    printf("qhits %ld\n", s->qhits);
    printf("qhash %016llx\n", (unsigned long long)s->qhash);
    printf("outlen %ld\n", s->outlen);
    printf("outhash %016llx\n", (unsigned long long)s->outhash);
}
