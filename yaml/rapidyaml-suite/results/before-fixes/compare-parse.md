# bm_parse: master against branch, every case and row

Times are the median CPU time of 5 repetitions, in microseconds. Ratio is branch / master: below 1 is faster. Spread is (slowest - fastest) / median over the 5 repetitions. Source: `compare.csv`.

## appveyor.yml (2,129 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 56.7 | 56.1 | 0.990 | 1.4% | 0.6% |
| bm_libyaml_arena | 35.4 | 35.4 | 1.002 | 0.2% | 0.4% |
| bm_libyaml_arena_reuse | 34.8 | 34.9 | 1.002 | 0.1% | 0.5% |
| bm_ryml_yaml_arena | 11.1 | 10.7 | 0.965 | 0.3% | 0.4% |
| bm_ryml_yaml_arena_nofilter | 10.9 | 10.5 | 0.964 | 0.5% | 0.6% |
| bm_ryml_yaml_arena_nofilter_reserve | 9.9 | 10.0 | 1.007 | 0.5% | 0.4% |
| bm_ryml_yaml_arena_reserve | 10.5 | 10.5 | 1.003 | 0.5% | 0.5% |
| bm_ryml_yaml_arena_reuse | 10.1 | 10.2 | 1.004 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter | 10.9 | 10.5 | 0.964 | 0.5% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 9.8 | 9.9 | 1.007 | 0.7% | 0.4% |
| bm_ryml_yaml_arena_reuse_reserve | 10.1 | 10.2 | 1.005 | 0.5% | 0.5% |
| bm_ryml_yaml_inplace | 11.3 | 11.0 | 0.969 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace_nofilter | 10.8 | 10.4 | 0.965 | 0.8% | 0.7% |
| bm_ryml_yaml_inplace_nofilter_reserve | 9.8 | 9.9 | 1.007 | 0.7% | 0.8% |
| bm_ryml_yaml_inplace_reserve | 10.4 | 10.4 | 1.006 | 0.4% | 0.7% |
| bm_ryml_yaml_inplace_reuse | 10.1 | 10.1 | 1.004 | 0.3% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 9.8 | 9.9 | 1.010 | 0.6% | 0.7% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 9.8 | 9.9 | 1.009 | 0.5% | 0.8% |
| bm_ryml_yaml_inplace_reuse_reserve | 10.1 | 10.2 | 1.007 | 0.5% | 0.6% |
| bm_rymlints_yaml_inplace | 18.8 | 18.8 | 1.002 | 0.3% | 1.3% |
| bm_rymlints_yaml_inplace_nofilter | 18.1 | 18.2 | 1.002 | 0.4% | 0.9% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 9.2 | 9.3 | 1.007 | 0.6% | 1.0% |
| bm_rymlints_yaml_inplace_reserve | 9.6 | 9.6 | 1.003 | 0.7% | 0.8% |
| bm_rymlints_yaml_inplace_reuse | 9.4 | 9.5 | 1.008 | 0.9% | 0.8% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 9.1 | 9.1 | 1.008 | 0.5% | 1.2% |
| bm_yamlcpp_arena | 216.4 | 217.8 | 1.006 | 1.1% | 0.6% |

## compile_commands.json (46,826 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_jsoncpp_arena | 187.4 | 195.6 | 1.044 | 1.0% | 0.2% |
| bm_libfyaml_arena | 331.6 | 328.9 | 0.992 | 0.2% | 0.7% |
| bm_libyaml_arena | 441.2 | 422.9 | 0.958 | 0.1% | 0.2% |
| bm_libyaml_arena_reuse | 447.0 | 418.3 | 0.936 | 2.3% | 2.4% |
| bm_nlohmann_arena | 363.2 | 404.4 | 1.113 | 0.1% | 0.3% |
| bm_rapidjson_arena | 95.6 | 94.5 | 0.989 | 0.3% | 0.2% |
| bm_rapidjson_inplace | 35.3 | 35.5 | 1.005 | 0.2% | 0.2% |
| bm_ryml_json_arena | 71.3 | 69.9 | 0.980 | 0.3% | 1.2% |
| bm_ryml_json_arena_nofilter | 71.3 | 69.1 | 0.969 | 0.6% | 0.7% |
| bm_ryml_json_arena_nofilter_reserve | 67.7 | 66.7 | 0.986 | 0.6% | 1.5% |
| bm_ryml_json_arena_reserve | 68.9 | 67.1 | 0.974 | 1.0% | 1.2% |
| bm_ryml_json_arena_reuse | 67.6 | 66.2 | 0.979 | 0.9% | 1.5% |
| bm_ryml_json_arena_reuse_nofilter | 67.6 | 65.9 | 0.975 | 0.4% | 1.6% |
| bm_ryml_json_arena_reuse_nofilter_reserve | 67.5 | 66.5 | 0.985 | 0.5% | 1.3% |
| bm_ryml_json_arena_reuse_reserve | 67.5 | 66.7 | 0.987 | 1.0% | 1.5% |
| bm_ryml_json_inplace | 70.6 | 69.0 | 0.977 | 0.6% | 0.7% |
| bm_ryml_json_inplace_nofilter | 70.2 | 68.0 | 0.968 | 0.7% | 0.7% |
| bm_ryml_json_inplace_nofilter_reserve | 66.5 | 65.5 | 0.985 | 0.5% | 1.3% |
| bm_ryml_json_inplace_reserve | 67.8 | 66.2 | 0.977 | 0.7% | 1.5% |
| bm_ryml_json_inplace_reuse | 66.4 | 65.6 | 0.988 | 0.7% | 1.5% |
| bm_ryml_json_inplace_reuse_nofilter | 66.5 | 65.2 | 0.981 | 0.8% | 1.4% |
| bm_ryml_json_inplace_reuse_nofilter_reserve | 66.4 | 65.3 | 0.983 | 0.9% | 0.6% |
| bm_ryml_json_inplace_reuse_reserve | 66.4 | 65.3 | 0.983 | 1.2% | 1.3% |
| bm_ryml_yaml_arena | 74.8 | 73.6 | 0.984 | 1.1% | 0.9% |
| bm_ryml_yaml_arena_nofilter | 74.7 | 72.9 | 0.976 | 1.4% | 1.2% |
| bm_ryml_yaml_arena_nofilter_reserve | 70.4 | 70.4 | 1.000 | 1.3% | 1.0% |
| bm_ryml_yaml_arena_reserve | 71.5 | 71.0 | 0.993 | 1.5% | 1.2% |
| bm_ryml_yaml_arena_reuse | 70.5 | 70.5 | 1.001 | 1.2% | 1.3% |
| bm_ryml_yaml_arena_reuse_nofilter | 74.6 | 72.7 | 0.974 | 1.3% | 0.5% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 70.5 | 70.2 | 0.997 | 1.2% | 0.8% |
| bm_ryml_yaml_arena_reuse_reserve | 70.2 | 70.4 | 1.003 | 0.9% | 1.1% |
| bm_ryml_yaml_inplace | 74.9 | 72.4 | 0.967 | 1.3% | 0.9% |
| bm_ryml_yaml_inplace_nofilter | 73.7 | 71.7 | 0.973 | 1.3% | 0.8% |
| bm_ryml_yaml_inplace_nofilter_reserve | 69.3 | 69.3 | 1.000 | 0.9% | 1.2% |
| bm_ryml_yaml_inplace_reserve | 70.6 | 70.0 | 0.991 | 1.3% | 1.3% |
| bm_ryml_yaml_inplace_reuse | 69.3 | 69.4 | 1.002 | 1.2% | 1.2% |
| bm_ryml_yaml_inplace_reuse_nofilter | 69.2 | 69.3 | 1.001 | 1.0% | 1.2% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 69.1 | 69.2 | 1.002 | 1.3% | 0.9% |
| bm_ryml_yaml_inplace_reuse_reserve | 69.1 | 69.4 | 1.004 | 1.0% | 1.2% |
| bm_rymlints_estimate | 61.9 | 61.8 | 0.999 | 0.3% | 0.6% |
| bm_rymlints_json_inplace | 125.4 | 125.2 | 0.998 | 1.3% | 1.6% |
| bm_rymlints_json_inplace_nofilter | 125.2 | 125.6 | 1.003 | 0.7% | 1.4% |
| bm_rymlints_json_inplace_nofilter_reserve | 64.0 | 64.3 | 1.004 | 0.8% | 0.4% |
| bm_rymlints_json_inplace_reserve | 64.0 | 64.5 | 1.007 | 0.3% | 0.8% |
| bm_rymlints_json_inplace_reuse | 64.2 | 64.0 | 0.998 | 0.6% | 0.5% |
| bm_rymlints_json_inplace_reuse_nofilter | 64.0 | 64.0 | 1.001 | 1.0% | 0.6% |
| bm_rymlints_yaml_inplace | 133.1 | 132.7 | 0.998 | 0.4% | 1.0% |
| bm_rymlints_yaml_inplace_nofilter | 132.9 | 132.5 | 0.997 | 0.9% | 0.6% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 67.4 | 67.3 | 0.999 | 0.1% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 67.5 | 67.5 | 1.001 | 0.3% | 0.3% |
| bm_rymlints_yaml_inplace_reuse | 67.3 | 67.1 | 0.997 | 0.4% | 0.7% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 67.0 | 66.8 | 0.997 | 0.3% | 0.7% |
| bm_sajson_arena | 105.2 | 105.3 | 1.000 | 0.1% | 0.2% |
| bm_sajson_inplace | 104.5 | 104.5 | 1.000 | 0.2% | 0.1% |
| bm_yamlcpp_arena | 2,443.1 | 2,434.4 | 0.996 | 1.1% | 0.9% |

