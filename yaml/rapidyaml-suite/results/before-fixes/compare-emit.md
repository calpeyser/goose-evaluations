# bm_emit: master against branch, every case and row

Times are the median CPU time of 5 repetitions, in microseconds. Ratio is branch / master: below 1 is faster. Spread is (slowest - fastest) / median over the 5 repetitions. Source: `compare.csv`.

## appveyor.yml (2,129 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 31.5 | 31.5 | 1.000 | 0.2% | 0.5% |
| bm_fyaml_str | 27.8 | 27.2 | 0.980 | 0.4% | 0.4% |
| bm_fyaml_str_reserve | 27.8 | 27.2 | 0.981 | 0.4% | 0.4% |
| bm_ryml_yaml_file | 5.5 | 5.5 | 1.001 | 0.2% | 0.9% |
| bm_ryml_yaml_ofstream | 7.1 | 7.1 | 1.004 | 0.8% | 0.8% |
| bm_ryml_yaml_ostream | 5.9 | 5.8 | 0.997 | 0.8% | 0.3% |
| bm_ryml_yaml_str | 2.0 | 2.0 | 0.997 | 3.2% | 1.5% |
| bm_ryml_yaml_str_file | 3.0 | 3.0 | 0.996 | 0.5% | 0.8% |
| bm_ryml_yaml_str_reserve | 2.1 | 2.1 | 1.002 | 2.5% | 2.1% |
| bm_yamlcpp | 161.3 | 160.5 | 0.995 | 0.9% | 1.1% |

## compile_commands.json (46,826 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 183.3 | 182.3 | 0.995 | 0.1% | 0.4% |
| bm_fyaml_str | 148.1 | 147.8 | 0.998 | 0.1% | 0.1% |
| bm_fyaml_str_reserve | 147.6 | 147.4 | 0.998 | 0.2% | 0.3% |
| bm_jsoncpp | 106.4 | 109.7 | 1.031 | 0.6% | 0.2% |
| bm_nlohmann | 165.5 | 165.7 | 1.001 | 0.4% | 0.5% |
| bm_rapidjson | 100.5 | 100.5 | 1.000 | 0.5% | 0.5% |
| bm_ryml_json_file | 89.1 | 89.0 | 1.000 | 1.0% | 0.3% |
| bm_ryml_json_ofstream | 95.1 | 95.5 | 1.004 | 0.1% | 0.1% |
| bm_ryml_json_ostream | 87.9 | 87.9 | 1.000 | 0.4% | 1.2% |
| bm_ryml_json_str | 75.9 | 76.0 | 1.001 | 0.5% | 0.1% |
| bm_ryml_json_str_file | 79.2 | 79.3 | 1.000 | 1.3% | 0.0% |
| bm_ryml_json_str_reserve | 76.2 | 76.3 | 1.001 | 0.1% | 0.3% |
| bm_ryml_yaml_file | 78.8 | 78.7 | 0.998 | 0.4% | 0.7% |
| bm_ryml_yaml_ofstream | 88.6 | 88.7 | 1.001 | 0.2% | 0.8% |
| bm_ryml_yaml_ostream | 80.3 | 80.2 | 0.999 | 2.4% | 0.6% |
| bm_ryml_yaml_str | 54.4 | 54.3 | 0.998 | 3.6% | 0.6% |
| bm_ryml_yaml_str_file | 57.6 | 57.4 | 0.998 | 1.2% | 0.2% |
| bm_ryml_yaml_str_reserve | 54.8 | 54.4 | 0.993 | 0.8% | 0.4% |
| bm_yamlcpp | 5,176.8 | 5,177.9 | 1.000 | 0.9% | 0.6% |

## travis.yml (4,067 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 67.3 | 67.3 | 1.000 | 0.3% | 0.6% |
| bm_fyaml_str | 63.1 | 61.8 | 0.978 | 0.7% | 1.1% |
| bm_fyaml_str_reserve | 63.6 | 62.2 | 0.978 | 0.4% | 0.8% |
| bm_ryml_yaml_file | 7.0 | 7.1 | 1.012 | 0.5% | 0.3% |
| bm_ryml_yaml_ofstream | 8.5 | 8.7 | 1.020 | 0.6% | 0.5% |
| bm_ryml_yaml_ostream | 7.3 | 7.3 | 0.998 | 0.3% | 0.3% |
| bm_ryml_yaml_str | 3.1 | 3.1 | 0.986 | 0.8% | 1.2% |
| bm_ryml_yaml_str_file | 4.1 | 4.1 | 1.002 | 0.7% | 1.1% |
| bm_ryml_yaml_str_reserve | 3.1 | 3.1 | 0.988 | 0.9% | 0.5% |
| bm_yamlcpp | 300.3 | 298.7 | 0.995 | 1.7% | 0.6% |

