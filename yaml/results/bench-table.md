| size | row | best s | median s | spread | vs Goose | cycles:u (G) | instr:u (G) | peak RSS MB |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| small | yaml-cpp (idiomatic) | 0.138 | 0.138 | 0.9% | 9.89x | 0.318 | 1.262 | 29.5 |
| small | rapidyaml (expert) | 0.023 | 0.024 | 2.5% | 1.69x | 0.027 | 0.079 | 14.9 |
| small | rapidyaml, reserved | 0.021 | 0.021 | 1.4% | 1.49x | 0.029 | 0.090 | 10.1 |
| small | Goose | 0.014 | 0.014 | 3.6% |  | 0.015 | 0.048 | 4.3 |
| small | C twin of Goose | 0.013 | 0.014 | 3.7% | 0.97x | 0.015 | 0.047 | 4.0 |
| small | start-up floor | 0.007 | 0.007 | 2.9% |  | 0.000 | 0.000 | 1.4 |
| medium | yaml-cpp (idiomatic) | 2.596 | 2.606 | 3.2% | 20.11x | 6.303 | 24.592 | 542.6 |
| medium | rapidyaml (expert) | 0.297 | 0.301 | 2.0% | 2.32x | 0.514 | 1.496 | 213.5 |
| medium | rapidyaml, reserved | 0.261 | 0.263 | 1.1% | 2.03x | 0.546 | 1.736 | 146.8 |
| medium | Goose | 0.128 | 0.130 | 1.9% |  | 0.272 | 0.900 | 56.2 |
| medium | C twin of Goose | 0.129 | 0.130 | 1.9% | 1.00x | 0.276 | 0.868 | 56.0 |
| medium | start-up floor | 0.007 | 0.007 | 4.0% |  | 0.000 | 0.000 | 1.5 |
| large | yaml-cpp (idiomatic) | 20.682 | 20.803 | 0.8% | 21.02x | 50.576 | 196.656 | 4227.0 |
| large | rapidyaml (expert) | 2.381 | 2.384 | 0.5% | 2.41x | 4.145 | 11.953 | 1596.1 |
| large | rapidyaml, reserved | 2.051 | 2.054 | 0.2% | 2.08x | 4.360 | 13.871 | 1151.3 |
| large | Goose | 0.967 | 0.990 | 4.0% |  | 2.171 | 7.198 | 439.0 |
| large | C twin of Goose | 0.979 | 0.991 | 2.0% | 1.00x | 2.202 | 6.940 | 438.7 |
| large | start-up floor | 0.007 | 0.007 | 1.3% |  | 0.000 | 0.000 | 1.4 |
