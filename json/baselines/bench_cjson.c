/* Idiomatic row: cJSON. read -> parse -> walk (counts, string bytes, hash) -> key queries
   on every object -> minified print -> checksum -> delete. */
#include "common.h"
#include "cJSON.h"

static Sums S;

static int tag(const cJSON *v) {
    if (cJSON_IsNull(v)) return T_NULL;
    if (cJSON_IsFalse(v)) return T_FALSE;
    if (cJSON_IsTrue(v)) return T_TRUE;
    if (cJSON_IsNumber(v)) return T_NUM;
    if (cJSON_IsString(v)) return T_STR;
    if (cJSON_IsArray(v)) return T_ARR;
    return T_OBJ;
}

static void walk(const cJSON *v) {
    if (cJSON_IsNull(v)) { S.count[T_NULL]++; S.walk = mix(S.walk, T_NULL); }
    else if (cJSON_IsFalse(v)) { S.count[T_FALSE]++; S.walk = mix(S.walk, T_FALSE); }
    else if (cJSON_IsTrue(v)) { S.count[T_TRUE]++; S.walk = mix(S.walk, T_TRUE); }
    else if (cJSON_IsNumber(v)) { S.count[T_NUM]++; S.walk = mix_dbl(mix(S.walk, T_NUM), v->valuedouble); }
    else if (cJSON_IsString(v)) {
        size_t n = strlen(v->valuestring);
        S.count[T_STR]++; S.strbytes += n;
        S.walk = mix_bytes(mix(S.walk, T_STR), v->valuestring, n);
    } else if (cJSON_IsArray(v)) {
        S.count[T_ARR]++; S.walk = mix(S.walk, T_ARR);
        for (const cJSON *c = v->child; c; c = c->next) walk(c);
        S.walk = mix(S.walk, T_END);
    } else if (cJSON_IsObject(v)) {
        S.count[T_OBJ]++; S.walk = mix(S.walk, T_OBJ);
        for (const cJSON *c = v->child; c; c = c->next) {
            size_t n = strlen(c->string);
            S.strbytes += n;
            S.walk = mix_bytes(S.walk, c->string, n);
            walk(c);
        }
        S.walk = mix(S.walk, T_END);
        for (int k = 0; k < 5; k++) {
            const cJSON *f = cJSON_GetObjectItemCaseSensitive(v, QKEYS[k]);
            if (f) { S.qhits++; S.qhash = mix(S.qhash, (uint64_t)(k * 16 + tag(f))); }
            else S.qhash = mix(S.qhash, 255);
        }
    }
}

int main(int argc, char **argv) {
    if (argc < 2) { fprintf(stderr, "usage: %s file.json\n", argv[0]); return 2; }
    double t0 = now_s();
    size_t len; char *text = read_all(argv[1], &len);
    double t1 = now_s();
    cJSON *root = cJSON_ParseWithLength(text, len);
    if (!root) { fprintf(stderr, "parse error near %.20s\n", cJSON_GetErrorPtr()); return 1; }
    double t2 = now_s();
    S.walk = FNV_BASIS; S.qhash = FNV_BASIS;
    walk(root);
    double t3 = now_s();
    char *out = cJSON_PrintUnformatted(root);
    double t4 = now_s();
    S.outlen = strlen(out);
    S.outhash = FNV_BASIS;
    for (long i = 0; i < S.outlen; i++) S.outhash = mix(S.outhash, (unsigned char)out[i]);
    if (argc > 2) { FILE *f = fopen(argv[2], "wb"); fwrite(out, 1, S.outlen, f); fclose(f); }
    print_sums(&S);
    double t6 = now_s();
    free(out);
    cJSON_Delete(root);
    free(text);
    double t5 = now_s();
    fprintf(stderr, "phase read %.4f parse %.4f walk %.4f emit %.4f hash %.4f free %.4f\n", t1 - t0, t2 - t1, t3 - t2, t4 - t3, t6 - t4, t5 - t6);
    return 0;
}
