# bm_emit: master against branch, every case and row

Times are the median CPU time of 5 repetitions, in microseconds. Ratio is branch / master: below 1 is faster. Spread is (slowest - fastest) / median over the 5 repetitions. Source: `compare.csv`.

## appveyor.yml (2,129 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 31.7 | 31.4 | 0.991 | 0.2% | 0.1% |
| bm_fyaml_str | 27.9 | 27.2 | 0.975 | 0.5% | 0.4% |
| bm_fyaml_str_reserve | 27.8 | 27.2 | 0.978 | 0.4% | 0.3% |
| bm_ryml_yaml_file | 5.5 | 5.5 | 1.003 | 1.2% | 0.6% |
| bm_ryml_yaml_ofstream | 7.0 | 7.0 | 0.998 | 0.6% | 0.9% |
| bm_ryml_yaml_ostream | 6.0 | 6.0 | 0.996 | 0.3% | 0.7% |
| bm_ryml_yaml_str | 2.0 | 2.0 | 0.999 | 1.8% | 1.9% |
| bm_ryml_yaml_str_file | 3.0 | 3.0 | 1.004 | 0.9% | 1.0% |
| bm_ryml_yaml_str_reserve | 2.1 | 2.1 | 1.007 | 1.3% | 1.6% |
| bm_yamlcpp | 159.6 | 159.1 | 0.997 | 0.5% | 0.8% |

## compile_commands.json (46,826 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 182.3 | 180.5 | 0.990 | 0.2% | 0.3% |
| bm_fyaml_str | 148.1 | 148.1 | 1.000 | 0.2% | 0.2% |
| bm_fyaml_str_reserve | 147.8 | 147.6 | 0.999 | 0.1% | 0.1% |
| bm_jsoncpp | 106.0 | 107.0 | 1.010 | 0.4% | 0.1% |
| bm_nlohmann | 165.5 | 165.6 | 1.001 | 0.9% | 0.5% |
| bm_rapidjson | 100.4 | 100.5 | 1.000 | 1.2% | 1.3% |
| bm_ryml_json_file | 89.8 | 89.4 | 0.996 | 0.7% | 0.6% |
| bm_ryml_json_ofstream | 95.2 | 95.2 | 1.000 | 0.1% | 0.1% |
| bm_ryml_json_ostream | 87.0 | 87.2 | 1.002 | 0.2% | 11.2% |
| bm_ryml_json_str | 75.9 | 76.0 | 1.002 | 0.0% | 0.5% |
| bm_ryml_json_str_file | 79.3 | 79.3 | 1.000 | 1.0% | 1.3% |
| bm_ryml_json_str_reserve | 76.2 | 76.3 | 1.002 | 0.2% | 0.2% |
| bm_ryml_yaml_file | 78.8 | 78.9 | 1.002 | 1.6% | 1.7% |
| bm_ryml_yaml_ofstream | 88.4 | 88.6 | 1.003 | 1.3% | 0.4% |
| bm_ryml_yaml_ostream | 79.4 | 79.0 | 0.995 | 0.2% | 0.5% |
| bm_ryml_yaml_str | 54.2 | 54.2 | 0.999 | 0.3% | 0.2% |
| bm_ryml_yaml_str_file | 57.6 | 57.4 | 0.997 | 1.0% | 0.1% |
| bm_ryml_yaml_str_reserve | 54.5 | 54.5 | 1.000 | 0.1% | 0.3% |
| bm_yamlcpp | 5,229.9 | 5,192.2 | 0.993 | 2.6% | 0.8% |

## travis.yml (4,067 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 68.3 | 68.1 | 0.997 | 0.3% | 0.3% |
| bm_fyaml_str | 62.4 | 61.6 | 0.988 | 0.5% | 0.2% |
| bm_fyaml_str_reserve | 62.3 | 61.6 | 0.989 | 0.3% | 0.4% |
| bm_ryml_yaml_file | 7.1 | 7.1 | 0.996 | 0.5% | 0.2% |
| bm_ryml_yaml_ofstream | 8.5 | 8.6 | 1.007 | 0.8% | 0.4% |
| bm_ryml_yaml_ostream | 7.4 | 7.4 | 0.997 | 0.5% | 0.8% |
| bm_ryml_yaml_str | 3.1 | 3.1 | 1.000 | 0.6% | 0.4% |
| bm_ryml_yaml_str_file | 4.1 | 4.1 | 1.002 | 0.7% | 1.0% |
| bm_ryml_yaml_str_reserve | 3.1 | 3.1 | 1.005 | 0.6% | 0.3% |
| bm_yamlcpp | 298.0 | 298.3 | 1.001 | 1.4% | 0.9% |

