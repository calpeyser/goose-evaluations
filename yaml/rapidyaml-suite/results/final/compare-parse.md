# bm_parse: master against branch, every case and row

Times are the median CPU time of 5 repetitions, in microseconds. Ratio is branch / master: below 1 is faster. Spread is (slowest - fastest) / median over the 5 repetitions. Source: `compare.csv`.

## appveyor.yml (2,129 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 56.5 | 56.0 | 0.991 | 0.6% | 0.9% |
| bm_libyaml_arena | 35.7 | 35.2 | 0.987 | 0.3% | 0.2% |
| bm_libyaml_arena_reuse | 35.1 | 34.8 | 0.989 | 0.3% | 0.2% |
| bm_ryml_yaml_arena | 11.1 | 10.8 | 0.975 | 0.5% | 0.8% |
| bm_ryml_yaml_arena_nofilter | 10.9 | 10.6 | 0.974 | 0.4% | 0.9% |
| bm_ryml_yaml_arena_nofilter_reserve | 10.0 | 10.1 | 1.010 | 0.5% | 0.5% |
| bm_ryml_yaml_arena_reserve | 10.5 | 10.6 | 1.012 | 0.3% | 0.5% |
| bm_ryml_yaml_arena_reuse | 10.1 | 10.2 | 1.015 | 0.5% | 0.8% |
| bm_ryml_yaml_arena_reuse_nofilter | 10.9 | 10.6 | 0.972 | 0.5% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 9.8 | 9.9 | 1.014 | 0.5% | 0.4% |
| bm_ryml_yaml_arena_reuse_reserve | 10.1 | 10.2 | 1.011 | 0.5% | 0.6% |
| bm_ryml_yaml_inplace | 11.3 | 11.0 | 0.974 | 0.4% | 0.7% |
| bm_ryml_yaml_inplace_nofilter | 10.8 | 10.5 | 0.972 | 0.4% | 0.5% |
| bm_ryml_yaml_inplace_nofilter_reserve | 9.8 | 10.0 | 1.011 | 0.3% | 0.5% |
| bm_ryml_yaml_inplace_reserve | 10.3 | 10.5 | 1.017 | 0.7% | 0.5% |
| bm_ryml_yaml_inplace_reuse | 10.1 | 10.2 | 1.015 | 0.8% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter | 9.7 | 9.9 | 1.017 | 0.4% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 9.8 | 9.9 | 1.016 | 0.7% | 0.5% |
| bm_ryml_yaml_inplace_reuse_reserve | 10.1 | 10.2 | 1.016 | 0.8% | 0.3% |
| bm_rymlints_yaml_inplace | 18.8 | 18.8 | 1.003 | 0.7% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter | 18.1 | 18.1 | 1.000 | 0.9% | 0.8% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 9.2 | 9.2 | 1.002 | 0.2% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 9.6 | 9.6 | 1.002 | 0.4% | 1.2% |
| bm_rymlints_yaml_inplace_reuse | 9.4 | 9.4 | 1.001 | 1.2% | 0.7% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 9.1 | 9.1 | 1.001 | 1.5% | 0.9% |
| bm_yamlcpp_arena | 216.1 | 216.9 | 1.004 | 0.8% | 1.0% |

## compile_commands.json (46,826 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_jsoncpp_arena | 188.3 | 186.3 | 0.989 | 1.5% | 0.9% |
| bm_libfyaml_arena | 331.0 | 329.7 | 0.996 | 1.0% | 1.4% |
| bm_libyaml_arena | 445.6 | 422.2 | 0.948 | 0.2% | 0.4% |
| bm_libyaml_arena_reuse | 441.3 | 418.2 | 0.948 | 2.3% | 2.5% |
| bm_nlohmann_arena | 357.2 | 395.4 | 1.107 | 0.2% | 0.2% |
| bm_rapidjson_arena | 95.2 | 95.1 | 1.000 | 0.3% | 0.3% |
| bm_rapidjson_inplace | 35.3 | 35.3 | 0.999 | 0.3% | 0.3% |
| bm_ryml_json_arena | 71.2 | 69.2 | 0.972 | 0.3% | 0.9% |
| bm_ryml_json_arena_nofilter | 71.3 | 69.3 | 0.972 | 0.4% | 1.5% |
| bm_ryml_json_arena_nofilter_reserve | 67.6 | 67.6 | 1.000 | 1.1% | 1.9% |
| bm_ryml_json_arena_reserve | 67.9 | 67.4 | 0.993 | 0.5% | 1.5% |
| bm_ryml_json_arena_reuse | 67.2 | 67.1 | 0.999 | 0.8% | 1.5% |
| bm_ryml_json_arena_reuse_nofilter | 67.2 | 67.1 | 0.998 | 0.7% | 0.7% |
| bm_ryml_json_arena_reuse_nofilter_reserve | 67.1 | 67.1 | 0.999 | 0.6% | 0.4% |
| bm_ryml_json_arena_reuse_reserve | 67.2 | 67.1 | 0.998 | 0.7% | 1.2% |
| bm_ryml_json_inplace | 70.5 | 68.4 | 0.970 | 0.9% | 1.5% |
| bm_ryml_json_inplace_nofilter | 70.2 | 68.2 | 0.972 | 0.8% | 0.8% |
| bm_ryml_json_inplace_nofilter_reserve | 66.1 | 66.1 | 1.000 | 0.7% | 0.5% |
| bm_ryml_json_inplace_reserve | 66.5 | 66.4 | 0.998 | 0.7% | 1.4% |
| bm_ryml_json_inplace_reuse | 66.1 | 65.9 | 0.997 | 0.5% | 0.5% |
| bm_ryml_json_inplace_reuse_nofilter | 66.1 | 66.0 | 0.999 | 0.6% | 1.0% |
| bm_ryml_json_inplace_reuse_nofilter_reserve | 66.1 | 65.8 | 0.995 | 0.7% | 0.9% |
| bm_ryml_json_inplace_reuse_reserve | 66.2 | 66.0 | 0.997 | 0.3% | 0.3% |
| bm_ryml_yaml_arena | 74.7 | 73.4 | 0.982 | 1.2% | 0.7% |
| bm_ryml_yaml_arena_nofilter | 75.0 | 73.5 | 0.980 | 0.7% | 1.0% |
| bm_ryml_yaml_arena_nofilter_reserve | 70.7 | 71.0 | 1.005 | 0.7% | 0.9% |
| bm_ryml_yaml_arena_reserve | 70.9 | 71.5 | 1.009 | 0.9% | 0.8% |
| bm_ryml_yaml_arena_reuse | 70.3 | 70.4 | 1.001 | 1.0% | 1.0% |
| bm_ryml_yaml_arena_reuse_nofilter | 74.8 | 73.5 | 0.982 | 0.2% | 0.9% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 70.2 | 70.9 | 1.009 | 1.0% | 1.1% |
| bm_ryml_yaml_arena_reuse_reserve | 70.3 | 70.8 | 1.007 | 0.6% | 0.9% |
| bm_ryml_yaml_inplace | 74.0 | 72.4 | 0.978 | 0.5% | 0.8% |
| bm_ryml_yaml_inplace_nofilter | 73.7 | 72.4 | 0.982 | 0.2% | 0.6% |
| bm_ryml_yaml_inplace_nofilter_reserve | 69.5 | 69.6 | 1.001 | 0.5% | 1.1% |
| bm_ryml_yaml_inplace_reserve | 69.9 | 70.4 | 1.007 | 0.8% | 0.7% |
| bm_ryml_yaml_inplace_reuse | 69.1 | 69.6 | 1.008 | 1.1% | 1.2% |
| bm_ryml_yaml_inplace_reuse_nofilter | 69.2 | 69.8 | 1.008 | 1.0% | 0.7% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 69.2 | 69.9 | 1.010 | 0.7% | 0.8% |
| bm_ryml_yaml_inplace_reuse_reserve | 69.2 | 69.7 | 1.006 | 0.7% | 1.2% |
| bm_rymlints_estimate | 61.8 | 61.8 | 0.999 | 0.7% | 0.7% |
| bm_rymlints_json_inplace | 125.2 | 125.4 | 1.001 | 1.2% | 1.4% |
| bm_rymlints_json_inplace_nofilter | 125.5 | 125.1 | 0.997 | 1.3% | 0.8% |
| bm_rymlints_json_inplace_nofilter_reserve | 64.2 | 64.2 | 0.999 | 0.9% | 1.0% |
| bm_rymlints_json_inplace_reserve | 64.2 | 64.2 | 1.000 | 0.9% | 0.3% |
| bm_rymlints_json_inplace_reuse | 64.0 | 64.1 | 1.002 | 0.8% | 0.7% |
| bm_rymlints_json_inplace_reuse_nofilter | 63.9 | 64.3 | 1.006 | 0.5% | 1.0% |
| bm_rymlints_yaml_inplace | 132.0 | 132.3 | 1.002 | 0.8% | 0.6% |
| bm_rymlints_yaml_inplace_nofilter | 131.7 | 132.0 | 1.002 | 0.3% | 0.9% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 67.2 | 67.4 | 1.003 | 0.4% | 0.5% |
| bm_rymlints_yaml_inplace_reserve | 67.3 | 67.5 | 1.004 | 0.3% | 0.3% |
| bm_rymlints_yaml_inplace_reuse | 66.7 | 66.9 | 1.003 | 0.9% | 1.2% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 66.9 | 67.0 | 1.001 | 0.5% | 1.2% |
| bm_sajson_arena | 105.3 | 105.3 | 1.000 | 0.3% | 0.1% |
| bm_sajson_inplace | 104.6 | 104.5 | 0.999 | 0.2% | 0.1% |
| bm_yamlcpp_arena | 2,463.1 | 2,440.9 | 0.991 | 0.8% | 1.3% |

