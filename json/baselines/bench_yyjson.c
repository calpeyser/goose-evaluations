/* Expert row: yyjson (immutable DOM). Same steps and checksum lines as bench_cjson.c. */
#include "common.h"
#include "yyjson.h"

static Sums S;

static int tag(yyjson_val *v) {
    switch (yyjson_get_type(v)) {
    case YYJSON_TYPE_NULL: return T_NULL;
    case YYJSON_TYPE_BOOL: return yyjson_get_bool(v) ? T_TRUE : T_FALSE;
    case YYJSON_TYPE_NUM: return T_NUM;
    case YYJSON_TYPE_STR: return T_STR;
    case YYJSON_TYPE_ARR: return T_ARR;
    default: return T_OBJ;
    }
}

static void walk(yyjson_val *v) {
    int t = tag(v);
    S.count[t]++;
    S.walk = mix(S.walk, t);
    if (t == T_NUM) S.walk = mix_dbl(S.walk, yyjson_get_num(v));
    else if (t == T_STR) {
        size_t n = yyjson_get_len(v);
        S.strbytes += n;
        S.walk = mix_bytes(S.walk, yyjson_get_str(v), n);
    } else if (t == T_ARR) {
        size_t i, max; yyjson_val *c;
        yyjson_arr_foreach(v, i, max, c) walk(c);
        S.walk = mix(S.walk, T_END);
    } else if (t == T_OBJ) {
        size_t i, max; yyjson_val *k, *c;
        yyjson_obj_foreach(v, i, max, k, c) {
            size_t n = yyjson_get_len(k);
            S.strbytes += n;
            S.walk = mix_bytes(S.walk, yyjson_get_str(k), n);
            walk(c);
        }
        S.walk = mix(S.walk, T_END);
        for (int q = 0; q < 5; q++) {
            yyjson_val *f = yyjson_obj_get(v, QKEYS[q]);
            if (f) { S.qhits++; S.qhash = mix(S.qhash, (uint64_t)(q * 16 + tag(f))); }
            else S.qhash = mix(S.qhash, 255);
        }
    }
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: %s file.json\n", argv[0]); return 2; }
    double t0 = now_s();
    size_t len; char *text = read_all(argv[1], &len);
    double t1 = now_s();
    yyjson_read_err err;
    yyjson_doc *doc = yyjson_read_opts(text, len, 0, NULL, &err);
    if (!doc) { fprintf(stderr, "parse error %s at %zu\n", err.msg, err.pos); return 1; }
    double t2 = now_s();
    S.walk = FNV_BASIS; S.qhash = FNV_BASIS;
    walk(yyjson_doc_get_root(doc));
    double t3 = now_s();
    size_t outlen;
    char *out = yyjson_write(doc, 0, &outlen);
    double t4 = now_s();
    S.outlen = outlen;
    S.outhash = FNV_BASIS;
    for (size_t i = 0; i < outlen; i++) S.outhash = mix(S.outhash, (unsigned char)out[i]);
    if (argc > 2) { FILE *f = fopen(argv[2], "wb"); fwrite(out, 1, outlen, f); fclose(f); }
    print_sums(&S);
    double t6 = now_s();
    free(out);
    yyjson_doc_free(doc);
    free(text);
    double t5 = now_s();
    fprintf(stderr, "phase read %.4f parse %.4f walk %.4f emit %.4f hash %.4f free %.4f\n", t1 - t0, t2 - t1, t3 - t2, t4 - t3, t6 - t4, t5 - t6);
    return 0;
}