## scalar_dquot_multiline.yml (72,181 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,503.3 | 1,502.8 | 1.000 | 0.5% | 0.1% |
| bm_fyaml_str | 1,523.5 | 1,524.6 | 1.001 | 0.4% | 0.3% |
| bm_fyaml_str_reserve | 1,522.0 | 1,522.2 | 1.000 | 0.4% | 0.3% |
| bm_ryml_yaml_file | 93.1 | 93.2 | 1.002 | 13.5% | 13.0% |
| bm_ryml_yaml_ofstream | 89.0 | 89.0 | 1.000 | 2.8% | 0.1% |
| bm_ryml_yaml_ostream | 78.9 | 78.9 | 1.000 | 0.1% | 0.3% |
| bm_ryml_yaml_str | 70.0 | 70.1 | 1.001 | 0.1% | 0.4% |
| bm_ryml_yaml_str_file | 73.6 | 73.6 | 1.000 | 0.2% | 0.2% |
| bm_ryml_yaml_str_reserve | 70.5 | 70.6 | 1.001 | 0.1% | 0.8% |
| bm_yamlcpp | 6,052.8 | 6,032.5 | 0.997 | 0.4% | 0.6% |

## scalar_dquot_singleline.yml (4,824 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 33.2 | 32.8 | 0.988 | 0.1% | 0.1% |
| bm_fyaml_str | 26.9 | 26.9 | 0.999 | 0.3% | 0.2% |
| bm_fyaml_str_reserve | 26.9 | 26.8 | 0.998 | 0.3% | 0.2% |
| bm_ryml_yaml_file | 12.2 | 12.3 | 1.003 | 0.2% | 1.1% |
| bm_ryml_yaml_ofstream | 12.9 | 13.0 | 1.008 | 1.1% | 0.2% |
| bm_ryml_yaml_ostream | 11.2 | 11.2 | 0.999 | 0.2% | 0.2% |
| bm_ryml_yaml_str | 6.8 | 6.8 | 1.002 | 0.8% | 10.8% |
| bm_ryml_yaml_str_file | 8.4 | 8.4 | 1.001 | 0.7% | 0.4% |
| bm_ryml_yaml_str_reserve | 6.9 | 6.9 | 1.007 | 0.9% | 1.5% |
| bm_yamlcpp | 451.9 | 450.4 | 0.997 | 1.2% | 1.7% |

## scalar_squot_multiline.yml (72,273 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,408.9 | 1,410.2 | 1.001 | 0.2% | 0.3% |
| bm_fyaml_str | 1,427.2 | 1,427.2 | 1.000 | 0.2% | 0.3% |
| bm_fyaml_str_reserve | 1,427.1 | 1,429.4 | 1.002 | 0.2% | 0.3% |
| bm_ryml_yaml_file | 67.2 | 67.0 | 0.998 | 0.2% | 0.2% |
| bm_ryml_yaml_ofstream | 65.2 | 65.3 | 1.001 | 0.2% | 0.5% |
| bm_ryml_yaml_ostream | 55.1 | 55.0 | 0.999 | 0.2% | 0.9% |
| bm_ryml_yaml_str | 44.4 | 44.5 | 1.002 | 0.4% | 0.2% |
| bm_ryml_yaml_str_file | 48.0 | 48.0 | 0.999 | 0.3% | 0.4% |
| bm_ryml_yaml_str_reserve | 44.9 | 45.0 | 1.001 | 0.3% | 1.0% |
| bm_yamlcpp | 6,602.8 | 6,587.1 | 0.998 | 2.3% | 2.0% |