## travis.yml (4,067 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 80.1 | 79.2 | 0.989 | 0.6% | 0.9% |
| bm_libyaml_arena | 58.0 | 58.2 | 1.003 | 0.3% | 0.2% |
| bm_libyaml_arena_reuse | 57.7 | 57.6 | 0.998 | 1.6% | 0.4% |
| bm_ryml_yaml_arena | 18.4 | 18.0 | 0.977 | 0.5% | 0.3% |
| bm_ryml_yaml_arena_nofilter | 17.3 | 16.9 | 0.974 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_nofilter_reserve | 16.3 | 16.2 | 0.995 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_reserve | 17.7 | 17.6 | 0.995 | 0.6% | 0.3% |
| bm_ryml_yaml_arena_reuse | 17.3 | 17.3 | 1.000 | 0.4% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter | 17.3 | 16.8 | 0.973 | 0.6% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 16.0 | 16.0 | 0.999 | 0.6% | 0.4% |
| bm_ryml_yaml_arena_reuse_reserve | 17.3 | 17.3 | 0.999 | 0.4% | 0.2% |
| bm_ryml_yaml_inplace | 18.5 | 18.1 | 0.979 | 0.8% | 0.3% |
| bm_ryml_yaml_inplace_nofilter | 17.1 | 16.7 | 0.974 | 0.8% | 0.2% |
| bm_ryml_yaml_inplace_nofilter_reserve | 16.0 | 16.1 | 1.002 | 0.7% | 0.5% |
| bm_ryml_yaml_inplace_reserve | 17.5 | 17.4 | 0.999 | 0.5% | 0.4% |
| bm_ryml_yaml_inplace_reuse | 17.2 | 17.2 | 1.001 | 0.5% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter | 15.9 | 16.0 | 1.002 | 0.6% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 16.0 | 16.0 | 1.000 | 0.7% | 0.4% |
| bm_ryml_yaml_inplace_reuse_reserve | 17.2 | 17.2 | 1.000 | 0.5% | 0.2% |
| bm_rymlints_yaml_inplace | 32.8 | 32.8 | 1.000 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter | 30.2 | 30.2 | 1.000 | 0.2% | 0.7% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 15.4 | 15.3 | 1.000 | 0.1% | 0.6% |
| bm_rymlints_yaml_inplace_reserve | 16.6 | 16.7 | 1.001 | 0.4% | 0.5% |
| bm_rymlints_yaml_inplace_reuse | 16.5 | 16.6 | 1.003 | 0.3% | 0.6% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 15.3 | 15.2 | 0.996 | 0.3% | 0.6% |
| bm_yamlcpp_arena | 372.7 | 374.5 | 1.005 | 0.9% | 0.3% |