## scalar_dquot_multiline.yml (72,181 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,532.3 | 1,497.1 | 0.977 | 0.4% | 0.5% |
| bm_fyaml_str | 1,494.5 | 1,484.3 | 0.993 | 0.5% | 0.5% |
| bm_fyaml_str_reserve | 1,495.6 | 1,487.7 | 0.995 | 0.4% | 0.7% |
| bm_ryml_yaml_file | 93.3 | 93.0 | 0.996 | 4.8% | 13.0% |
| bm_ryml_yaml_ofstream | 89.1 | 89.2 | 1.001 | 13.5% | 0.3% |
| bm_ryml_yaml_ostream | 79.2 | 78.9 | 0.997 | 0.2% | 0.0% |
| bm_ryml_yaml_str | 70.0 | 70.0 | 1.000 | 0.1% | 0.1% |
| bm_ryml_yaml_str_file | 73.6 | 73.6 | 1.000 | 0.1% | 0.2% |
| bm_ryml_yaml_str_reserve | 70.5 | 70.5 | 1.000 | 0.2% | 0.3% |
| bm_yamlcpp | 5,981.1 | 5,998.4 | 1.003 | 1.4% | 0.8% |

## scalar_dquot_singleline.yml (4,824 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 33.3 | 33.3 | 0.999 | 0.5% | 0.3% |
| bm_fyaml_str | 26.7 | 26.7 | 0.999 | 0.2% | 0.4% |
| bm_fyaml_str_reserve | 26.8 | 26.7 | 0.998 | 0.1% | 0.1% |
| bm_ryml_yaml_file | 12.3 | 12.3 | 1.002 | 0.6% | 0.6% |
| bm_ryml_yaml_ofstream | 13.0 | 13.0 | 1.002 | 1.4% | 7.7% |
| bm_ryml_yaml_ostream | 11.2 | 11.2 | 0.997 | 0.2% | 0.2% |
| bm_ryml_yaml_str | 6.8 | 6.8 | 1.006 | 0.7% | 8.0% |
| bm_ryml_yaml_str_file | 8.4 | 8.4 | 1.000 | 0.6% | 0.5% |
| bm_ryml_yaml_str_reserve | 6.9 | 7.0 | 1.014 | 1.2% | 3.2% |
| bm_yamlcpp | 457.2 | 454.3 | 0.994 | 1.2% | 0.9% |

## scalar_squot_multiline.yml (72,273 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,435.8 | 1,411.1 | 0.983 | 0.2% | 0.3% |
| bm_fyaml_str | 1,401.1 | 1,402.1 | 1.001 | 0.3% | 0.3% |
| bm_fyaml_str_reserve | 1,399.3 | 1,401.0 | 1.001 | 0.2% | 0.1% |
| bm_ryml_yaml_file | 67.1 | 67.1 | 1.001 | 0.4% | 0.4% |
| bm_ryml_yaml_ofstream | 65.2 | 65.4 | 1.003 | 0.2% | 0.3% |
| bm_ryml_yaml_ostream | 55.4 | 55.0 | 0.993 | 0.2% | 0.2% |
| bm_ryml_yaml_str | 44.5 | 44.5 | 1.000 | 0.9% | 0.2% |
| bm_ryml_yaml_str_file | 47.9 | 47.9 | 0.999 | 0.2% | 0.4% |
| bm_ryml_yaml_str_reserve | 45.0 | 44.9 | 0.999 | 0.5% | 0.1% |
| bm_yamlcpp | 6,584.5 | 6,594.0 | 1.001 | 1.8% | 2.9% |