## scalar_squot_singleline.yml (4,820 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 36.0 | 35.7 | 0.991 | 0.3% | 0.2% |
| bm_fyaml_str | 29.9 | 29.7 | 0.995 | 0.2% | 0.4% |
| bm_fyaml_str_reserve | 29.9 | 29.7 | 0.995 | 0.1% | 0.2% |
| bm_ryml_yaml_file | 10.4 | 10.4 | 1.002 | 0.4% | 0.6% |
| bm_ryml_yaml_ofstream | 10.9 | 10.9 | 0.998 | 0.5% | 0.3% |
| bm_ryml_yaml_ostream | 9.4 | 9.4 | 1.003 | 0.3% | 0.5% |
| bm_ryml_yaml_str | 4.9 | 4.9 | 0.997 | 1.4% | 0.9% |
| bm_ryml_yaml_str_file | 6.5 | 6.5 | 0.989 | 1.5% | 1.2% |
| bm_ryml_yaml_str_reserve | 5.0 | 4.9 | 0.988 | 1.2% | 1.2% |
| bm_yamlcpp | 454.2 | 449.4 | 0.990 | 0.8% | 2.3% |

## scalar_plain_multiline.yml (72,041 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,436.1 | 1,438.2 | 1.001 | 0.2% | 0.2% |
| bm_fyaml_str | 1,460.3 | 1,462.7 | 1.002 | 0.1% | 0.2% |
| bm_fyaml_str_reserve | 1,461.1 | 1,463.1 | 1.001 | 0.1% | 0.2% |
| bm_ryml_yaml_file | 46.7 | 46.6 | 0.997 | 0.5% | 0.3% |
| bm_ryml_yaml_ofstream | 44.0 | 44.1 | 1.002 | 0.2% | 0.6% |
| bm_ryml_yaml_ostream | 35.4 | 35.5 | 1.001 | 0.1% | 0.1% |
| bm_ryml_yaml_str | 30.2 | 30.2 | 1.000 | 0.0% | 0.1% |
| bm_ryml_yaml_str_file | 33.7 | 33.6 | 0.999 | 0.4% | 0.2% |
| bm_ryml_yaml_str_reserve | 30.7 | 30.7 | 1.001 | 0.1% | 0.1% |
| bm_yamlcpp | 6,707.9 | 6,679.1 | 0.996 | 1.5% | 1.2% |

## scalar_plain_singleline.yml (4,676 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 107.4 | 107.1 | 0.997 | 0.3% | 0.2% |
| bm_fyaml_str | 104.4 | 103.9 | 0.995 | 0.4% | 0.1% |
| bm_fyaml_str_reserve | 104.4 | 103.9 | 0.996 | 0.4% | 0.2% |
| bm_ryml_yaml_file | 9.1 | 9.0 | 0.995 | 0.2% | 0.7% |
| bm_ryml_yaml_ofstream | 9.3 | 9.2 | 0.997 | 0.6% | 0.6% |
| bm_ryml_yaml_ostream | 7.8 | 7.7 | 0.997 | 0.6% | 0.1% |
| bm_ryml_yaml_str | 3.9 | 4.0 | 1.008 | 1.2% | 1.4% |
| bm_ryml_yaml_str_file | 5.6 | 5.6 | 0.999 | 0.8% | 0.9% |
| bm_ryml_yaml_str_reserve | 4.0 | 4.0 | 1.003 | 0.9% | 1.4% |
| bm_yamlcpp | 473.9 | 476.5 | 1.005 | 0.6% | 0.6% |

## scalar_block_literal_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,462.7 | 1,461.0 | 0.999 | 0.2% | 0.3% |
| bm_fyaml_str | 1,431.1 | 1,429.2 | 0.999 | 0.4% | 0.7% |
| bm_fyaml_str_reserve | 1,430.0 | 1,429.0 | 0.999 | 0.3% | 0.3% |
| bm_ryml_yaml_file | 78.1 | 77.8 | 0.996 | 1.5% | 0.9% |
| bm_ryml_yaml_ofstream | 84.2 | 84.3 | 1.001 | 0.4% | 0.1% |
| bm_ryml_yaml_ostream | 71.0 | 71.0 | 1.000 | 1.4% | 1.1% |
| bm_ryml_yaml_str | 35.0 | 34.9 | 0.997 | 0.7% | 2.0% |
| bm_ryml_yaml_str_file | 38.9 | 38.8 | 0.997 | 0.2% | 0.5% |
| bm_ryml_yaml_str_reserve | 35.6 | 35.4 | 0.996 | 2.1% | 1.8% |
| bm_yamlcpp | 2,291.3 | 2,290.1 | 0.999 | 0.6% | 0.5% |