## travis.yml (4,067 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 80.9 | 80.2 | 0.991 | 0.8% | 1.2% |
| bm_libyaml_arena | 57.2 | 57.8 | 1.010 | 0.2% | 0.5% |
| bm_libyaml_arena_reuse | 56.3 | 57.4 | 1.019 | 1.3% | 1.4% |
| bm_ryml_yaml_arena | 18.4 | 18.0 | 0.977 | 0.3% | 0.3% |
| bm_ryml_yaml_arena_nofilter | 17.2 | 16.8 | 0.976 | 0.5% | 0.3% |
| bm_ryml_yaml_arena_nofilter_reserve | 16.1 | 16.1 | 1.000 | 0.6% | 0.5% |
| bm_ryml_yaml_arena_reserve | 17.7 | 17.7 | 1.000 | 0.4% | 0.1% |
| bm_ryml_yaml_arena_reuse | 17.2 | 17.2 | 1.004 | 0.9% | 0.6% |
| bm_ryml_yaml_arena_reuse_nofilter | 17.2 | 16.8 | 0.975 | 0.5% | 0.7% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 15.9 | 16.0 | 1.005 | 0.5% | 0.9% |
| bm_ryml_yaml_arena_reuse_reserve | 17.2 | 17.3 | 1.006 | 0.2% | 0.6% |
| bm_ryml_yaml_inplace | 18.6 | 18.2 | 0.981 | 0.4% | 0.7% |
| bm_ryml_yaml_inplace_nofilter | 17.0 | 16.6 | 0.979 | 0.6% | 0.4% |
| bm_ryml_yaml_inplace_nofilter_reserve | 15.9 | 16.0 | 1.003 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace_reserve | 17.5 | 17.6 | 1.004 | 0.2% | 0.7% |
| bm_ryml_yaml_inplace_reuse | 17.1 | 17.2 | 1.006 | 0.8% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 15.9 | 15.9 | 1.002 | 0.9% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 15.9 | 15.9 | 1.003 | 0.4% | 0.5% |
| bm_ryml_yaml_inplace_reuse_reserve | 17.1 | 17.2 | 1.005 | 0.3% | 0.5% |
| bm_rymlints_yaml_inplace | 32.8 | 32.9 | 1.002 | 0.5% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter | 30.3 | 30.3 | 1.001 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 15.4 | 15.4 | 1.000 | 0.2% | 0.2% |
| bm_rymlints_yaml_inplace_reserve | 16.7 | 16.7 | 1.001 | 0.3% | 0.1% |
| bm_rymlints_yaml_inplace_reuse | 16.5 | 16.5 | 1.001 | 0.4% | 0.3% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 15.2 | 15.2 | 1.001 | 0.4% | 0.2% |
| bm_yamlcpp_arena | 372.6 | 374.7 | 1.006 | 0.2% | 0.3% |