## scalar_dquot_multiline.yml (72,181 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 371.2 | 369.7 | 0.996 | 0.4% | 0.3% |
| bm_libyaml_arena | 550.9 | 549.1 | 0.997 | 0.2% | 0.3% |
| bm_libyaml_arena_reuse | 549.9 | 547.6 | 0.996 | 0.1% | 0.1% |
| bm_ryml_yaml_arena | 294.5 | 291.6 | 0.990 | 0.5% | 0.3% |
| bm_ryml_yaml_arena_nofilter | 96.6 | 95.8 | 0.992 | 0.6% | 0.9% |
| bm_ryml_yaml_arena_nofilter_reserve | 95.5 | 95.1 | 0.995 | 0.6% | 1.0% |
| bm_ryml_yaml_arena_reserve | 293.8 | 291.4 | 0.992 | 0.7% | 0.2% |
| bm_ryml_yaml_arena_reuse | 292.5 | 291.2 | 0.995 | 0.7% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter | 96.2 | 95.9 | 0.997 | 1.1% | 0.9% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 94.9 | 95.1 | 1.002 | 0.5% | 0.6% |
| bm_ryml_yaml_arena_reuse_reserve | 292.6 | 291.2 | 0.995 | 0.9% | 0.1% |
| bm_ryml_yaml_inplace | 293.0 | 290.2 | 0.990 | 0.3% | 0.5% |
| bm_ryml_yaml_inplace_nofilter | 94.8 | 94.2 | 0.993 | 0.6% | 1.4% |
| bm_ryml_yaml_inplace_nofilter_reserve | 93.9 | 93.4 | 0.995 | 0.7% | 1.3% |
| bm_ryml_yaml_inplace_reserve | 292.1 | 289.6 | 0.992 | 0.4% | 0.5% |
| bm_ryml_yaml_inplace_reuse | 290.9 | 289.2 | 0.994 | 0.7% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter | 93.2 | 93.5 | 1.002 | 1.4% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 93.2 | 93.3 | 1.001 | 1.1% | 0.9% |
| bm_ryml_yaml_inplace_reuse_reserve | 291.2 | 289.3 | 0.993 | 0.9% | 0.3% |
| bm_rymlints_yaml_inplace | 575.8 | 575.7 | 1.000 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace_nofilter | 184.0 | 184.2 | 1.001 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 94.6 | 94.9 | 1.004 | 0.9% | 0.8% |
| bm_rymlints_yaml_inplace_reserve | 292.5 | 292.2 | 0.999 | 0.7% | 0.7% |
| bm_rymlints_yaml_inplace_reuse | 287.6 | 288.2 | 1.002 | 0.6% | 0.3% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 92.0 | 92.2 | 1.002 | 0.2% | 0.3% |
| bm_yamlcpp_arena | 3,298.1 | 3,312.1 | 1.004 | 1.3% | 0.7% |

## scalar_dquot_singleline.yml (4,824 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 89.2 | 88.0 | 0.986 | 1.1% | 0.3% |
| bm_libyaml_arena | 68.3 | 67.5 | 0.987 | 0.3% | 0.2% |
| bm_libyaml_arena_reuse | 68.1 | 67.4 | 0.989 | 0.3% | 0.3% |
| bm_ryml_yaml_arena | 12.8 | 12.2 | 0.957 | 0.3% | 0.4% |
| bm_ryml_yaml_arena_nofilter | 12.8 | 12.3 | 0.961 | 0.7% | 0.3% |
| bm_ryml_yaml_arena_nofilter_reserve | 11.7 | 11.7 | 1.001 | 0.6% | 0.5% |
| bm_ryml_yaml_arena_reserve | 12.0 | 12.0 | 1.000 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_reuse | 11.7 | 11.7 | 1.002 | 0.7% | 0.9% |
| bm_ryml_yaml_arena_reuse_nofilter | 12.8 | 12.2 | 0.956 | 0.5% | 0.7% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 11.5 | 11.5 | 1.000 | 0.5% | 0.8% |
| bm_ryml_yaml_arena_reuse_reserve | 11.7 | 11.7 | 1.003 | 0.7% | 0.4% |
| bm_ryml_yaml_inplace | 12.9 | 12.4 | 0.967 | 0.5% | 0.4% |
| bm_ryml_yaml_inplace_nofilter | 12.5 | 12.1 | 0.966 | 0.5% | 0.6% |
| bm_ryml_yaml_inplace_nofilter_reserve | 11.5 | 11.5 | 0.999 | 0.7% | 0.7% |
| bm_ryml_yaml_inplace_reserve | 11.8 | 11.9 | 1.004 | 0.5% | 0.7% |
| bm_ryml_yaml_inplace_reuse | 11.6 | 11.6 | 0.999 | 0.6% | 0.5% |
| bm_ryml_yaml_inplace_reuse_nofilter | 11.4 | 11.5 | 1.001 | 0.6% | 0.8% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 11.4 | 11.5 | 1.003 | 0.3% | 0.7% |
| bm_ryml_yaml_inplace_reuse_reserve | 11.6 | 11.6 | 1.001 | 0.6% | 0.3% |
| bm_rymlints_yaml_inplace | 22.0 | 22.1 | 1.003 | 0.9% | 0.8% |
| bm_rymlints_yaml_inplace_nofilter | 21.7 | 21.6 | 0.997 | 0.6% | 0.7% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 11.1 | 11.0 | 0.999 | 0.4% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 11.2 | 11.2 | 0.999 | 0.9% | 0.5% |
| bm_rymlints_yaml_inplace_reuse | 11.2 | 11.2 | 1.001 | 1.6% | 0.5% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 11.0 | 11.0 | 1.001 | 0.4% | 0.8% |
| bm_yamlcpp_arena | 358.0 | 360.0 | 1.006 | 1.4% | 1.0% |

## scalar_squot_multiline.yml (72,273 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 372.2 | 369.0 | 0.991 | 0.6% | 0.9% |
| bm_libyaml_arena | 553.5 | 549.9 | 0.994 | 0.5% | 0.2% |
| bm_libyaml_arena_reuse | 552.3 | 548.7 | 0.993 | 0.6% | 1.0% |
| bm_ryml_yaml_arena | 242.7 | 243.0 | 1.002 | 1.8% | 2.7% |
| bm_ryml_yaml_arena_nofilter | 84.4 | 85.7 | 1.015 | 3.8% | 3.9% |
| bm_ryml_yaml_arena_nofilter_reserve | 83.2 | 85.1 | 1.023 | 4.2% | 7.4% |
| bm_ryml_yaml_arena_reserve | 241.8 | 242.4 | 1.002 | 1.5% | 1.7% |
| bm_ryml_yaml_arena_reuse | 242.8 | 242.6 | 0.999 | 1.4% | 1.8% |
| bm_ryml_yaml_arena_reuse_nofilter | 86.3 | 85.5 | 0.990 | 6.0% | 5.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 85.3 | 85.0 | 0.997 | 8.3% | 4.9% |
| bm_ryml_yaml_arena_reuse_reserve | 242.6 | 242.3 | 0.999 | 1.3% | 2.4% |
| bm_ryml_yaml_inplace | 241.0 | 241.5 | 1.002 | 1.9% | 2.2% |
| bm_ryml_yaml_inplace_nofilter | 84.2 | 83.8 | 0.996 | 7.9% | 4.5% |
| bm_ryml_yaml_inplace_nofilter_reserve | 83.1 | 83.2 | 1.001 | 8.0% | 5.2% |
| bm_ryml_yaml_inplace_reserve | 241.9 | 241.1 | 0.996 | 1.8% | 2.5% |
| bm_ryml_yaml_inplace_reuse | 242.8 | 240.9 | 0.992 | 1.9% | 1.7% |
| bm_ryml_yaml_inplace_reuse_nofilter | 85.5 | 85.2 | 0.996 | 8.6% | 5.9% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 83.8 | 85.4 | 1.018 | 6.5% | 10.4% |
| bm_ryml_yaml_inplace_reuse_reserve | 243.1 | 241.0 | 0.992 | 2.2% | 2.9% |
| bm_rymlints_yaml_inplace | 480.3 | 481.6 | 1.003 | 0.6% | 1.5% |
| bm_rymlints_yaml_inplace_nofilter | 166.3 | 167.2 | 1.005 | 5.2% | 6.0% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 86.3 | 86.5 | 1.001 | 1.7% | 4.8% |
| bm_rymlints_yaml_inplace_reserve | 243.3 | 241.9 | 0.994 | 2.0% | 1.9% |
| bm_rymlints_yaml_inplace_reuse | 237.8 | 238.9 | 1.005 | 1.8% | 1.2% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 82.2 | 83.0 | 1.010 | 4.5% | 1.8% |
| bm_yamlcpp_arena | 2,880.8 | 2,882.5 | 1.001 | 1.3% | 1.1% |

