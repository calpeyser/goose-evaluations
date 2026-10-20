| size | row | best s | median s | spread | vs Goose | cycles:u (G) | instr:u (G) | peak RSS MB |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| small | Goose | 0.013 | 0.014 | 2.9% |  | 0.015 | 0.048 | 4.5 |
| small | Goose, one C file | 0.013 | 0.014 | 3.7% | 1.00x | 0.015 | 0.049 | 4.4 |
| small | C twin of Goose | 0.013 | 0.013 | 1.5% | 0.99x | 0.015 | 0.047 | 4.1 |
| medium | Goose | 0.130 | 0.130 | 0.7% |  | 0.272 | 0.900 | 56.3 |
| medium | Goose, one C file | 0.128 | 0.128 | 0.5% | 0.99x | 0.268 | 0.919 | 56.3 |
| medium | C twin of Goose | 0.131 | 0.131 | 0.4% | 1.01x | 0.275 | 0.868 | 55.9 |
| large | Goose | 0.971 | 0.975 | 0.4% |  | 2.170 | 7.198 | 439.0 |
| large | Goose, one C file | 0.959 | 0.962 | 0.9% | 0.99x | 2.142 | 7.347 | 439.0 |
| large | C twin of Goose | 0.981 | 0.984 | 0.8% | 1.01x | 2.202 | 6.940 | 438.6 |