## scalar_squot_singleline.yml (4,820 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 36.0 | 35.9 | 0.998 | 0.3% | 0.4% |
| bm_fyaml_str | 29.7 | 29.6 | 0.996 | 0.2% | 0.3% |
| bm_fyaml_str_reserve | 29.8 | 29.6 | 0.994 | 0.2% | 0.2% |
| bm_ryml_yaml_file | 10.2 | 10.3 | 1.002 | 0.7% | 0.5% |
| bm_ryml_yaml_ofstream | 10.9 | 11.0 | 1.003 | 0.5% | 0.8% |
| bm_ryml_yaml_ostream | 9.4 | 9.4 | 0.995 | 0.2% | 0.6% |
| bm_ryml_yaml_str | 4.9 | 4.9 | 0.990 | 1.9% | 1.3% |
| bm_ryml_yaml_str_file | 6.5 | 6.5 | 0.990 | 1.4% | 1.1% |
| bm_ryml_yaml_str_reserve | 4.9 | 4.9 | 1.000 | 1.7% | 1.8% |
| bm_yamlcpp | 449.0 | 447.2 | 0.996 | 3.3% | 2.2% |

## scalar_plain_multiline.yml (72,041 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,466.9 | 1,434.1 | 0.978 | 0.4% | 0.1% |
| bm_fyaml_str | 1,428.5 | 1,426.9 | 0.999 | 0.2% | 0.2% |
| bm_fyaml_str_reserve | 1,428.1 | 1,426.6 | 0.999 | 0.3% | 0.2% |
| bm_ryml_yaml_file | 46.6 | 46.5 | 0.998 | 0.5% | 1.4% |
| bm_ryml_yaml_ofstream | 44.0 | 44.0 | 1.001 | 0.3% | 0.1% |
| bm_ryml_yaml_ostream | 35.6 | 35.4 | 0.996 | 0.2% | 0.1% |
| bm_ryml_yaml_str | 30.2 | 30.2 | 1.000 | 0.3% | 0.0% |
| bm_ryml_yaml_str_file | 33.7 | 33.6 | 0.999 | 0.1% | 0.2% |
| bm_ryml_yaml_str_reserve | 30.7 | 30.7 | 1.000 | 0.2% | 0.1% |
| bm_yamlcpp | 6,605.1 | 6,576.1 | 0.996 | 0.6% | 1.1% |

## scalar_plain_singleline.yml (4,676 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 107.3 | 107.2 | 0.999 | 0.2% | 0.4% |
| bm_fyaml_str | 107.3 | 106.7 | 0.995 | 0.6% | 0.3% |
| bm_fyaml_str_reserve | 107.3 | 106.7 | 0.994 | 0.6% | 0.1% |
| bm_ryml_yaml_file | 9.0 | 9.0 | 1.000 | 0.8% | 0.8% |
| bm_ryml_yaml_ofstream | 9.3 | 9.3 | 0.996 | 0.4% | 0.4% |
| bm_ryml_yaml_ostream | 7.8 | 7.8 | 0.994 | 1.1% | 0.4% |
| bm_ryml_yaml_str | 3.9 | 4.0 | 1.011 | 1.6% | 3.2% |
| bm_ryml_yaml_str_file | 5.6 | 5.6 | 0.996 | 0.6% | 0.9% |
| bm_ryml_yaml_str_reserve | 4.0 | 4.0 | 1.001 | 0.8% | 1.0% |
| bm_yamlcpp | 473.1 | 471.4 | 0.996 | 2.3% | 8.8% |

## scalar_block_literal_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,462.4 | 1,468.7 | 1.004 | 0.6% | 0.4% |
| bm_fyaml_str | 1,433.6 | 1,470.4 | 1.026 | 1.0% | 0.6% |
| bm_fyaml_str_reserve | 1,433.7 | 1,471.0 | 1.026 | 0.9% | 0.7% |
| bm_ryml_yaml_file | 78.1 | 77.4 | 0.991 | 0.6% | 1.6% |
| bm_ryml_yaml_ofstream | 83.0 | 82.9 | 0.999 | 0.6% | 1.0% |
| bm_ryml_yaml_ostream | 70.7 | 70.9 | 1.003 | 0.3% | 1.2% |
| bm_ryml_yaml_str | 35.0 | 34.9 | 0.996 | 0.5% | 3.9% |
| bm_ryml_yaml_str_file | 38.9 | 38.8 | 0.998 | 0.1% | 0.2% |
| bm_ryml_yaml_str_reserve | 35.6 | 35.5 | 0.999 | 0.5% | 3.9% |
| bm_yamlcpp | 2,294.7 | 2,293.6 | 0.999 | 0.7% | 0.4% |