## scalar_block_literal_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 119.5 | 119.4 | 0.999 | 0.5% | 0.2% |
| bm_fyaml_str | 112.1 | 110.8 | 0.989 | 0.2% | 0.1% |
| bm_fyaml_str_reserve | 112.1 | 110.8 | 0.989 | 0.2% | 0.1% |
| bm_ryml_yaml_file | 10.7 | 10.6 | 0.998 | 0.8% | 0.8% |
| bm_ryml_yaml_ofstream | 12.4 | 12.4 | 1.003 | 0.8% | 0.6% |
| bm_ryml_yaml_ostream | 10.7 | 10.6 | 0.995 | 0.4% | 0.5% |
| bm_ryml_yaml_str | 4.7 | 4.7 | 1.007 | 0.9% | 3.0% |
| bm_ryml_yaml_str_file | 6.4 | 6.4 | 1.002 | 0.8% | 1.5% |
| bm_ryml_yaml_str_reserve | 4.7 | 4.9 | 1.028 | 1.5% | 5.0% |
| bm_yamlcpp | 553.0 | 552.5 | 0.999 | 0.5% | 1.0% |

## scalar_block_folded_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,470.5 | 1,472.1 | 1.001 | 0.5% | 0.4% |
| bm_fyaml_str | 1,510.7 | 1,465.0 | 0.970 | 0.5% | 0.3% |
| bm_fyaml_str_reserve | 1,513.2 | 1,464.7 | 0.968 | 0.4% | 0.4% |
| bm_ryml_yaml_file | 48.2 | 48.2 | 1.000 | 0.2% | 0.6% |
| bm_ryml_yaml_ofstream | 72.4 | 72.6 | 1.003 | 0.4% | 0.0% |
| bm_ryml_yaml_ostream | 63.6 | 63.6 | 1.000 | 0.2% | 0.2% |
| bm_ryml_yaml_str | 31.1 | 31.3 | 1.006 | 0.2% | 0.5% |
| bm_ryml_yaml_str_file | 34.7 | 34.7 | 1.001 | 0.5% | 0.3% |
| bm_ryml_yaml_str_reserve | 31.6 | 31.7 | 1.003 | 0.2% | 0.3% |
| bm_yamlcpp | 7,796.9 | 7,756.0 | 0.995 | 2.6% | 0.8% |

## scalar_block_folded_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 126.9 | 127.0 | 1.001 | 0.2% | 0.3% |
| bm_fyaml_str | 119.3 | 118.3 | 0.992 | 0.2% | 0.5% |
| bm_fyaml_str_reserve | 119.2 | 118.4 | 0.993 | 0.1% | 0.1% |
| bm_ryml_yaml_file | 10.6 | 10.5 | 0.995 | 0.2% | 0.7% |
| bm_ryml_yaml_ofstream | 13.9 | 14.0 | 1.005 | 2.7% | 2.3% |
| bm_ryml_yaml_ostream | 12.0 | 12.0 | 0.999 | 0.9% | 0.3% |
| bm_ryml_yaml_str | 4.8 | 4.8 | 1.003 | 0.3% | 2.5% |
| bm_ryml_yaml_str_file | 6.4 | 6.4 | 0.999 | 0.6% | 0.5% |
| bm_ryml_yaml_str_reserve | 4.8 | 4.9 | 1.023 | 0.8% | 2.6% |
| bm_yamlcpp | 551.5 | 552.4 | 1.002 | 1.0% | 1.0% |

## medium.yaml (22,421,093 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 48.0 | 47.9 | 0.996 | 0.2% | 0.2% |
| bm_fyaml_str | 42.4 | 41.9 | 0.987 | 0.9% | 0.5% |
| bm_fyaml_str_reserve | 43.4 | 42.9 | 0.987 | 0.2% | 0.8% |
| bm_ryml_yaml_file | 74,948 | 75,180 | 1.003 | 0.4% | 0.9% |
| bm_ryml_yaml_ofstream | 112,219 | 112,322 | 1.001 | 0.4% | 0.8% |
| bm_ryml_yaml_ostream | 107,894 | 108,123 | 1.002 | 7.9% | 0.8% |
| bm_ryml_yaml_str | 24,412 | 24,536 | 1.005 | 0.6% | 0.4% |
| bm_ryml_yaml_str_file | 26,917 | 26,973 | 1.002 | 1.3% | 1.1% |
| bm_ryml_yaml_str_reserve | 23,983 | 24,138 | 1.006 | 0.4% | 0.4% |
| bm_yamlcpp | 163.8 | 163.6 | 0.999 | 0.7% | 0.9% |

