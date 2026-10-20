| size | row | best s | median s | spread | vs Goose | cycles:u (G) | instr:u (G) | peak RSS MB |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| small | yaml-cpp (idiomatic) | 0.140 | 0.141 | 0.9% | 9.67x | 0.323 | 1.299 | 30.8 |
| small | rapidyaml (expert) | 0.021 | 0.021 | 165.6% | 1.47x | 0.027 | 0.076 | 10.2 |
| small | rapidyaml, reserved | 0.021 | 0.021 | 3.3% | 1.47x | 0.030 | 0.088 | 9.7 |
| small | Goose | 0.015 | 0.015 | 2.1% |  | 0.017 | 0.048 | 4.2 |
| small | C twin of Goose | 0.014 | 0.014 | 1.4% | 0.97x | 0.016 | 0.047 | 4.1 |
| small | start-up floor | 0.007 | 0.007 | 9.9% |  | 0.000 | 0.000 | 1.4 |
| medium | yaml-cpp (idiomatic) | 2.877 | 2.887 | 0.5% | 17.75x | 6.998 | 27.554 | 596.6 |
| medium | rapidyaml (expert) | 0.323 | 0.324 | 1.0% | 1.99x | 0.576 | 1.578 | 215.4 |
| medium | rapidyaml, reserved | 0.292 | 0.292 | 0.6% | 1.80x | 0.619 | 1.819 | 151.6 |
| medium | Goose | 0.162 | 0.163 | 0.4% |  | 0.351 | 1.010 | 60.1 |
| medium | C twin of Goose | 0.156 | 0.158 | 1.4% | 0.97x | 0.340 | 0.987 | 59.9 |
| medium | start-up floor | 0.007 | 0.007 | 2.7% |  | 0.000 | 0.000 | 1.4 |
| large | yaml-cpp (idiomatic) | 22.924 | 23.050 | 0.8% | 18.43x | 56.059 | 220.892 | 4665.6 |
| large | rapidyaml (expert) | 2.589 | 2.604 | 0.8% | 2.08x | 4.665 | 12.633 | 1596.1 |
| large | rapidyaml, reserved | 2.303 | 2.310 | 0.5% | 1.85x | 4.950 | 14.559 | 1193.0 |
| large | Goose | 1.246 | 1.250 | 1.8% |  | 2.819 | 8.094 | 471.3 |
| large | C twin of Goose | 1.204 | 1.217 | 1.5% | 0.97x | 2.713 | 7.914 | 471.0 |
| large | start-up floor | 0.007 | 0.007 | 5.4% |  | 0.000 | 0.000 | 1.5 |
