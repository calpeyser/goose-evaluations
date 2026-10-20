#!/usr/bin/env python3
"""Peak RSS per row and case, with /usr/bin/time -f %M (one run each): python3 rss.py bench.json

bench.py's wait4 numbers include the forked Python interpreter (about 7 MB) before exec,
so small processes all read ~7.3 MB there. This adds rows[r]["rss_time_kb"] to the JSON.
"""
import json, subprocess, sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bench
res = json.load(open(sys.argv[1]))
paths = {name: path for name, f, path in bench.cases()}
for name, c in res.items():
    for r in [r for r in bench.ROWS if r in c["rows"]]:
        with open(paths[name], "rb") as inp:
            p = subprocess.run(["/usr/bin/time", "-f", "%M"] + bench.ROWS[r] + [c["filter"]], stdin=inp,
                               stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)
        c["rows"][r]["rss_time_kb"] = int(p.stderr.decode().strip().splitlines()[-1])
    print(name, {r: c["rows"][r]["rss_time_kb"] for r in c["rows"]}, flush=True)
    json.dump(res, open(sys.argv[1], "w"), indent=1)
