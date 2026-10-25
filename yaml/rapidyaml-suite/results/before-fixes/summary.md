# Summary: geometric mean of branch / master time, per case and kind of row

`ryml` = the `bm_ryml_*` rows: into a new tree or into a reused tree (`_reuse`), reserved before the timer or not (`_reserve`). `ints` = `bm_rymlints_*`. `libyaml` = libyaml, which builds a rapidyaml tree. `others` = libfyaml, yaml-cpp and the JSON libraries, which this change cannot touch. Each cell is the geometric mean of the ratios, with the number of rows in brackets. `bm_ryml_yaml_arena_reuse_nofilter` counts as a new-tree row: it does not pass the reused tree to the parser.

## bm_parse

| case | bytes | ryml, new tree | ryml, new tree, `_reserve` | ryml, `_reuse` | ryml, `_reuse` + `_reserve` | ints | libyaml | others |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| appveyor.yml | 2,129 | 0.965 (5) | 1.006 (4) | 1.006 (3) | 1.007 (4) | 1.005 (6) | 1.002 (2) | 0.998 (2) |
| compile_commands.json | 46,826 | 0.974 (9) | 0.988 (8) | 0.990 (7) | 0.993 (8) | 1.000 (13) | 0.947 (2) | 1.017 (8) |
| travis.yml | 4,067 | 0.978 (5) | 1.002 (4) | 1.004 (3) | 1.005 (4) | 1.001 (6) | 1.015 (2) | 0.998 (2) |
| scalar_dquot_multiline.yml | 72,181 | 0.994 (5) | 0.997 (4) | 0.999 (3) | 1.001 (4) | 0.998 (6) | 0.996 (2) | 1.000 (2) |
| scalar_dquot_singleline.yml | 4,824 | 0.960 (5) | 0.996 (4) | 0.995 (3) | 0.996 (4) | 0.999 (6) | 0.990 (2) | 0.998 (2) |
| scalar_squot_multiline.yml | 72,273 | 1.010 (5) | 1.013 (4) | 1.005 (3) | 1.009 (4) | 0.999 (6) | 0.995 (2) | 0.997 (2) |
| scalar_squot_singleline.yml | 4,820 | 0.960 (5) | 0.997 (4) | 0.995 (3) | 0.996 (4) | 1.001 (6) | 0.992 (2) | 1.000 (2) |
| scalar_plain_multiline.yml | 72,041 | 0.997 (5) | 0.998 (4) | 0.999 (3) | 1.000 (4) | 0.999 (6) | 0.999 (2) | 0.998 (2) |
| scalar_plain_singleline.yml | 4,676 | 0.977 (5) | 1.002 (4) | 1.003 (3) | 1.003 (4) | 1.001 (6) | 1.001 (2) | 0.998 (2) |
| scalar_block_literal_multiline.yml | 72,577 | 0.984 (5) | 0.984 (4) | 0.973 (3) | 0.978 (4) | 1.002 (6) | 1.004 (2) | 1.008 (2) |
| scalar_block_literal_singleline.yml | 5,257 | 0.966 (5) | 1.000 (4) | 1.000 (3) | 1.002 (4) | 1.003 (6) | 0.997 (2) | 0.997 (2) |
| scalar_block_folded_multiline.yml | 72,577 | 0.994 (5) | 0.998 (4) | 0.997 (3) | 0.998 (4) | 0.999 (6) | 1.006 (2) | 0.999 (2) |
| scalar_block_folded_singleline.yml | 5,257 | 0.968 (5) | 0.998 (4) | 1.000 (3) | 0.999 (4) | 1.000 (6) | 0.997 (2) | 0.998 (2) |
| medium.yaml | 22,421,093 | 0.687 (5) | 1.158 (4) | 0.998 (3) | 0.998 (4) | 1.001 (6) | 0.942 (2) | 0.984 (2) |
| big_scalar_block_literal_multiline.yml | 1,088,715 | 1.430 (5) | 0.986 (4) | 0.971 (3) | 0.978 (4) | 0.999 (6) | 0.966 (2) | 0.998 (2) |
| big_scalar_dquot_multiline.yml | 1,082,775 | 1.233 (5) | 0.997 (4) | 0.996 (3) | 0.995 (4) | 1.001 (6) | 1.015 (2) | 0.995 (2) |
| big_scalar_plain_multiline.yml | 1,080,675 | 1.125 (5) | 0.997 (4) | 0.998 (3) | 0.998 (4) | 1.001 (6) | 1.010 (2) | 1.002 (2) |

## bm_emit

| case | bytes | ryml | others |
|---|---:|---:|---:|
| appveyor.yml | 2,129 | 0.999 (6) | 0.989 (4) |
| compile_commands.json | 46,826 | 1.000 (12) | 1.003 (7) |
| travis.yml | 4,067 | 1.001 (6) | 0.988 (4) |
| scalar_dquot_multiline.yml | 72,181 | 0.999 (6) | 0.992 (4) |
| scalar_dquot_singleline.yml | 4,824 | 1.004 (6) | 0.997 (4) |
| scalar_squot_multiline.yml | 72,273 | 0.999 (6) | 0.997 (4) |
| scalar_squot_singleline.yml | 4,820 | 0.997 (6) | 0.996 (4) |
| scalar_plain_multiline.yml | 72,041 | 0.999 (6) | 0.993 (4) |
| scalar_plain_singleline.yml | 4,676 | 1.000 (6) | 0.996 (4) |
| scalar_block_literal_multiline.yml | 72,577 | 0.998 (6) | 1.014 (4) |
| scalar_block_literal_singleline.yml | 5,257 | 1.001 (6) | 0.999 (4) |
| scalar_block_folded_multiline.yml | 72,577 | 1.000 (6) | 1.015 (4) |
| scalar_block_folded_singleline.yml | 5,257 | 0.993 (6) | 1.011 (4) |
| medium.yaml | 22,421,093 | 1.003 (6) | 0.994 (4) |
| big_scalar_block_literal_multiline.yml | 1,088,715 | 1.000 (6) | 1.003 (4) |
| big_scalar_dquot_multiline.yml | 1,082,775 | 1.002 (6) | 0.999 (4) |
| big_scalar_plain_multiline.yml | 1,080,675 | 1.000 (6) | 1.000 (4) |