## scalar_squot_singleline.yml (4,820 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 89.5 | 88.6 | 0.989 | 0.3% | 0.4% |
| bm_libyaml_arena | 68.0 | 67.5 | 0.993 | 0.2% | 0.2% |
| bm_libyaml_arena_reuse | 67.9 | 67.3 | 0.991 | 0.4% | 0.1% |
| bm_ryml_yaml_arena | 12.6 | 12.1 | 0.956 | 0.6% | 1.3% |
| bm_ryml_yaml_arena_nofilter | 12.1 | 11.6 | 0.958 | 0.3% | 1.2% |
| bm_ryml_yaml_arena_nofilter_reserve | 11.0 | 11.0 | 0.996 | 0.4% | 0.2% |
| bm_ryml_yaml_arena_reserve | 11.9 | 11.8 | 0.994 | 0.7% | 1.1% |
| bm_ryml_yaml_arena_reuse | 11.6 | 11.5 | 0.991 | 0.5% | 1.3% |
| bm_ryml_yaml_arena_reuse_nofilter | 12.2 | 11.6 | 0.952 | 0.4% | 1.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 10.9 | 10.9 | 0.997 | 0.5% | 1.4% |
| bm_ryml_yaml_arena_reuse_reserve | 11.6 | 11.5 | 0.993 | 0.4% | 1.1% |
| bm_ryml_yaml_inplace | 12.7 | 12.3 | 0.965 | 0.3% | 0.6% |
| bm_ryml_yaml_inplace_nofilter | 11.9 | 11.5 | 0.963 | 0.3% | 0.9% |
| bm_ryml_yaml_inplace_nofilter_reserve | 10.9 | 10.9 | 0.999 | 0.5% | 2.5% |
| bm_ryml_yaml_inplace_reserve | 11.7 | 11.7 | 0.997 | 0.3% | 0.7% |
| bm_ryml_yaml_inplace_reuse | 11.5 | 11.4 | 0.993 | 0.7% | 1.0% |
| bm_ryml_yaml_inplace_reuse_nofilter | 10.8 | 10.9 | 1.002 | 0.8% | 0.7% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 10.8 | 10.8 | 0.998 | 0.3% | 0.5% |
| bm_ryml_yaml_inplace_reuse_reserve | 11.5 | 11.4 | 0.992 | 0.4% | 0.5% |
| bm_rymlints_yaml_inplace | 21.8 | 21.8 | 1.001 | 0.2% | 0.7% |
| bm_rymlints_yaml_inplace_nofilter | 20.6 | 20.6 | 1.002 | 0.7% | 0.6% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 10.4 | 10.4 | 1.001 | 0.3% | 0.9% |
| bm_rymlints_yaml_inplace_reserve | 11.1 | 11.1 | 0.996 | 0.1% | 0.8% |
| bm_rymlints_yaml_inplace_reuse | 11.0 | 11.1 | 1.007 | 0.5% | 0.8% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 10.4 | 10.4 | 0.999 | 0.4% | 0.7% |
| bm_yamlcpp_arena | 343.3 | 346.7 | 1.010 | 1.5% | 1.2% |

## scalar_plain_multiline.yml (72,041 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 338.3 | 336.6 | 0.995 | 0.6% | 0.1% |
| bm_libyaml_arena | 611.2 | 610.2 | 0.998 | 0.3% | 0.5% |
| bm_libyaml_arena_reuse | 610.3 | 608.4 | 0.997 | 0.4% | 0.5% |
| bm_ryml_yaml_arena | 349.4 | 349.3 | 1.000 | 0.3% | 0.2% |
| bm_ryml_yaml_arena_nofilter | 205.9 | 205.6 | 0.998 | 0.5% | 0.7% |
| bm_ryml_yaml_arena_nofilter_reserve | 204.7 | 204.7 | 1.000 | 0.5% | 0.6% |
| bm_ryml_yaml_arena_reserve | 348.1 | 348.6 | 1.001 | 0.2% | 0.2% |
| bm_ryml_yaml_arena_reuse | 347.8 | 348.9 | 1.003 | 0.1% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter | 205.8 | 205.6 | 0.999 | 0.2% | 0.5% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 204.6 | 204.8 | 1.001 | 0.3% | 0.6% |
| bm_ryml_yaml_arena_reuse_reserve | 348.0 | 348.7 | 1.002 | 0.1% | 0.4% |
| bm_ryml_yaml_inplace | 347.7 | 347.9 | 1.001 | 0.3% | 0.3% |
| bm_ryml_yaml_inplace_nofilter | 204.3 | 204.0 | 0.999 | 0.1% | 0.6% |
| bm_ryml_yaml_inplace_nofilter_reserve | 203.1 | 203.1 | 1.000 | 0.1% | 0.7% |
| bm_ryml_yaml_inplace_reserve | 346.6 | 347.1 | 1.001 | 0.2% | 0.2% |
| bm_ryml_yaml_inplace_reuse | 346.4 | 347.2 | 1.002 | 0.2% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 203.1 | 203.1 | 1.000 | 0.2% | 0.1% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 203.2 | 203.4 | 1.001 | 0.3% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 346.7 | 347.1 | 1.001 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace | 689.5 | 689.5 | 1.000 | 0.5% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter | 404.5 | 404.0 | 0.999 | 0.6% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 204.0 | 203.5 | 0.997 | 0.6% | 0.5% |
| bm_rymlints_yaml_inplace_reserve | 350.8 | 350.5 | 0.999 | 0.1% | 0.2% |
| bm_rymlints_yaml_inplace_reuse | 345.0 | 345.2 | 1.001 | 0.2% | 0.1% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 202.2 | 202.6 | 1.002 | 0.6% | 0.7% |
| bm_yamlcpp_arena | 4,836.8 | 4,862.7 | 1.005 | 0.8% | 1.1% |