## scalar_dquot_multiline.yml (72,181 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 372.2 | 372.4 | 1.001 | 0.2% | 0.7% |
| bm_libyaml_arena | 539.3 | 537.2 | 0.996 | 0.2% | 0.1% |
| bm_libyaml_arena_reuse | 538.1 | 536.1 | 0.996 | 0.3% | 0.2% |
| bm_ryml_yaml_arena | 294.3 | 291.9 | 0.992 | 0.8% | 0.3% |
| bm_ryml_yaml_arena_nofilter | 96.3 | 95.5 | 0.992 | 0.3% | 0.6% |
| bm_ryml_yaml_arena_nofilter_reserve | 95.1 | 94.8 | 0.997 | 0.5% | 0.8% |
| bm_ryml_yaml_arena_reserve | 292.7 | 291.9 | 0.997 | 0.8% | 0.6% |
| bm_ryml_yaml_arena_reuse | 291.6 | 291.2 | 0.999 | 0.7% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter | 95.9 | 95.8 | 0.998 | 1.0% | 0.7% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 94.8 | 95.1 | 1.003 | 1.2% | 0.7% |
| bm_ryml_yaml_arena_reuse_reserve | 291.6 | 291.7 | 1.000 | 0.7% | 0.6% |
| bm_ryml_yaml_inplace | 292.3 | 290.3 | 0.993 | 0.8% | 0.9% |
| bm_ryml_yaml_inplace_nofilter | 94.7 | 94.0 | 0.992 | 1.2% | 0.9% |
| bm_ryml_yaml_inplace_nofilter_reserve | 93.6 | 93.3 | 0.996 | 0.5% | 1.0% |
| bm_ryml_yaml_inplace_reserve | 291.2 | 290.3 | 0.997 | 0.2% | 0.6% |
| bm_ryml_yaml_inplace_reuse | 290.6 | 289.5 | 0.996 | 0.5% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter | 93.1 | 93.4 | 1.003 | 1.2% | 0.5% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 93.0 | 93.4 | 1.003 | 1.5% | 0.9% |
| bm_ryml_yaml_inplace_reuse_reserve | 290.5 | 290.1 | 0.999 | 0.6% | 0.5% |
| bm_rymlints_yaml_inplace | 575.8 | 576.0 | 1.000 | 0.2% | 0.2% |
| bm_rymlints_yaml_inplace_nofilter | 184.8 | 184.5 | 0.998 | 0.4% | 0.2% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 95.6 | 94.9 | 0.993 | 0.9% | 1.0% |
| bm_rymlints_yaml_inplace_reserve | 292.9 | 292.9 | 1.000 | 0.5% | 0.2% |
| bm_rymlints_yaml_inplace_reuse | 288.1 | 287.9 | 0.999 | 0.4% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 92.1 | 92.0 | 1.000 | 0.2% | 0.6% |
| bm_yamlcpp_arena | 3,341.1 | 3,341.8 | 1.000 | 0.7% | 0.4% |

## scalar_dquot_singleline.yml (4,824 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 89.4 | 88.6 | 0.991 | 0.7% | 0.2% |
| bm_libyaml_arena | 67.4 | 66.8 | 0.991 | 0.3% | 0.3% |
| bm_libyaml_arena_reuse | 67.4 | 66.7 | 0.989 | 2.0% | 0.2% |
| bm_ryml_yaml_arena | 12.9 | 12.3 | 0.956 | 0.5% | 0.7% |
| bm_ryml_yaml_arena_nofilter | 12.8 | 12.3 | 0.962 | 0.6% | 0.6% |
| bm_ryml_yaml_arena_nofilter_reserve | 11.7 | 11.7 | 0.997 | 0.5% | 0.6% |
| bm_ryml_yaml_arena_reserve | 12.0 | 12.0 | 0.996 | 0.9% | 0.4% |
| bm_ryml_yaml_arena_reuse | 11.7 | 11.6 | 0.997 | 0.4% | 0.6% |
| bm_ryml_yaml_arena_reuse_nofilter | 12.8 | 12.2 | 0.954 | 0.3% | 0.5% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 11.5 | 11.5 | 0.997 | 0.2% | 0.3% |
| bm_ryml_yaml_arena_reuse_reserve | 11.7 | 11.6 | 0.998 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace | 12.9 | 12.4 | 0.964 | 0.6% | 0.4% |
| bm_ryml_yaml_inplace_nofilter | 12.5 | 12.1 | 0.966 | 0.8% | 0.2% |
| bm_ryml_yaml_inplace_nofilter_reserve | 11.5 | 11.5 | 0.999 | 0.8% | 0.2% |
| bm_ryml_yaml_inplace_reserve | 12.0 | 11.9 | 0.993 | 0.4% | 0.4% |
| bm_ryml_yaml_inplace_reuse | 11.6 | 11.5 | 0.994 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 11.5 | 11.4 | 0.995 | 0.7% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 11.5 | 11.4 | 0.994 | 0.6% | 0.5% |
| bm_ryml_yaml_inplace_reuse_reserve | 11.6 | 11.6 | 0.993 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace | 22.1 | 22.1 | 0.999 | 1.0% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter | 21.8 | 21.7 | 0.999 | 0.7% | 0.8% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 11.1 | 11.1 | 1.001 | 0.9% | 0.8% |
| bm_rymlints_yaml_inplace_reserve | 11.3 | 11.3 | 0.999 | 0.9% | 1.1% |
| bm_rymlints_yaml_inplace_reuse | 11.2 | 11.1 | 0.998 | 0.9% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 11.0 | 11.0 | 1.001 | 0.9% | 0.2% |
| bm_yamlcpp_arena | 361.1 | 363.3 | 1.006 | 0.5% | 0.6% |

## scalar_squot_multiline.yml (72,273 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 373.9 | 372.0 | 0.995 | 0.8% | 0.6% |
| bm_libyaml_arena | 540.9 | 538.4 | 0.995 | 0.2% | 0.3% |
| bm_libyaml_arena_reuse | 539.4 | 536.4 | 0.994 | 0.5% | 0.3% |
| bm_ryml_yaml_arena | 243.1 | 244.8 | 1.007 | 0.9% | 0.9% |
| bm_ryml_yaml_arena_nofilter | 84.4 | 85.8 | 1.017 | 2.5% | 1.2% |
| bm_ryml_yaml_arena_nofilter_reserve | 83.5 | 85.4 | 1.022 | 3.2% | 2.4% |
| bm_ryml_yaml_arena_reserve | 241.7 | 243.9 | 1.009 | 0.9% | 1.5% |
| bm_ryml_yaml_arena_reuse | 241.7 | 243.0 | 1.005 | 1.2% | 1.6% |
| bm_ryml_yaml_arena_reuse_nofilter | 85.2 | 85.8 | 1.007 | 4.4% | 3.4% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 84.1 | 85.3 | 1.014 | 3.8% | 2.5% |
| bm_ryml_yaml_arena_reuse_reserve | 241.6 | 242.9 | 1.005 | 1.0% | 1.2% |
| bm_ryml_yaml_inplace | 242.0 | 242.9 | 1.004 | 1.0% | 1.1% |
| bm_ryml_yaml_inplace_nofilter | 82.9 | 84.2 | 1.015 | 3.9% | 2.0% |
| bm_ryml_yaml_inplace_nofilter_reserve | 82.2 | 83.5 | 1.016 | 6.2% | 2.6% |
| bm_ryml_yaml_inplace_reserve | 240.9 | 242.0 | 1.005 | 1.3% | 0.6% |
| bm_ryml_yaml_inplace_reuse | 241.9 | 241.2 | 0.997 | 1.6% | 0.5% |
| bm_ryml_yaml_inplace_reuse_nofilter | 84.1 | 85.3 | 1.014 | 4.2% | 2.7% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 84.7 | 85.8 | 1.013 | 4.4% | 2.0% |
| bm_ryml_yaml_inplace_reuse_reserve | 240.7 | 241.6 | 1.004 | 1.5% | 1.1% |
| bm_rymlints_yaml_inplace | 481.0 | 478.8 | 0.995 | 2.5% | 1.2% |
| bm_rymlints_yaml_inplace_nofilter | 167.6 | 165.8 | 0.990 | 2.2% | 5.9% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 86.6 | 86.3 | 0.997 | 5.3% | 3.1% |
| bm_rymlints_yaml_inplace_reserve | 242.5 | 241.6 | 0.997 | 2.3% | 1.7% |
| bm_rymlints_yaml_inplace_reuse | 239.0 | 238.7 | 0.999 | 0.8% | 2.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 82.7 | 84.2 | 1.018 | 3.3% | 3.4% |
| bm_yamlcpp_arena | 2,906.2 | 2,906.2 | 1.000 | 0.7% | 0.8% |

