#!/bin/bash
# bench.sh - for each input, the rows run in turn: 1 warm-up and $RUNS timed runs each.
# Wall clock is perf stat's "seconds time elapsed"; peak RSS is from /usr/bin/time;
# user cycles and instructions are from perf stat. Every row's checksum lines must agree,
# except outlen/outhash: cJSON prints numbers differently (see the README).
# Settings: ROWS (default "cjson yyjson goose"), FILES (input names in $INPUTS/json), RUNS (5).
# Output: $OUT/json/results/bench-<date>.tsv (one line per run), sums-*, stderr-*.
set -uo pipefail
source "$(dirname "$0")/../../bin/env.sh"
IN=$INPUTS/json; B=$OUT/json/bin; R=$OUT/json/results; mkdir -p "$R"
ROWS=${ROWS:-"cjson yyjson goose"}; FILES=${FILES:-"twitter citm_catalog canada gharchive-1m gen-500"}
RUNS=${RUNS:-5}
T=$(mktemp -d)
TSV=$R/bench-$(date +%Y%m%d-%H%M).tsv
echo -e "file\trow\trun\twall_s\trss_kb\tcycles_u\tinstr_u" > "$TSV"
bad=0
for f in $FILES; do
  for r in $ROWS; do "$B/bench_$r" "$IN/$f.json" > "$R/sums-$r-$f.txt" 2>/dev/null; done
  for i in $(seq 0 "$RUNS"); do
    for r in $ROWS; do
      "$PERF" stat -e cycles:u,instructions:u -o "$T/perf" \
        /usr/bin/time -f "%M" -o "$T/time" "$B/bench_$r" "$IN/$f.json" > /dev/null 2> "$R/stderr-$r-$f.txt"
      read -r rss < "$T/time"
      wall=$(awk '/seconds time elapsed/ {print $1}' "$T/perf")
      cyc=$(awk '/cycles:u/ {gsub(",","",$1); print $1}' "$T/perf"); ins=$(awk '/instructions:u/ {gsub(",","",$1); print $1}' "$T/perf")
      [ "$i" -gt 0 ] && echo -e "$f\t$r\t$i\t$wall\t$rss\t$cyc\t$ins" >> "$TSV"
    done
  done
  base=""; for r in $ROWS; do s=$(grep -v '^out' "$R/sums-$r-$f.txt" | md5sum); [ -z "$base" ] && base=$s
    if [ "$s" = "$base" ]; then echo "checksums agree: $f $r"; else echo "CHECKSUM MISMATCH $f $r"; bad=1; fi; done
done
rm -rf "$T"
echo "$TSV"
exit $bad