## scalar_plain_singleline.yml (4,676 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 86.7 | 85.8 | 0.989 | 1.0% | 0.5% |
| bm_libyaml_arena | 70.8 | 70.7 | 0.998 | 0.2% | 0.3% |
| bm_libyaml_arena_reuse | 68.8 | 68.7 | 0.998 | 0.4% | 0.4% |
| bm_ryml_yaml_arena | 18.8 | 18.2 | 0.973 | 0.3% | 0.3% |
| bm_ryml_yaml_arena_nofilter | 18.8 | 18.3 | 0.975 | 0.4% | 0.2% |
| bm_ryml_yaml_arena_nofilter_reserve | 17.7 | 17.7 | 0.996 | 0.3% | 0.3% |
| bm_ryml_yaml_arena_reserve | 18.0 | 18.0 | 0.998 | 0.2% | 0.2% |
| bm_ryml_yaml_arena_reuse | 17.7 | 17.7 | 0.998 | 0.2% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter | 18.9 | 18.3 | 0.968 | 0.4% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 17.6 | 17.5 | 0.999 | 0.3% | 0.3% |
| bm_ryml_yaml_arena_reuse_reserve | 17.7 | 17.7 | 0.998 | 0.4% | 0.2% |
| bm_ryml_yaml_inplace | 18.9 | 18.5 | 0.978 | 0.2% | 0.2% |
| bm_ryml_yaml_inplace_nofilter | 18.6 | 18.2 | 0.979 | 0.2% | 0.4% |
| bm_ryml_yaml_inplace_nofilter_reserve | 17.6 | 17.5 | 0.998 | 0.3% | 0.3% |
| bm_ryml_yaml_inplace_reserve | 17.8 | 17.9 | 1.001 | 0.6% | 0.4% |
| bm_ryml_yaml_inplace_reuse | 17.6 | 17.6 | 1.000 | 0.5% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter | 17.5 | 17.5 | 1.000 | 0.4% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 17.5 | 17.5 | 0.999 | 0.4% | 0.2% |
| bm_ryml_yaml_inplace_reuse_reserve | 17.6 | 17.6 | 0.999 | 0.4% | 0.2% |
| bm_rymlints_yaml_inplace | 34.1 | 34.1 | 1.000 | 0.3% | 0.2% |
| bm_rymlints_yaml_inplace_nofilter | 33.9 | 33.9 | 1.000 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 17.1 | 17.1 | 1.000 | 0.5% | 0.3% |
| bm_rymlints_yaml_inplace_reserve | 17.3 | 17.3 | 1.000 | 0.3% | 0.2% |
| bm_rymlints_yaml_inplace_reuse | 17.2 | 17.2 | 1.000 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 17.1 | 17.0 | 0.997 | 0.3% | 0.3% |
| bm_yamlcpp_arena | 464.9 | 464.6 | 1.000 | 0.8% | 1.0% |

## scalar_block_literal_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 358.8 | 358.1 | 0.998 | 0.1% | 0.1% |
| bm_libyaml_arena | 501.6 | 501.9 | 1.001 | 0.3% | 0.4% |
| bm_libyaml_arena_reuse | 501.0 | 501.0 | 1.000 | 0.2% | 0.4% |
| bm_ryml_yaml_arena | 118.0 | 115.1 | 0.976 | 1.2% | 0.5% |
| bm_ryml_yaml_arena_nofilter | 55.9 | 55.5 | 0.992 | 0.6% | 0.5% |
| bm_ryml_yaml_arena_nofilter_reserve | 54.9 | 54.8 | 0.999 | 1.2% | 0.4% |
| bm_ryml_yaml_arena_reserve | 117.3 | 114.9 | 0.979 | 3.8% | 0.6% |
| bm_ryml_yaml_arena_reuse | 118.1 | 115.9 | 0.981 | 3.7% | 0.8% |
| bm_ryml_yaml_arena_reuse_nofilter | 56.2 | 55.4 | 0.987 | 0.5% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 54.8 | 54.6 | 0.998 | 0.6% | 0.4% |
| bm_ryml_yaml_arena_reuse_reserve | 118.4 | 115.9 | 0.979 | 3.9% | 0.7% |
| bm_ryml_yaml_inplace | 115.5 | 113.7 | 0.984 | 2.1% | 0.7% |
| bm_ryml_yaml_inplace_nofilter | 54.3 | 53.8 | 0.991 | 0.5% | 0.5% |
| bm_ryml_yaml_inplace_nofilter_reserve | 53.2 | 53.2 | 0.999 | 0.3% | 0.6% |
| bm_ryml_yaml_inplace_reserve | 114.6 | 113.0 | 0.986 | 1.8% | 0.6% |
| bm_ryml_yaml_inplace_reuse | 120.9 | 114.1 | 0.944 | 4.2% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter | 53.3 | 53.2 | 0.996 | 0.9% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 53.4 | 53.3 | 0.997 | 0.8% | 0.4% |
| bm_ryml_yaml_inplace_reuse_reserve | 120.2 | 113.9 | 0.948 | 4.1% | 0.4% |
| bm_rymlints_yaml_inplace | 222.1 | 222.8 | 1.003 | 0.7% | 0.8% |
| bm_rymlints_yaml_inplace_nofilter | 103.2 | 103.5 | 1.002 | 0.5% | 0.7% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 53.3 | 53.6 | 1.005 | 1.2% | 0.7% |
| bm_rymlints_yaml_inplace_reserve | 115.2 | 115.5 | 1.003 | 1.4% | 0.7% |
| bm_rymlints_yaml_inplace_reuse | 111.0 | 111.0 | 1.000 | 0.3% | 0.3% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 52.3 | 51.9 | 0.993 | 0.5% | 0.3% |
| bm_yamlcpp_arena | 2,716.3 | 2,722.5 | 1.002 | 1.7% | 1.9% |

