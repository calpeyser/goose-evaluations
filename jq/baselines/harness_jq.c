// The jq row: libjq (jq 1.8.2) behind the same harness as the Goose row.
// Usage: harness_jq [-o] '<filter>' < input
// Reads standard input in 64 KB chunks through jq's own streaming parser (as the
// jq command does), runs the filter on each value, dumps each output compactly
// with a newline, and folds the bytes into FNV-1a. Prints the same four
// checksum lines as jqg.
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>
#include "jq.h"
#include "jv.h"

static uint64_t h = 14695981039346656037ull;
static long long nin = 0, nout = 0, nbytes = 0;
static int show = 0;

static void run(jq_state *jq, jv value) {
  nin++;
  jq_start(jq, value, 0);
  jv r;
  while (jv_is_valid(r = jq_next(jq))) {
    jv s = jv_dump_string(r, 0);
    const char *p = jv_string_value(s);
    int n = jv_string_length_bytes(jv_copy(s));
    for (int i = 0; i < n; i++) h = (h ^ (unsigned char)p[i]) * 1099511628211ull;
    h = (h ^ '\n') * 1099511628211ull;
    nbytes += n + 1;
    nout++;
    if (show) { fwrite(p, 1, n, stdout); fputc('\n', stdout); }
    jv_free(s);
  }
  if (jv_invalid_has_msg(jv_copy(r))) {
    jv msg = jv_invalid_get_msg(r);
    fprintf(stderr, "jq error: %s\n", jv_string_value(msg));
    exit(5);
  }
  jv_free(r);
}

int main(int argc, char **argv) {
  int fi = 1;
  if (argc > 1 && !strcmp(argv[1], "-o")) { show = 1; fi = 2; }
  if (argc <= fi) { fprintf(stderr, "usage: harness_jq [-o] filter < input\n"); return 2; }
  jq_state *jq = jq_init();
  if (!jq || !jq_compile(jq, argv[fi])) { fprintf(stderr, "compile failed\n"); return 3; }
  jv_parser *parser = jv_parser_new(0);
  static char buf[65536];
  for (;;) {
    size_t n = fread(buf, 1, sizeof buf, stdin);
    int is_last = n < sizeof buf;
    jv_parser_set_buf(parser, buf, (int)n, !is_last);
    jv v;
    while (jv_is_valid(v = jv_parser_next(parser))) run(jq, v);
    if (jv_invalid_has_msg(jv_copy(v))) {
      jv msg = jv_invalid_get_msg(v);
      fprintf(stderr, "parse error: %s\n", jv_string_value(msg));
      return 4;
    }
    jv_free(v);
    if (is_last) break;
  }
  jv_parser_free(parser);
  jq_teardown(&jq);
  fflush(stdout);
  printf("inputs %lld\noutputs %lld\nbytes %lld\nfnv %llu\n", nin, nout, nbytes, (unsigned long long)h);
  return 0;
}