## scalar_squot_singleline.yml (4,820 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 89.7 | 89.0 | 0.992 | 0.1% | 0.2% |
| bm_libyaml_arena | 67.2 | 66.7 | 0.993 | 0.3% | 0.4% |
| bm_libyaml_arena_reuse | 67.1 | 66.5 | 0.992 | 0.3% | 0.3% |
| bm_ryml_yaml_arena | 12.7 | 12.2 | 0.959 | 0.8% | 1.3% |
| bm_ryml_yaml_arena_nofilter | 12.1 | 11.6 | 0.958 | 0.8% | 0.8% |
| bm_ryml_yaml_arena_nofilter_reserve | 11.0 | 11.0 | 0.997 | 1.1% | 0.8% |
| bm_ryml_yaml_arena_reserve | 11.9 | 11.8 | 0.994 | 0.8% | 1.2% |
| bm_ryml_yaml_arena_reuse | 11.5 | 11.5 | 0.995 | 0.7% | 0.8% |
| bm_ryml_yaml_arena_reuse_nofilter | 12.1 | 11.6 | 0.954 | 0.6% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 10.9 | 10.9 | 1.000 | 0.6% | 1.0% |
| bm_ryml_yaml_arena_reuse_reserve | 11.6 | 11.5 | 0.994 | 0.6% | 1.1% |
| bm_ryml_yaml_inplace | 12.7 | 12.2 | 0.964 | 0.9% | 0.8% |
| bm_ryml_yaml_inplace_nofilter | 11.9 | 11.4 | 0.963 | 0.9% | 0.8% |
| bm_ryml_yaml_inplace_nofilter_reserve | 10.9 | 10.9 | 0.999 | 0.7% | 0.8% |
| bm_ryml_yaml_inplace_reserve | 11.8 | 11.7 | 0.997 | 0.9% | 0.8% |
| bm_ryml_yaml_inplace_reuse | 11.5 | 11.4 | 0.993 | 0.8% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 10.8 | 10.8 | 0.996 | 0.6% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 10.8 | 10.8 | 0.996 | 0.5% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 11.5 | 11.4 | 0.992 | 0.5% | 1.0% |
| bm_rymlints_yaml_inplace | 21.9 | 21.9 | 1.002 | 0.4% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter | 20.7 | 20.6 | 0.998 | 0.4% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 10.5 | 10.5 | 1.002 | 0.3% | 0.6% |
| bm_rymlints_yaml_inplace_reserve | 11.2 | 11.2 | 1.003 | 0.9% | 0.5% |
| bm_rymlints_yaml_inplace_reuse | 11.1 | 11.1 | 1.000 | 1.0% | 0.9% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 10.3 | 10.4 | 1.002 | 0.5% | 0.8% |
| bm_yamlcpp_arena | 344.8 | 347.8 | 1.009 | 1.0% | 0.8% |

## scalar_plain_multiline.yml (72,041 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 339.2 | 338.3 | 0.997 | 0.8% | 0.5% |
| bm_libyaml_arena | 603.2 | 603.1 | 1.000 | 0.1% | 0.3% |
| bm_libyaml_arena_reuse | 602.0 | 601.5 | 0.999 | 0.3% | 0.3% |
| bm_ryml_yaml_arena | 349.4 | 348.3 | 0.997 | 0.4% | 0.2% |
| bm_ryml_yaml_arena_nofilter | 205.8 | 205.3 | 0.997 | 0.5% | 0.2% |
| bm_ryml_yaml_arena_nofilter_reserve | 204.7 | 204.5 | 0.999 | 0.4% | 0.2% |
| bm_ryml_yaml_arena_reserve | 348.6 | 347.9 | 0.998 | 0.5% | 0.2% |
| bm_ryml_yaml_arena_reuse | 348.1 | 347.4 | 0.998 | 0.1% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter | 205.7 | 205.4 | 0.998 | 0.3% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 204.4 | 204.6 | 1.001 | 0.6% | 0.3% |
| bm_ryml_yaml_arena_reuse_reserve | 348.1 | 347.9 | 0.999 | 0.3% | 0.2% |
| bm_ryml_yaml_inplace | 347.9 | 346.9 | 0.997 | 0.4% | 0.1% |
| bm_ryml_yaml_inplace_nofilter | 204.2 | 203.7 | 0.998 | 0.4% | 0.2% |
| bm_ryml_yaml_inplace_nofilter_reserve | 203.2 | 202.9 | 0.998 | 0.4% | 0.3% |
| bm_ryml_yaml_inplace_reserve | 346.4 | 346.0 | 0.999 | 0.3% | 0.2% |
| bm_ryml_yaml_inplace_reuse | 346.2 | 345.9 | 0.999 | 0.3% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter | 203.5 | 203.1 | 0.998 | 0.7% | 0.1% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 203.1 | 203.1 | 1.000 | 0.7% | 0.1% |
| bm_ryml_yaml_inplace_reuse_reserve | 346.2 | 346.1 | 1.000 | 0.3% | 0.2% |
| bm_rymlints_yaml_inplace | 691.0 | 690.1 | 0.999 | 0.4% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter | 404.5 | 404.3 | 0.999 | 0.5% | 0.6% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 204.4 | 203.9 | 0.998 | 0.6% | 0.9% |
| bm_rymlints_yaml_inplace_reserve | 351.1 | 350.6 | 0.999 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_reuse | 345.3 | 345.0 | 0.999 | 0.5% | 0.1% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 202.2 | 202.3 | 1.001 | 0.6% | 0.6% |
| bm_yamlcpp_arena | 4,829.7 | 4,828.2 | 1.000 | 0.8% | 0.9% |