## scalar_block_literal_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 91.0 | 90.1 | 0.990 | 0.2% | 0.2% |
| bm_libyaml_arena | 65.2 | 64.9 | 0.995 | 0.2% | 0.2% |
| bm_libyaml_arena_reuse | 65.2 | 64.8 | 0.995 | 0.2% | 1.9% |
| bm_ryml_yaml_arena | 18.7 | 18.1 | 0.969 | 1.5% | 0.7% |
| bm_ryml_yaml_arena_nofilter | 14.2 | 13.6 | 0.957 | 1.7% | 0.3% |
| bm_ryml_yaml_arena_nofilter_reserve | 13.0 | 12.9 | 0.990 | 0.8% | 0.5% |
| bm_ryml_yaml_arena_reserve | 17.9 | 17.8 | 0.993 | 0.8% | 0.6% |
| bm_ryml_yaml_arena_reuse | 17.9 | 17.8 | 0.995 | 1.2% | 0.6% |
| bm_ryml_yaml_arena_reuse_nofilter | 14.3 | 13.6 | 0.951 | 1.0% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 12.9 | 12.8 | 0.992 | 1.4% | 0.7% |
| bm_ryml_yaml_arena_reuse_reserve | 18.0 | 17.8 | 0.990 | 1.2% | 0.7% |
| bm_ryml_yaml_inplace | 18.7 | 18.3 | 0.974 | 0.6% | 1.5% |
| bm_ryml_yaml_inplace_nofilter | 13.9 | 13.4 | 0.964 | 0.5% | 1.1% |
| bm_ryml_yaml_inplace_nofilter_reserve | 12.8 | 12.8 | 0.995 | 0.9% | 0.6% |
| bm_ryml_yaml_inplace_reserve | 17.7 | 17.6 | 0.995 | 1.9% | 0.8% |
| bm_ryml_yaml_inplace_reuse | 17.9 | 17.7 | 0.991 | 1.4% | 1.0% |
| bm_ryml_yaml_inplace_reuse_nofilter | 12.8 | 12.7 | 0.994 | 0.7% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 12.8 | 12.7 | 0.996 | 0.8% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 17.9 | 17.7 | 0.991 | 1.9% | 1.8% |
| bm_rymlints_yaml_inplace | 33.6 | 33.6 | 1.001 | 1.4% | 1.4% |
| bm_rymlints_yaml_inplace_nofilter | 24.3 | 24.3 | 1.000 | 0.3% | 3.5% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 12.4 | 12.4 | 0.999 | 0.7% | 0.8% |
| bm_rymlints_yaml_inplace_reserve | 17.4 | 17.4 | 1.000 | 1.2% | 0.8% |
| bm_rymlints_yaml_inplace_reuse | 17.1 | 17.1 | 1.000 | 0.8% | 0.7% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 12.4 | 12.3 | 0.993 | 0.9% | 0.8% |
| bm_yamlcpp_arena | 344.0 | 342.6 | 0.996 | 0.6% | 1.3% |

## scalar_block_folded_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 359.5 | 358.6 | 0.998 | 0.4% | 0.3% |
| bm_libyaml_arena | 499.0 | 498.6 | 0.999 | 0.2% | 0.3% |
| bm_libyaml_arena_reuse | 497.7 | 497.4 | 0.999 | 0.2% | 0.3% |
| bm_ryml_yaml_arena | 188.9 | 188.8 | 0.999 | 0.6% | 0.1% |
| bm_ryml_yaml_arena_nofilter | 56.0 | 55.4 | 0.990 | 0.7% | 0.3% |
| bm_ryml_yaml_arena_nofilter_reserve | 54.9 | 54.7 | 0.997 | 0.8% | 0.3% |
| bm_ryml_yaml_arena_reserve | 188.4 | 188.5 | 1.001 | 0.3% | 0.2% |
| bm_ryml_yaml_arena_reuse | 189.3 | 189.4 | 1.000 | 0.1% | 0.1% |
| bm_ryml_yaml_arena_reuse_nofilter | 55.9 | 55.4 | 0.990 | 1.0% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 54.8 | 54.6 | 0.996 | 2.2% | 0.4% |
| bm_ryml_yaml_arena_reuse_reserve | 189.6 | 189.6 | 1.000 | 0.1% | 0.1% |
| bm_ryml_yaml_inplace | 187.2 | 186.9 | 0.999 | 0.3% | 0.1% |
| bm_ryml_yaml_inplace_nofilter | 54.3 | 53.9 | 0.992 | 0.5% | 0.3% |
| bm_ryml_yaml_inplace_nofilter_reserve | 53.4 | 53.1 | 0.995 | 0.6% | 0.4% |
| bm_ryml_yaml_inplace_reserve | 186.1 | 186.3 | 1.001 | 0.2% | 0.1% |
| bm_ryml_yaml_inplace_reuse | 187.6 | 187.6 | 1.000 | 0.1% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter | 53.4 | 53.1 | 0.995 | 0.3% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 53.6 | 53.2 | 0.993 | 0.3% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 188.0 | 188.0 | 1.000 | 0.1% | 0.1% |
| bm_rymlints_yaml_inplace | 370.1 | 369.9 | 0.999 | 1.1% | 0.1% |
| bm_rymlints_yaml_inplace_nofilter | 103.4 | 103.3 | 1.000 | 0.4% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 53.4 | 53.4 | 1.001 | 1.2% | 3.1% |
| bm_rymlints_yaml_inplace_reserve | 187.7 | 187.6 | 1.000 | 0.2% | 0.5% |
| bm_rymlints_yaml_inplace_reuse | 184.9 | 185.0 | 1.000 | 0.1% | 0.2% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 52.3 | 51.9 | 0.992 | 0.2% | 0.2% |
| bm_yamlcpp_arena | 2,703.6 | 2,716.8 | 1.005 | 0.8% | 1.9% |

## scalar_block_folded_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 91.0 | 90.0 | 0.988 | 0.4% | 0.2% |
| bm_libyaml_arena | 65.3 | 64.9 | 0.994 | 0.3% | 0.3% |
| bm_libyaml_arena_reuse | 65.1 | 64.8 | 0.996 | 0.4% | 0.1% |
| bm_ryml_yaml_arena | 22.5 | 21.9 | 0.973 | 0.3% | 0.4% |
| bm_ryml_yaml_arena_nofilter | 14.3 | 13.6 | 0.954 | 1.0% | 0.7% |
| bm_ryml_yaml_arena_nofilter_reserve | 13.1 | 12.9 | 0.988 | 1.2% | 0.5% |
| bm_ryml_yaml_arena_reserve | 21.8 | 21.7 | 0.995 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_reuse | 21.8 | 21.7 | 0.992 | 0.7% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter | 14.3 | 13.6 | 0.948 | 0.5% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 13.0 | 12.8 | 0.986 | 1.0% | 0.2% |
| bm_ryml_yaml_arena_reuse_reserve | 21.8 | 21.7 | 0.994 | 0.7% | 0.1% |
| bm_ryml_yaml_inplace | 22.6 | 22.2 | 0.980 | 0.4% | 0.4% |
| bm_ryml_yaml_inplace_nofilter | 14.0 | 13.4 | 0.957 | 1.1% | 0.3% |
| bm_ryml_yaml_inplace_nofilter_reserve | 12.9 | 12.8 | 0.993 | 1.0% | 0.3% |
| bm_ryml_yaml_inplace_reserve | 21.5 | 21.5 | 1.000 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace_reuse | 21.7 | 21.6 | 0.994 | 0.6% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 12.8 | 12.7 | 0.994 | 0.5% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 12.8 | 12.8 | 0.994 | 0.6% | 0.2% |
| bm_ryml_yaml_inplace_reuse_reserve | 21.7 | 21.6 | 0.995 | 0.5% | 0.4% |
| bm_rymlints_yaml_inplace | 41.3 | 41.4 | 1.003 | 0.6% | 0.8% |
| bm_rymlints_yaml_inplace_nofilter | 24.3 | 24.2 | 0.997 | 1.3% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 12.4 | 12.4 | 0.999 | 1.1% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 21.1 | 21.1 | 1.000 | 0.4% | 0.3% |
| bm_rymlints_yaml_inplace_reuse | 20.9 | 20.8 | 0.995 | 1.3% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 12.3 | 12.2 | 0.990 | 1.9% | 0.3% |
| bm_yamlcpp_arena | 345.2 | 343.6 | 0.995 | 0.9% | 1.0% |