## big_scalar_block_literal_multiline.yml (1,088,715 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,458.4 | 1,486.9 | 1.020 | 0.6% | 0.3% |
| bm_fyaml_str | 1,429.3 | 1,429.0 | 1.000 | 0.6% | 0.4% |
| bm_fyaml_str_reserve | 1,433.0 | 1,432.5 | 1.000 | 0.2% | 0.4% |
| bm_ryml_yaml_file | 1,195.1 | 1,194.9 | 1.000 | 0.8% | 0.7% |
| bm_ryml_yaml_ofstream | 1,297.0 | 1,277.2 | 0.985 | 0.4% | 1.0% |
| bm_ryml_yaml_ostream | 1,064.4 | 1,089.0 | 1.023 | 0.8% | 0.8% |
| bm_ryml_yaml_str | 537.7 | 535.2 | 0.995 | 0.8% | 0.2% |
| bm_ryml_yaml_str_file | 583.1 | 582.9 | 1.000 | 1.0% | 1.2% |
| bm_ryml_yaml_str_reserve | 552.5 | 551.6 | 0.998 | 1.2% | 1.6% |
| bm_yamlcpp | 2,288.2 | 2,347.9 | 1.026 | 0.3% | 0.6% |

## big_scalar_dquot_multiline.yml (1,082,775 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,498.9 | 1,493.5 | 0.996 | 0.3% | 0.3% |
| bm_fyaml_str | 1,521.0 | 1,483.9 | 0.976 | 0.4% | 0.3% |
| bm_fyaml_str_reserve | 1,521.6 | 1,484.1 | 0.975 | 0.4% | 0.2% |
| bm_ryml_yaml_file | 1,417.3 | 1,420.9 | 1.003 | 0.6% | 7.1% |
| bm_ryml_yaml_ofstream | 1,355.7 | 1,358.1 | 1.002 | 0.6% | 0.6% |
| bm_ryml_yaml_ostream | 1,195.3 | 1,193.0 | 0.998 | 0.2% | 0.2% |
| bm_ryml_yaml_str | 1,059.6 | 1,056.0 | 0.997 | 0.6% | 0.2% |
| bm_ryml_yaml_str_file | 1,105.5 | 1,106.5 | 1.001 | 0.2% | 1.4% |
| bm_ryml_yaml_str_reserve | 1,073.4 | 1,073.2 | 1.000 | 0.3% | 2.4% |
| bm_yamlcpp | 6,099.1 | 6,010.0 | 0.985 | 1.3% | 0.6% |

## big_scalar_plain_multiline.yml (1,080,675 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_fyaml_ostream | 1,435.3 | 1,433.5 | 0.999 | 0.3% | 0.2% |
| bm_fyaml_str | 1,463.5 | 1,429.5 | 0.977 | 0.2% | 0.1% |
| bm_fyaml_str_reserve | 1,462.9 | 1,428.4 | 0.976 | 0.3% | 0.1% |
| bm_ryml_yaml_file | 712.4 | 713.4 | 1.001 | 0.7% | 1.2% |
| bm_ryml_yaml_ofstream | 679.4 | 685.1 | 1.009 | 1.1% | 1.0% |
| bm_ryml_yaml_ostream | 540.1 | 540.5 | 1.001 | 0.5% | 0.7% |
| bm_ryml_yaml_str | 455.8 | 455.4 | 0.999 | 0.1% | 0.1% |
| bm_ryml_yaml_str_file | 500.8 | 501.0 | 1.000 | 0.7% | 1.1% |
| bm_ryml_yaml_str_reserve | 472.6 | 473.0 | 1.001 | 0.3% | 0.3% |
| bm_yamlcpp | 6,641.2 | 6,565.4 | 0.989 | 1.5% | 1.0% |

