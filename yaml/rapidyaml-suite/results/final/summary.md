# Summary: geometric mean of branch / master time, per case and kind of row

`ryml` = the `bm_ryml_*` rows: into a new tree or into a reused tree (`_reuse`), reserved before the timer or not (`_reserve`). `ints` = `bm_rymlints_*`. `libyaml` = libyaml, which builds a rapidyaml tree. `others` = libfyaml, yaml-cpp and the JSON libraries, which this change cannot touch. Each cell is the geometric mean of the ratios, with the number of rows in brackets. `bm_ryml_yaml_arena_reuse_nofilter` counts as a new-tree row: it does not pass the reused tree to the parser.

## bm_parse

| case | bytes | ryml, new tree | ryml, new tree, `_reserve` | ryml, `_reuse` | ryml, `_reuse` + `_reserve` | ints | libyaml | others |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| appveyor.yml | 2,129 | 0.973 (5) | 1.013 (4) | 1.015 (3) | 1.014 (4) | 1.001 (6) | 0.988 (2) | 0.998 (2) |
| compile_commands.json | 46,826 | 0.977 (9) | 1.001 (8) | 1.001 (7) | 1.003 (8) | 1.001 (13) | 0.948 (2) | 1.009 (8) |
| travis.yml | 4,067 | 0.976 (5) | 0.998 (4) | 1.001 (3) | 1.000 (4) | 1.000 (6) | 1.001 (2) | 0.997 (2) |
| scalar_dquot_multiline.yml | 72,181 | 0.992 (5) | 0.993 (4) | 0.997 (3) | 0.998 (4) | 1.001 (6) | 0.996 (2) | 1.000 (2) |
| scalar_dquot_singleline.yml | 4,824 | 0.961 (5) | 1.001 (4) | 1.001 (3) | 1.002 (4) | 1.000 (6) | 0.988 (2) | 0.996 (2) |
| scalar_squot_multiline.yml | 72,273 | 1.001 (5) | 1.006 (4) | 0.996 (3) | 1.001 (4) | 1.003 (6) | 0.994 (2) | 0.996 (2) |
| scalar_squot_singleline.yml | 4,820 | 0.959 (5) | 0.997 (4) | 0.995 (3) | 0.995 (4) | 1.001 (6) | 0.992 (2) | 1.000 (2) |
| scalar_plain_multiline.yml | 72,041 | 0.999 (5) | 1.001 (4) | 1.002 (3) | 1.001 (4) | 1.000 (6) | 0.998 (2) | 1.000 (2) |
| scalar_plain_singleline.yml | 4,676 | 0.974 (5) | 0.998 (4) | 0.999 (3) | 0.999 (4) | 0.999 (6) | 0.998 (2) | 0.994 (2) |
| scalar_block_literal_multiline.yml | 72,577 | 0.986 (5) | 0.991 (4) | 0.974 (3) | 0.980 (4) | 1.001 (6) | 1.000 (2) | 1.000 (2) |
| scalar_block_literal_singleline.yml | 5,257 | 0.963 (5) | 0.993 (4) | 0.993 (3) | 0.992 (4) | 0.999 (6) | 0.995 (2) | 0.993 (2) |
| scalar_block_folded_multiline.yml | 72,577 | 0.994 (5) | 0.998 (4) | 0.998 (3) | 0.997 (4) | 0.999 (6) | 0.999 (2) | 1.001 (2) |
| scalar_block_folded_singleline.yml | 5,257 | 0.962 (5) | 0.994 (4) | 0.994 (3) | 0.992 (4) | 0.997 (6) | 0.995 (2) | 0.992 (2) |
| medium.yaml | 22,421,093 | 0.638 (5) | 1.008 (4) | 0.997 (3) | 0.998 (4) | 0.999 (6) | 0.940 (2) | 1.004 (2) |
| big_scalar_block_literal_multiline.yml | 1,088,715 | 0.994 (5) | 0.981 (4) | 0.971 (3) | 0.976 (4) | 0.999 (6) | 1.026 (2) | 0.997 (2) |
| big_scalar_dquot_multiline.yml | 1,082,775 | 0.999 (5) | 0.994 (4) | 0.996 (3) | 0.995 (4) | 0.999 (6) | 0.968 (2) | 0.999 (2) |
| big_scalar_plain_multiline.yml | 1,080,675 | 1.003 (5) | 1.000 (4) | 0.999 (3) | 0.999 (4) | 0.999 (6) | 0.989 (2) | 1.001 (2) |

## bm_emit

| case | bytes | ryml | others |
|---|---:|---:|---:|
| appveyor.yml | 2,129 | 1.001 (6) | 0.985 (4) |
| compile_commands.json | 46,826 | 1.000 (12) | 0.999 (7) |
| travis.yml | 4,067 | 1.001 (6) | 0.994 (4) |
| scalar_dquot_multiline.yml | 72,181 | 1.001 (6) | 0.999 (4) |
| scalar_dquot_singleline.yml | 4,824 | 1.003 (6) | 0.995 (4) |
| scalar_squot_multiline.yml | 72,273 | 1.000 (6) | 1.000 (4) |
| scalar_squot_singleline.yml | 4,820 | 0.996 (6) | 0.993 (4) |
| scalar_plain_multiline.yml | 72,041 | 1.000 (6) | 1.000 (4) |
| scalar_plain_singleline.yml | 4,676 | 1.000 (6) | 0.998 (4) |
| scalar_block_literal_multiline.yml | 72,577 | 0.998 (6) | 0.999 (4) |
| scalar_block_literal_singleline.yml | 5,257 | 1.005 (6) | 0.994 (4) |
| scalar_block_folded_multiline.yml | 72,577 | 1.002 (6) | 0.983 (4) |
| scalar_block_folded_singleline.yml | 5,257 | 1.004 (6) | 0.997 (4) |
| medium.yaml | 22,421,093 | 1.003 (6) | 0.992 (4) |
| big_scalar_block_literal_multiline.yml | 1,088,715 | 1.000 (6) | 1.011 (4) |
| big_scalar_dquot_multiline.yml | 1,082,775 | 1.000 (6) | 0.983 (4) |
| big_scalar_plain_multiline.yml | 1,080,675 | 1.002 (6) | 0.985 (4) |