## medium.yaml (22,421,093 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 5,699.3 | 5,681.1 | 0.997 | 0.1% | 0.2% |
| bm_libyaml_arena | 418,246 | 389,738 | 0.932 | 1.7% | 1.1% |
| bm_libyaml_arena_reuse | 350,043 | 331,836 | 0.948 | 0.3% | 0.1% |
| bm_ryml_yaml_arena | 219,684 | 138,707 | 0.631 | 2.9% | 1.6% |
| bm_ryml_yaml_arena_nofilter | 210,988 | 129,391 | 0.613 | 2.5% | 1.6% |
| bm_ryml_yaml_arena_nofilter_reserve | 110,687 | 111,587 | 1.008 | 1.1% | 1.6% |
| bm_ryml_yaml_arena_reserve | 120,156 | 121,366 | 1.010 | 0.8% | 1.7% |
| bm_ryml_yaml_arena_reuse | 114,005 | 113,834 | 0.998 | 0.4% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter | 210,522 | 129,442 | 0.615 | 2.9% | 1.8% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 104,894 | 104,801 | 0.999 | 0.3% | 0.5% |
| bm_ryml_yaml_arena_reuse_reserve | 114,051 | 113,950 | 0.999 | 0.3% | 0.4% |
| bm_ryml_yaml_inplace | 204,560 | 137,887 | 0.674 | 2.3% | 1.1% |
| bm_ryml_yaml_inplace_nofilter | 194,408 | 127,954 | 0.658 | 2.9% | 1.8% |
| bm_ryml_yaml_inplace_nofilter_reserve | 109,525 | 110,542 | 1.009 | 0.9% | 2.1% |
| bm_ryml_yaml_inplace_reserve | 119,434 | 120,161 | 1.006 | 1.0% | 1.4% |
| bm_ryml_yaml_inplace_reuse | 113,197 | 112,903 | 0.997 | 0.2% | 0.5% |
| bm_ryml_yaml_inplace_reuse_nofilter | 104,051 | 103,686 | 0.996 | 0.2% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 103,941 | 103,736 | 0.998 | 0.4% | 0.4% |
| bm_ryml_yaml_inplace_reuse_reserve | 113,415 | 113,038 | 0.997 | 0.1% | 0.3% |
| bm_rymlints_yaml_inplace | 212,371 | 212,367 | 1.000 | 0.2% | 0.2% |
| bm_rymlints_yaml_inplace_nofilter | 194,420 | 194,172 | 0.999 | 0.4% | 0.6% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 102,925 | 102,584 | 0.997 | 0.4% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 112,042 | 112,218 | 1.002 | 0.7% | 0.8% |
| bm_rymlints_yaml_inplace_reuse | 108,239 | 108,113 | 0.999 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 99,141 | 98,853 | 0.997 | 0.3% | 0.3% |
| bm_yamlcpp_arena | 2,426.6 | 2,455.1 | 1.012 | 13.4% | 13.3% |

## big_scalar_block_literal_multiline.yml (1,088,715 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 4,874.3 | 4,859.4 | 0.997 | 0.1% | 0.1% |
| bm_libyaml_arena | 7,550.5 | 7,750.6 | 1.026 | 0.3% | 0.2% |
| bm_libyaml_arena_reuse | 7,547.5 | 7,732.7 | 1.025 | 0.3% | 0.1% |
| bm_ryml_yaml_arena | 1,806.6 | 1,750.1 | 0.969 | 4.4% | 0.8% |
| bm_ryml_yaml_arena_nofilter | 839.8 | 850.4 | 1.013 | 0.7% | 0.7% |
| bm_ryml_yaml_arena_nofilter_reserve | 824.2 | 821.2 | 0.996 | 0.9% | 0.9% |
| bm_ryml_yaml_arena_reserve | 1,748.9 | 1,722.0 | 0.985 | 5.5% | 0.6% |
| bm_ryml_yaml_arena_reuse | 1,795.6 | 1,718.5 | 0.957 | 4.1% | 1.0% |
| bm_ryml_yaml_arena_reuse_nofilter | 846.9 | 850.4 | 1.004 | 1.0% | 0.9% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 826.7 | 819.9 | 0.992 | 1.1% | 0.8% |
| bm_ryml_yaml_arena_reuse_reserve | 1,775.1 | 1,719.8 | 0.969 | 4.4% | 1.1% |
| bm_ryml_yaml_inplace | 1,781.5 | 1,721.6 | 0.966 | 4.7% | 0.4% |
| bm_ryml_yaml_inplace_nofilter | 808.5 | 822.6 | 1.017 | 0.6% | 0.4% |
| bm_ryml_yaml_inplace_nofilter_reserve | 789.4 | 792.9 | 1.004 | 0.8% | 0.4% |
| bm_ryml_yaml_inplace_reserve | 1,798.2 | 1,691.7 | 0.941 | 5.0% | 0.5% |
| bm_ryml_yaml_inplace_reuse | 1,765.3 | 1,689.3 | 0.957 | 2.6% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 793.3 | 792.4 | 0.999 | 0.7% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 794.6 | 793.1 | 0.998 | 0.7% | 0.4% |
| bm_ryml_yaml_inplace_reuse_reserve | 1,782.0 | 1,688.9 | 0.948 | 3.8% | 0.6% |
| bm_rymlints_yaml_inplace | 3,358.1 | 3,351.5 | 0.998 | 1.0% | 1.0% |
| bm_rymlints_yaml_inplace_nofilter | 1,547.6 | 1,550.6 | 1.002 | 1.0% | 0.1% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 810.3 | 809.7 | 0.999 | 0.4% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 1,716.0 | 1,713.5 | 0.999 | 0.4% | 0.3% |
| bm_rymlints_yaml_inplace_reuse | 1,679.5 | 1,674.5 | 0.997 | 0.7% | 0.5% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 781.6 | 781.2 | 0.999 | 0.3% | 0.7% |
| bm_yamlcpp_arena | 2,809.8 | 2,803.3 | 0.998 | 0.5% | 0.3% |

