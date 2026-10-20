# Generated C

Each `.c` file here is the C that goose writes for the `.goose` file of the same name.
Goose is at commit `0e04966` (github.com/aardappel/goose). The command, run in this folder:

```bash
goose -O2 --stdlib ../../.deps/goose/stdlib -o jqg.c jqg.goose
goose -O2 --stdlib ../../.deps/goose/stdlib -o jqg_match.c jqg_match.goose
```

`bin/emit-c` runs these commands again, and `bin/emit-c --check` compares the result with these files.
The C links with the Goose run-time. `goose --emit-runtime runtime.c` writes that run-time.
The measured binaries come from `goose build <file>.goose -O2 --cc gcc`, which writes the same C and
compiles it and the run-time with `gcc -O2`.

`repro/casefn_zero_size_variant.goose` has no C: at this commit `goose build` stops on it with an internal error. That is the point of the file.