## scalar_block_literal_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 119.1 | 119.5 | 1.004 | 0.1% | 0.6% |
| bm_fyaml_str | 114.4 | 114.1 | 0.997 | 0.2% | 0.3% |
| bm_fyaml_str_reserve | 114.4 | 114.0 | 0.997 | 0.2% | 0.2% |
| bm_ryml_yaml_file | 10.6 | 10.6 | 0.999 | 0.5% | 0.4% |
| bm_ryml_yaml_ofstream | 12.2 | 12.2 | 0.999 | 2.8% | 0.5% |
| bm_ryml_yaml_ostream | 10.6 | 10.6 | 0.999 | 0.5% | 0.5% |
| bm_ryml_yaml_str | 4.7 | 4.7 | 1.007 | 0.8% | 0.7% |
| bm_ryml_yaml_str_file | 6.4 | 6.4 | 1.001 | 0.8% | 0.7% |
| bm_ryml_yaml_str_reserve | 4.8 | 4.8 | 1.004 | 0.6% | 3.7% |
| bm_yamlcpp | 554.1 | 553.2 | 0.998 | 0.4% | 1.0% |

## scalar_block_folded_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,474.8 | 1,474.5 | 1.000 | 0.3% | 0.5% |
| bm_fyaml_str | 1,465.4 | 1,513.4 | 1.033 | 0.3% | 0.5% |
| bm_fyaml_str_reserve | 1,466.0 | 1,513.8 | 1.033 | 0.4% | 0.5% |
| bm_ryml_yaml_file | 48.2 | 48.1 | 0.997 | 0.5% | 0.3% |
| bm_ryml_yaml_ofstream | 72.5 | 72.5 | 1.000 | 0.8% | 0.6% |
| bm_ryml_yaml_ostream | 63.7 | 63.7 | 1.000 | 0.1% | 0.1% |
| bm_ryml_yaml_str | 31.2 | 31.2 | 1.002 | 0.3% | 0.4% |
| bm_ryml_yaml_str_file | 34.7 | 34.7 | 0.999 | 0.2% | 0.4% |
| bm_ryml_yaml_str_reserve | 31.7 | 31.7 | 1.000 | 0.2% | 0.4% |
| bm_yamlcpp | 7,773.6 | 7,752.9 | 0.997 | 0.7% | 1.0% |

## scalar_block_folded_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 126.5 | 127.2 | 1.005 | 0.3% | 0.2% |
| bm_fyaml_str | 119.6 | 122.2 | 1.022 | 0.3% | 0.3% |
| bm_fyaml_str_reserve | 119.5 | 122.2 | 1.023 | 0.2% | 0.1% |
| bm_ryml_yaml_file | 10.6 | 10.5 | 0.991 | 0.3% | 0.5% |
| bm_ryml_yaml_ofstream | 14.1 | 13.7 | 0.972 | 3.1% | 3.1% |
| bm_ryml_yaml_ostream | 12.0 | 11.9 | 0.996 | 1.5% | 0.6% |
| bm_ryml_yaml_str | 4.8 | 4.8 | 0.999 | 2.1% | 0.7% |
| bm_ryml_yaml_str_file | 6.4 | 6.4 | 0.996 | 0.4% | 0.4% |
| bm_ryml_yaml_str_reserve | 4.8 | 4.9 | 1.003 | 2.9% | 2.4% |
| bm_yamlcpp | 551.4 | 549.3 | 0.996 | 1.3% | 1.2% |

## medium.yaml (22,421,093 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 47.6 | 47.6 | 1.000 | 0.3% | 0.2% |
| bm_fyaml_str | 42.6 | 42.2 | 0.992 | 0.3% | 0.1% |
| bm_fyaml_str_reserve | 43.7 | 43.1 | 0.988 | 0.6% | 0.2% |
| bm_ryml_yaml_file | 76,888 | 77,282 | 1.005 | 0.8% | 1.3% |
| bm_ryml_yaml_ofstream | 114,470 | 114,701 | 1.002 | 0.4% | 0.4% |
| bm_ryml_yaml_ostream | 105,437 | 105,747 | 1.003 | 0.2% | 0.9% |
| bm_ryml_yaml_str | 24,327 | 24,423 | 1.004 | 0.2% | 0.4% |
| bm_ryml_yaml_str_file | 26,918 | 26,887 | 0.999 | 1.1% | 2.3% |
| bm_ryml_yaml_str_reserve | 23,938 | 24,049 | 1.005 | 0.6% | 0.4% |
| bm_yamlcpp | 163.6 | 162.9 | 0.996 | 0.8% | 0.9% |