## scalar_plain_singleline.yml (4,676 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 86.0 | 85.8 | 0.997 | 0.7% | 0.6% |
| bm_libyaml_arena | 70.0 | 70.0 | 1.000 | 0.4% | 0.1% |
| bm_libyaml_arena_reuse | 68.6 | 68.8 | 1.002 | 1.0% | 0.1% |
| bm_ryml_yaml_arena | 18.8 | 18.4 | 0.977 | 2.3% | 0.1% |
| bm_ryml_yaml_arena_nofilter | 18.8 | 18.4 | 0.976 | 0.3% | 0.1% |
| bm_ryml_yaml_arena_nofilter_reserve | 17.8 | 17.8 | 1.000 | 0.3% | 0.1% |
| bm_ryml_yaml_arena_reserve | 18.0 | 18.1 | 1.001 | 0.2% | 0.1% |
| bm_ryml_yaml_arena_reuse | 17.7 | 17.7 | 1.003 | 0.3% | 0.2% |
| bm_ryml_yaml_arena_reuse_nofilter | 18.8 | 18.3 | 0.973 | 0.2% | 0.1% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 17.6 | 17.6 | 1.004 | 0.2% | 0.2% |
| bm_ryml_yaml_arena_reuse_reserve | 17.7 | 17.7 | 1.003 | 0.4% | 0.1% |
| bm_ryml_yaml_inplace | 18.9 | 18.5 | 0.978 | 0.2% | 0.2% |
| bm_ryml_yaml_inplace_nofilter | 18.6 | 18.2 | 0.979 | 0.3% | 0.0% |
| bm_ryml_yaml_inplace_nofilter_reserve | 17.6 | 17.6 | 1.003 | 0.3% | 0.2% |
| bm_ryml_yaml_inplace_reserve | 17.9 | 17.9 | 1.004 | 0.4% | 0.1% |
| bm_ryml_yaml_inplace_reuse | 17.6 | 17.7 | 1.003 | 0.1% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter | 17.5 | 17.5 | 1.003 | 0.2% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 17.5 | 17.6 | 1.003 | 0.2% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 17.6 | 17.7 | 1.002 | 0.1% | 0.2% |
| bm_rymlints_yaml_inplace | 34.2 | 34.2 | 1.000 | 0.2% | 0.1% |
| bm_rymlints_yaml_inplace_nofilter | 33.9 | 33.9 | 1.000 | 0.1% | 0.4% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 17.1 | 17.1 | 1.002 | 0.2% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 17.3 | 17.3 | 1.001 | 0.2% | 0.4% |
| bm_rymlints_yaml_inplace_reuse | 17.2 | 17.2 | 1.001 | 0.1% | 0.2% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 17.0 | 17.0 | 1.000 | 0.3% | 0.3% |
| bm_yamlcpp_arena | 464.0 | 464.0 | 1.000 | 0.4% | 0.4% |

## scalar_block_literal_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 359.6 | 358.6 | 0.997 | 0.3% | 0.1% |
| bm_libyaml_arena | 522.0 | 524.4 | 1.005 | 0.2% | 0.2% |
| bm_libyaml_arena_reuse | 521.2 | 523.1 | 1.004 | 0.2% | 0.1% |
| bm_ryml_yaml_arena | 117.1 | 115.2 | 0.984 | 4.6% | 0.5% |
| bm_ryml_yaml_arena_nofilter | 55.4 | 55.0 | 0.992 | 0.7% | 4.4% |
| bm_ryml_yaml_arena_nofilter_reserve | 54.4 | 54.2 | 0.996 | 0.8% | 2.2% |
| bm_ryml_yaml_arena_reserve | 116.6 | 114.7 | 0.984 | 4.1% | 0.5% |
| bm_ryml_yaml_arena_reuse | 118.5 | 114.8 | 0.968 | 2.8% | 0.7% |
| bm_ryml_yaml_arena_reuse_nofilter | 55.7 | 54.9 | 0.985 | 0.8% | 2.0% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 54.5 | 54.2 | 0.995 | 0.7% | 2.0% |
| bm_ryml_yaml_arena_reuse_reserve | 118.5 | 114.7 | 0.968 | 4.6% | 0.8% |
| bm_ryml_yaml_inplace | 118.1 | 114.0 | 0.966 | 2.1% | 0.7% |
| bm_ryml_yaml_inplace_nofilter | 53.7 | 53.4 | 0.993 | 0.9% | 0.8% |
| bm_ryml_yaml_inplace_nofilter_reserve | 52.7 | 52.6 | 0.998 | 1.0% | 0.4% |
| bm_ryml_yaml_inplace_reserve | 117.8 | 113.1 | 0.960 | 3.9% | 0.9% |
| bm_ryml_yaml_inplace_reuse | 118.0 | 112.6 | 0.954 | 4.7% | 0.9% |
| bm_ryml_yaml_inplace_reuse_nofilter | 52.9 | 52.7 | 0.996 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 53.0 | 52.7 | 0.995 | 0.2% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 118.0 | 112.6 | 0.954 | 4.2% | 1.5% |
| bm_rymlints_yaml_inplace | 221.9 | 223.3 | 1.006 | 0.3% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter | 103.3 | 103.5 | 1.003 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 53.4 | 53.5 | 1.003 | 1.2% | 1.6% |
| bm_rymlints_yaml_inplace_reserve | 115.0 | 115.1 | 1.001 | 0.8% | 1.4% |
| bm_rymlints_yaml_inplace_reuse | 111.1 | 111.4 | 1.003 | 1.0% | 1.0% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 52.0 | 51.9 | 0.999 | 0.4% | 0.4% |
| bm_yamlcpp_arena | 2,719.4 | 2,770.9 | 1.019 | 0.2% | 1.8% |

