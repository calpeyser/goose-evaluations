/* The one C helper the Goose row uses: correctly rounded decimal -> double for the
   numbers outside the exact fast path (more than 2^53 in the mantissa, or an exponent
   past 10^22). cJSON uses strtod for every number; yyjson has its own correct parser. */
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

typedef struct { const uint8_t *data; int64_t len; } gs_slice_u8;

double json_strtod(gs_slice_u8 s) {
    char buf[64];
    if (s.len < (int64_t)sizeof buf) {
        memcpy(buf, s.data, s.len); buf[s.len] = 0;
        return strtod(buf, NULL);
    }
    char *p = malloc(s.len + 1);
    memcpy(p, s.data, s.len); p[s.len] = 0;
    double d = strtod(p, NULL);
    free(p);
    return d;
}

uint64_t json_f64_bits(double d) { uint64_t b; memcpy(&b, &d, 8); return b; }

#include <time.h>
double json_now(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec + t.tv_nsec * 1e-9; }