## big_scalar_block_literal_multiline.yml (1,088,715 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,458.7 | 1,463.5 | 1.003 | 0.3% | 1.2% |
| bm_fyaml_str | 1,459.9 | 1,464.4 | 1.003 | 0.2% | 0.3% |
| bm_fyaml_str_reserve | 1,463.6 | 1,470.8 | 1.005 | 0.4% | 0.5% |
| bm_ryml_yaml_file | 1,198.7 | 1,198.6 | 1.000 | 0.9% | 1.0% |
| bm_ryml_yaml_ofstream | 1,280.4 | 1,282.4 | 1.002 | 0.6% | 1.8% |
| bm_ryml_yaml_ostream | 1,068.9 | 1,068.6 | 1.000 | 1.6% | 1.4% |
| bm_ryml_yaml_str | 539.0 | 538.2 | 0.999 | 0.8% | 0.7% |
| bm_ryml_yaml_str_file | 588.0 | 588.4 | 1.001 | 1.1% | 1.2% |
| bm_ryml_yaml_str_reserve | 554.6 | 554.6 | 1.000 | 0.4% | 0.4% |
| bm_yamlcpp | 2,297.0 | 2,302.1 | 1.002 | 0.8% | 0.6% |

## big_scalar_dquot_multiline.yml (1,082,775 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,492.8 | 1,492.9 | 1.000 | 0.6% | 0.3% |
| bm_fyaml_str | 1,483.7 | 1,485.0 | 1.001 | 0.4% | 0.4% |
| bm_fyaml_str_reserve | 1,484.5 | 1,485.6 | 1.001 | 0.3% | 0.3% |
| bm_ryml_yaml_file | 1,425.3 | 1,426.4 | 1.001 | 13.2% | 13.0% |
| bm_ryml_yaml_ofstream | 1,354.9 | 1,360.2 | 1.004 | 1.7% | 2.5% |
| bm_ryml_yaml_ostream | 1,193.9 | 1,195.9 | 1.002 | 0.3% | 0.6% |
| bm_ryml_yaml_str | 1,055.8 | 1,057.6 | 1.002 | 0.3% | 1.7% |
| bm_ryml_yaml_str_file | 1,104.0 | 1,105.8 | 1.002 | 0.3% | 0.5% |
| bm_ryml_yaml_str_reserve | 1,072.8 | 1,074.1 | 1.001 | 0.3% | 0.8% |
| bm_yamlcpp | 6,016.0 | 5,978.9 | 0.994 | 1.3% | 1.0% |

## big_scalar_plain_multiline.yml (1,080,675 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,434.8 | 1,436.0 | 1.001 | 0.3% | 0.3% |
| bm_fyaml_str | 1,427.1 | 1,428.5 | 1.001 | 0.3% | 0.2% |
| bm_fyaml_str_reserve | 1,428.3 | 1,428.9 | 1.000 | 0.3% | 0.1% |
| bm_ryml_yaml_file | 715.6 | 712.5 | 0.996 | 0.9% | 0.6% |
| bm_ryml_yaml_ofstream | 680.6 | 681.3 | 1.001 | 0.9% | 0.3% |
| bm_ryml_yaml_ostream | 539.5 | 540.6 | 1.002 | 0.3% | 0.4% |
| bm_ryml_yaml_str | 456.2 | 456.2 | 1.000 | 0.1% | 0.2% |
| bm_ryml_yaml_str_file | 503.2 | 503.5 | 1.001 | 0.7% | 0.5% |
| bm_ryml_yaml_str_reserve | 473.8 | 473.5 | 0.999 | 0.3% | 0.2% |
| bm_yamlcpp | 6,575.9 | 6,550.3 | 0.996 | 1.7% | 1.9% |