## scalar_block_literal_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 91.0 | 90.2 | 0.991 | 0.2% | 0.1% |
| bm_libyaml_arena | 66.3 | 66.1 | 0.998 | 0.1% | 0.1% |
| bm_libyaml_arena_reuse | 66.2 | 66.0 | 0.997 | 1.7% | 1.9% |
| bm_ryml_yaml_arena | 18.7 | 18.1 | 0.966 | 0.4% | 0.7% |
| bm_ryml_yaml_arena_nofilter | 14.0 | 13.5 | 0.965 | 0.2% | 0.9% |
| bm_ryml_yaml_arena_nofilter_reserve | 12.9 | 12.9 | 0.999 | 0.9% | 1.0% |
| bm_ryml_yaml_arena_reserve | 17.9 | 17.8 | 0.997 | 1.1% | 1.3% |
| bm_ryml_yaml_arena_reuse | 17.7 | 17.6 | 0.995 | 1.6% | 0.9% |
| bm_ryml_yaml_arena_reuse_nofilter | 14.2 | 13.5 | 0.955 | 1.5% | 1.1% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 12.7 | 12.8 | 1.002 | 0.4% | 0.7% |
| bm_ryml_yaml_arena_reuse_reserve | 17.6 | 17.6 | 0.999 | 1.3% | 0.4% |
| bm_ryml_yaml_inplace | 18.8 | 18.4 | 0.977 | 0.6% | 0.7% |
| bm_ryml_yaml_inplace_nofilter | 13.8 | 13.4 | 0.968 | 2.3% | 1.0% |
| bm_ryml_yaml_inplace_nofilter_reserve | 12.7 | 12.7 | 1.002 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace_reserve | 17.7 | 17.7 | 1.001 | 1.5% | 0.6% |
| bm_ryml_yaml_inplace_reuse | 17.5 | 17.5 | 1.003 | 0.5% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 12.7 | 12.7 | 1.003 | 0.2% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 12.6 | 12.7 | 1.004 | 0.1% | 0.6% |
| bm_ryml_yaml_inplace_reuse_reserve | 17.4 | 17.5 | 1.004 | 0.9% | 0.5% |
| bm_rymlints_yaml_inplace | 33.7 | 33.8 | 1.004 | 1.0% | 2.7% |
| bm_rymlints_yaml_inplace_nofilter | 24.2 | 24.2 | 1.001 | 1.8% | 0.9% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 12.5 | 12.5 | 1.002 | 0.9% | 1.5% |
| bm_rymlints_yaml_inplace_reserve | 17.5 | 17.5 | 0.999 | 0.9% | 0.5% |
| bm_rymlints_yaml_inplace_reuse | 17.1 | 17.3 | 1.012 | 1.0% | 0.8% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 12.3 | 12.3 | 1.000 | 1.1% | 0.8% |
| bm_yamlcpp_arena | 344.8 | 345.7 | 1.002 | 0.8% | 1.2% |

## scalar_block_folded_multiline.yml (72,577 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 359.8 | 358.3 | 0.996 | 0.1% | 0.2% |
| bm_libyaml_arena | 517.3 | 520.5 | 1.006 | 0.1% | 0.2% |
| bm_libyaml_arena_reuse | 516.5 | 519.1 | 1.005 | 0.2% | 0.2% |
| bm_ryml_yaml_arena | 188.6 | 188.0 | 0.997 | 0.0% | 0.2% |
| bm_ryml_yaml_arena_nofilter | 55.4 | 55.0 | 0.992 | 0.3% | 0.3% |
| bm_ryml_yaml_arena_nofilter_reserve | 54.3 | 54.3 | 1.001 | 1.0% | 0.3% |
| bm_ryml_yaml_arena_reserve | 187.7 | 188.0 | 1.001 | 0.2% | 0.2% |
| bm_ryml_yaml_arena_reuse | 187.4 | 187.2 | 0.999 | 0.3% | 0.6% |
| bm_ryml_yaml_arena_reuse_nofilter | 55.5 | 55.0 | 0.991 | 1.1% | 0.8% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 54.2 | 54.2 | 1.001 | 1.5% | 0.5% |
| bm_ryml_yaml_arena_reuse_reserve | 187.6 | 187.4 | 0.999 | 0.4% | 0.1% |
| bm_ryml_yaml_inplace | 187.5 | 187.2 | 0.998 | 0.2% | 0.1% |
| bm_ryml_yaml_inplace_nofilter | 53.8 | 53.5 | 0.994 | 0.8% | 0.1% |
| bm_ryml_yaml_inplace_nofilter_reserve | 53.0 | 52.7 | 0.995 | 1.0% | 0.2% |
| bm_ryml_yaml_inplace_reserve | 186.4 | 185.9 | 0.997 | 0.2% | 0.1% |
| bm_ryml_yaml_inplace_reuse | 185.9 | 185.4 | 0.997 | 0.3% | 0.4% |
| bm_ryml_yaml_inplace_reuse_nofilter | 53.0 | 52.7 | 0.995 | 1.1% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 53.1 | 52.8 | 0.996 | 1.0% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 186.1 | 185.5 | 0.996 | 0.3% | 0.1% |
| bm_rymlints_yaml_inplace | 370.6 | 370.1 | 0.999 | 0.6% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter | 103.6 | 103.4 | 0.998 | 0.2% | 0.6% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 53.8 | 53.6 | 0.997 | 1.5% | 2.1% |
| bm_rymlints_yaml_inplace_reserve | 187.6 | 187.1 | 0.997 | 0.4% | 0.6% |
| bm_rymlints_yaml_inplace_reuse | 185.0 | 185.4 | 1.002 | 0.3% | 0.3% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 51.9 | 51.9 | 1.000 | 0.4% | 0.5% |
| bm_yamlcpp_arena | 2,725.4 | 2,733.3 | 1.003 | 0.7% | 0.6% |

## scalar_block_folded_singleline.yml (5,257 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 90.9 | 90.2 | 0.992 | 0.3% | 0.2% |
| bm_libyaml_arena | 66.3 | 66.1 | 0.997 | 0.2% | 0.1% |
| bm_libyaml_arena_reuse | 66.2 | 66.0 | 0.997 | 1.8% | 1.9% |
| bm_ryml_yaml_arena | 22.6 | 22.1 | 0.976 | 1.0% | 0.7% |
| bm_ryml_yaml_arena_nofilter | 14.2 | 13.6 | 0.962 | 0.9% | 0.9% |
| bm_ryml_yaml_arena_nofilter_reserve | 13.0 | 12.9 | 0.996 | 0.8% | 0.8% |
| bm_ryml_yaml_arena_reserve | 21.7 | 21.6 | 0.994 | 0.3% | 0.7% |
| bm_ryml_yaml_arena_reuse | 21.5 | 21.4 | 0.997 | 0.7% | 0.5% |
| bm_ryml_yaml_arena_reuse_nofilter | 14.3 | 13.5 | 0.948 | 1.8% | 1.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 12.8 | 12.8 | 0.999 | 0.7% | 0.8% |
| bm_ryml_yaml_arena_reuse_reserve | 21.4 | 21.4 | 0.996 | 0.6% | 0.8% |
| bm_ryml_yaml_inplace | 22.7 | 22.3 | 0.982 | 0.3% | 0.9% |
| bm_ryml_yaml_inplace_nofilter | 13.9 | 13.5 | 0.971 | 1.1% | 1.1% |
| bm_ryml_yaml_inplace_nofilter_reserve | 12.8 | 12.8 | 1.001 | 1.4% | 1.4% |
| bm_ryml_yaml_inplace_reserve | 21.6 | 21.6 | 0.999 | 0.3% | 0.8% |
| bm_ryml_yaml_inplace_reuse | 21.4 | 21.3 | 0.999 | 0.6% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter | 12.7 | 12.8 | 1.005 | 0.4% | 0.9% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 12.7 | 12.7 | 1.004 | 0.3% | 0.8% |
| bm_ryml_yaml_inplace_reuse_reserve | 21.3 | 21.2 | 0.996 | 0.4% | 0.4% |
| bm_rymlints_yaml_inplace | 41.2 | 41.1 | 0.999 | 0.8% | 1.0% |
| bm_rymlints_yaml_inplace_nofilter | 24.2 | 24.3 | 1.003 | 1.1% | 0.7% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 12.4 | 12.4 | 1.000 | 0.5% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 21.2 | 21.1 | 0.999 | 0.2% | 0.2% |
| bm_rymlints_yaml_inplace_reuse | 20.9 | 20.9 | 1.001 | 0.9% | 0.6% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 12.2 | 12.2 | 1.002 | 0.9% | 1.2% |
| bm_yamlcpp_arena | 345.6 | 347.2 | 1.004 | 0.7% | 1.0% |