## big_scalar_dquot_multiline.yml (1,082,775 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 5,021.8 | 5,020.1 | 1.000 | 0.5% | 0.5% |
| bm_libyaml_arena | 8,285.8 | 8,024.4 | 0.968 | 0.2% | 0.1% |
| bm_libyaml_arena_reuse | 8,274.5 | 8,003.1 | 0.967 | 0.2% | 0.2% |
| bm_ryml_yaml_arena | 4,445.1 | 4,406.7 | 0.991 | 1.1% | 0.4% |
| bm_ryml_yaml_arena_nofilter | 1,453.5 | 1,456.4 | 1.002 | 0.8% | 1.1% |
| bm_ryml_yaml_arena_nofilter_reserve | 1,438.3 | 1,427.4 | 0.992 | 0.8% | 0.7% |
| bm_ryml_yaml_arena_reserve | 4,418.7 | 4,378.7 | 0.991 | 0.9% | 0.3% |
| bm_ryml_yaml_arena_reuse | 4,405.4 | 4,373.7 | 0.993 | 1.3% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter | 1,452.3 | 1,456.2 | 1.003 | 1.0% | 0.6% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 1,435.8 | 1,426.8 | 0.994 | 0.9% | 0.9% |
| bm_ryml_yaml_arena_reuse_reserve | 4,404.7 | 4,373.4 | 0.993 | 1.1% | 0.3% |
| bm_ryml_yaml_inplace | 4,395.7 | 4,376.0 | 0.996 | 0.8% | 0.2% |
| bm_ryml_yaml_inplace_nofilter | 1,419.0 | 1,426.7 | 1.005 | 0.6% | 0.6% |
| bm_ryml_yaml_inplace_nofilter_reserve | 1,401.7 | 1,398.3 | 0.998 | 0.6% | 0.6% |
| bm_ryml_yaml_inplace_reserve | 4,374.1 | 4,348.5 | 0.994 | 1.2% | 0.1% |
| bm_ryml_yaml_inplace_reuse | 4,351.6 | 4,342.4 | 0.998 | 0.8% | 0.5% |
| bm_ryml_yaml_inplace_reuse_nofilter | 1,398.1 | 1,395.1 | 0.998 | 0.7% | 1.0% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 1,397.4 | 1,394.1 | 0.998 | 0.7% | 1.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 4,360.3 | 4,343.6 | 0.996 | 0.8% | 0.5% |
| bm_rymlints_yaml_inplace | 8,646.2 | 8,653.4 | 1.001 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter | 2,766.0 | 2,758.6 | 0.997 | 1.1% | 0.4% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 1,410.8 | 1,409.2 | 0.999 | 0.3% | 0.1% |
| bm_rymlints_yaml_inplace_reserve | 4,351.2 | 4,349.2 | 1.000 | 0.1% | 0.2% |
| bm_rymlints_yaml_inplace_reuse | 4,324.3 | 4,323.3 | 1.000 | 0.3% | 0.2% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 1,381.8 | 1,379.5 | 0.998 | 0.3% | 0.5% |
| bm_yamlcpp_arena | 3,408.5 | 3,405.6 | 0.999 | 0.5% | 0.3% |

## big_scalar_plain_multiline.yml (1,080,675 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 4,530.3 | 4,534.8 | 1.001 | 0.6% | 0.3% |
| bm_libyaml_arena | 9,188.7 | 9,095.1 | 0.990 | 0.2% | 0.4% |
| bm_libyaml_arena_reuse | 9,180.4 | 9,067.4 | 0.988 | 0.2% | 0.2% |
| bm_ryml_yaml_arena | 5,252.8 | 5,255.2 | 1.000 | 0.3% | 0.3% |
| bm_ryml_yaml_arena_nofilter | 3,093.3 | 3,106.6 | 1.004 | 0.4% | 0.3% |
| bm_ryml_yaml_arena_nofilter_reserve | 3,075.9 | 3,075.1 | 1.000 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_reserve | 5,233.0 | 5,227.0 | 0.999 | 0.2% | 0.3% |
| bm_ryml_yaml_arena_reuse | 5,233.1 | 5,226.9 | 0.999 | 0.2% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter | 3,100.8 | 3,108.7 | 1.003 | 0.5% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 3,082.5 | 3,074.3 | 0.997 | 0.5% | 0.4% |
| bm_ryml_yaml_arena_reuse_reserve | 5,230.4 | 5,223.8 | 0.999 | 0.2% | 0.2% |
| bm_ryml_yaml_inplace | 5,217.4 | 5,222.2 | 1.001 | 0.1% | 0.1% |
| bm_ryml_yaml_inplace_nofilter | 3,061.0 | 3,074.9 | 1.005 | 0.2% | 0.2% |
| bm_ryml_yaml_inplace_nofilter_reserve | 3,043.2 | 3,044.7 | 1.000 | 0.3% | 0.1% |
| bm_ryml_yaml_inplace_reserve | 5,196.1 | 5,190.5 | 0.999 | 0.1% | 0.2% |
| bm_ryml_yaml_inplace_reuse | 5,192.6 | 5,193.3 | 1.000 | 0.1% | 0.1% |
| bm_ryml_yaml_inplace_reuse_nofilter | 3,045.8 | 3,044.3 | 1.000 | 0.3% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 3,044.2 | 3,043.4 | 1.000 | 0.3% | 0.1% |
| bm_ryml_yaml_inplace_reuse_reserve | 5,196.8 | 5,191.8 | 0.999 | 0.2% | 0.1% |
| bm_rymlints_yaml_inplace | 10,373 | 10,356 | 0.998 | 0.2% | 0.4% |
| bm_rymlints_yaml_inplace_nofilter | 6,069.5 | 6,059.8 | 0.998 | 0.7% | 0.7% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 3,058.5 | 3,053.6 | 0.998 | 0.5% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 5,248.5 | 5,242.2 | 0.999 | 0.4% | 0.2% |
| bm_rymlints_yaml_inplace_reuse | 5,190.9 | 5,191.3 | 1.000 | 0.5% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 3,030.7 | 3,033.9 | 1.001 | 0.8% | 0.7% |
| bm_yamlcpp_arena | 4,952.3 | 4,960.0 | 1.002 | 0.3% | 1.5% |