## medium.yaml (22,421,093 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 5,732.6 | 5,734.8 | 1.000 | 0.1% | 0.1% |
| bm_libyaml_arena | 416,517 | 388,577 | 0.933 | 2.2% | 0.9% |
| bm_libyaml_arena_reuse | 347,018 | 330,243 | 0.952 | 0.4% | 0.1% |
| bm_ryml_yaml_arena | 220,192 | 149,493 | 0.679 | 4.6% | 0.2% |
| bm_ryml_yaml_arena_nofilter | 211,981 | 139,757 | 0.659 | 3.2% | 0.1% |
| bm_ryml_yaml_arena_nofilter_reserve | 111,068 | 129,364 | 1.165 | 1.9% | 0.5% |
| bm_ryml_yaml_arena_reserve | 121,121 | 139,143 | 1.149 | 1.8% | 0.2% |
| bm_ryml_yaml_arena_reuse | 114,269 | 114,020 | 0.998 | 0.3% | 0.1% |
| bm_ryml_yaml_arena_reuse_nofilter | 211,955 | 139,765 | 0.659 | 4.0% | 1.8% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 104,910 | 104,551 | 0.997 | 0.4% | 0.3% |
| bm_ryml_yaml_arena_reuse_reserve | 114,216 | 113,898 | 0.997 | 0.3% | 6.1% |
| bm_ryml_yaml_inplace | 204,388 | 148,569 | 0.727 | 4.1% | 0.2% |
| bm_ryml_yaml_inplace_nofilter | 194,000 | 138,763 | 0.715 | 4.2% | 0.2% |
| bm_ryml_yaml_inplace_nofilter_reserve | 110,497 | 128,551 | 1.163 | 1.6% | 1.9% |
| bm_ryml_yaml_inplace_reserve | 119,675 | 138,352 | 1.156 | 1.8% | 0.1% |
| bm_ryml_yaml_inplace_reuse | 113,366 | 113,120 | 0.998 | 0.1% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter | 103,963 | 103,789 | 0.998 | 0.3% | 0.2% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 103,577 | 103,679 | 1.001 | 0.3% | 0.2% |
| bm_ryml_yaml_inplace_reuse_reserve | 113,437 | 112,971 | 0.996 | 0.2% | 0.4% |
| bm_rymlints_yaml_inplace | 212,197 | 212,254 | 1.000 | 0.1% | 0.2% |
| bm_rymlints_yaml_inplace_nofilter | 194,062 | 194,041 | 1.000 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 102,823 | 103,181 | 1.003 | 0.5% | 0.7% |
| bm_rymlints_yaml_inplace_reserve | 111,911 | 112,049 | 1.001 | 0.3% | 0.6% |
| bm_rymlints_yaml_inplace_reuse | 108,193 | 108,171 | 1.000 | 0.4% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 98,955 | 99,098 | 1.001 | 0.3% | 0.2% |
| bm_yamlcpp_arena | 2,477.1 | 2,395.8 | 0.967 | 5.6% | 6.8% |

## big_scalar_block_literal_multiline.yml (1,088,715 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 4,866.1 | 4,881.7 | 1.003 | 0.2% | 0.3% |
| bm_libyaml_arena | 7,848.7 | 7,590.4 | 0.967 | 0.2% | 0.3% |
| bm_libyaml_arena_reuse | 7,838.2 | 7,559.6 | 0.964 | 0.2% | 0.4% |
| bm_ryml_yaml_arena | 1,780.1 | 2,227.4 | 1.251 | 3.6% | 1.0% |
| bm_ryml_yaml_arena_nofilter | 838.7 | 1,317.3 | 1.571 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_nofilter_reserve | 823.6 | 816.7 | 0.992 | 0.3% | 0.4% |
| bm_ryml_yaml_arena_reserve | 1,764.1 | 1,724.5 | 0.978 | 3.9% | 0.9% |
| bm_ryml_yaml_arena_reuse | 1,790.0 | 1,719.2 | 0.960 | 4.2% | 0.8% |
| bm_ryml_yaml_arena_reuse_nofilter | 844.9 | 1,315.5 | 1.557 | 0.9% | 0.6% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 822.4 | 816.7 | 0.993 | 0.9% | 0.8% |
| bm_ryml_yaml_arena_reuse_reserve | 1,781.6 | 1,717.6 | 0.964 | 3.2% | 1.1% |
| bm_ryml_yaml_inplace | 1,784.7 | 2,193.3 | 1.229 | 4.8% | 0.6% |
| bm_ryml_yaml_inplace_nofilter | 808.7 | 1,285.5 | 1.590 | 1.2% | 0.5% |
| bm_ryml_yaml_inplace_nofilter_reserve | 789.9 | 787.9 | 0.997 | 0.5% | 0.5% |
| bm_ryml_yaml_inplace_reserve | 1,731.6 | 1,694.1 | 0.978 | 3.6% | 0.7% |
| bm_ryml_yaml_inplace_reuse | 1,769.2 | 1,691.0 | 0.956 | 4.7% | 0.5% |
| bm_ryml_yaml_inplace_reuse_nofilter | 790.7 | 789.1 | 0.998 | 0.4% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 791.0 | 789.3 | 0.998 | 0.5% | 0.3% |
| bm_ryml_yaml_inplace_reuse_reserve | 1,761.6 | 1,686.8 | 0.958 | 5.5% | 0.4% |
| bm_rymlints_yaml_inplace | 3,350.1 | 3,355.0 | 1.001 | 1.0% | 1.1% |
| bm_rymlints_yaml_inplace_nofilter | 1,559.8 | 1,549.9 | 0.994 | 0.4% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 813.9 | 810.7 | 0.996 | 0.2% | 0.4% |
| bm_rymlints_yaml_inplace_reserve | 1,718.6 | 1,715.9 | 0.998 | 0.3% | 0.3% |
| bm_rymlints_yaml_inplace_reuse | 1,680.2 | 1,681.0 | 1.000 | 0.8% | 1.0% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 781.1 | 782.0 | 1.001 | 0.6% | 0.2% |
| bm_yamlcpp_arena | 2,825.7 | 2,806.7 | 0.993 | 0.4% | 0.6% |

## big_scalar_dquot_multiline.yml (1,082,775 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 5,050.3 | 5,041.6 | 0.998 | 0.4% | 0.2% |
| bm_libyaml_arena | 8,104.4 | 8,239.6 | 1.017 | 0.4% | 0.2% |
| bm_libyaml_arena_reuse | 8,108.4 | 8,221.0 | 1.014 | 0.3% | 0.1% |
| bm_ryml_yaml_arena | 4,419.9 | 4,887.8 | 1.106 | 0.7% | 0.5% |
| bm_ryml_yaml_arena_nofilter | 1,449.5 | 1,926.5 | 1.329 | 1.0% | 0.4% |
| bm_ryml_yaml_arena_nofilter_reserve | 1,435.2 | 1,430.4 | 0.997 | 0.9% | 0.3% |
| bm_ryml_yaml_arena_reserve | 4,409.0 | 4,392.7 | 0.996 | 1.0% | 0.5% |
| bm_ryml_yaml_arena_reuse | 4,403.0 | 4,372.6 | 0.993 | 1.1% | 0.6% |
| bm_ryml_yaml_arena_reuse_nofilter | 1,461.5 | 1,924.6 | 1.317 | 1.0% | 0.3% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 1,440.4 | 1,428.9 | 0.992 | 0.9% | 0.5% |
| bm_ryml_yaml_arena_reuse_reserve | 4,418.9 | 4,377.5 | 0.991 | 0.8% | 0.5% |
| bm_ryml_yaml_inplace | 4,397.4 | 4,849.6 | 1.103 | 0.8% | 0.3% |
| bm_ryml_yaml_inplace_nofilter | 1,421.5 | 1,894.8 | 1.333 | 0.8% | 0.2% |
| bm_ryml_yaml_inplace_nofilter_reserve | 1,401.3 | 1,398.0 | 0.998 | 0.7% | 0.5% |
| bm_ryml_yaml_inplace_reserve | 4,374.7 | 4,359.1 | 0.996 | 0.3% | 0.4% |
| bm_ryml_yaml_inplace_reuse | 4,364.9 | 4,340.6 | 0.994 | 0.4% | 0.5% |
| bm_ryml_yaml_inplace_reuse_nofilter | 1,399.0 | 1,398.8 | 1.000 | 0.8% | 0.6% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 1,397.0 | 1,398.2 | 1.001 | 1.0% | 0.5% |
| bm_ryml_yaml_inplace_reuse_reserve | 4,358.4 | 4,337.2 | 0.995 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace | 8,642.7 | 8,645.9 | 1.000 | 0.5% | 0.4% |
| bm_rymlints_yaml_inplace_nofilter | 2,757.4 | 2,762.1 | 1.002 | 0.3% | 0.5% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 1,407.3 | 1,411.4 | 1.003 | 0.2% | 0.2% |
| bm_rymlints_yaml_inplace_reserve | 4,350.5 | 4,353.8 | 1.001 | 0.1% | 0.2% |
| bm_rymlints_yaml_inplace_reuse | 4,322.3 | 4,323.3 | 1.000 | 0.1% | 0.1% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 1,383.9 | 1,380.9 | 0.998 | 0.3% | 0.5% |
| bm_yamlcpp_arena | 3,442.4 | 3,411.9 | 0.991 | 0.6% | 0.4% |

## big_scalar_plain_multiline.yml (1,080,675 bytes)

| row | master us | branch us | ratio | master spread | branch spread |
|---|---:|---:|---:|---:|---:|
| bm_libfyaml_arena | 4,545.9 | 4,529.4 | 0.996 | 0.3% | 0.2% |
| bm_libyaml_arena | 9,080.4 | 9,172.9 | 1.010 | 0.4% | 0.2% |
| bm_libyaml_arena_reuse | 9,068.5 | 9,153.6 | 1.009 | 0.3% | 0.2% |
| bm_ryml_yaml_arena | 5,259.7 | 5,721.1 | 1.088 | 0.3% | 0.1% |
| bm_ryml_yaml_arena_nofilter | 3,098.5 | 3,562.4 | 1.150 | 0.7% | 0.4% |
| bm_ryml_yaml_arena_nofilter_reserve | 3,079.9 | 3,067.1 | 0.996 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_reserve | 5,240.9 | 5,222.9 | 0.997 | 0.2% | 0.2% |
| bm_ryml_yaml_arena_reuse | 5,236.8 | 5,215.9 | 0.996 | 0.1% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter | 3,102.6 | 3,563.2 | 1.148 | 0.4% | 0.4% |
| bm_ryml_yaml_arena_reuse_nofilter_reserve | 3,079.5 | 3,071.8 | 0.997 | 0.3% | 0.6% |
| bm_ryml_yaml_arena_reuse_reserve | 5,234.5 | 5,215.7 | 0.996 | 0.2% | 0.3% |
| bm_ryml_yaml_inplace | 5,220.4 | 5,681.0 | 1.088 | 0.1% | 0.1% |
| bm_ryml_yaml_inplace_nofilter | 3,067.0 | 3,533.7 | 1.152 | 0.3% | 0.1% |
| bm_ryml_yaml_inplace_nofilter_reserve | 3,047.1 | 3,038.8 | 0.997 | 0.2% | 0.1% |
| bm_ryml_yaml_inplace_reserve | 5,198.8 | 5,189.4 | 0.998 | 0.1% | 0.1% |
| bm_ryml_yaml_inplace_reuse | 5,196.4 | 5,185.0 | 0.998 | 0.1% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter | 3,044.4 | 3,043.4 | 1.000 | 0.3% | 0.3% |
| bm_ryml_yaml_inplace_reuse_nofilter_reserve | 3,045.8 | 3,042.6 | 0.999 | 0.6% | 0.4% |
| bm_ryml_yaml_inplace_reuse_reserve | 5,197.6 | 5,192.7 | 0.999 | 0.1% | 0.1% |
| bm_rymlints_yaml_inplace | 10,359 | 10,364 | 1.000 | 0.4% | 0.1% |
| bm_rymlints_yaml_inplace_nofilter | 6,055.7 | 6,066.3 | 1.002 | 0.2% | 0.3% |
| bm_rymlints_yaml_inplace_nofilter_reserve | 3,049.7 | 3,055.0 | 1.002 | 0.5% | 0.5% |
| bm_rymlints_yaml_inplace_reserve | 5,240.1 | 5,248.0 | 1.002 | 0.1% | 0.1% |
| bm_rymlints_yaml_inplace_reuse | 5,180.1 | 5,183.0 | 1.001 | 0.3% | 0.4% |
| bm_rymlints_yaml_inplace_reuse_nofilter | 3,032.6 | 3,034.7 | 1.001 | 0.1% | 0.3% |
| bm_yamlcpp_arena | 4,928.5 | 4,966.6 | 1.008 | 0.4% | 0.3% |

