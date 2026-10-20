# Generated C

Each `.c` file here is the C that goose writes for the `.goose` file of the same name.
Goose is at commit `0e04966` (github.com/aardappel/goose). The command, run in this folder:

```bash
goose -O2 --stdlib ../../.deps/goose/stdlib -o json.c json.goose
goose -O2 --stdlib ../../.deps/goose/stdlib -o json_fast.c json_fast.goose
goose -O2 --stdlib ../../.deps/goose/stdlib -o json_view.c json_view.goose
goose -O2 --stdlib ../../.deps/goose/stdlib -o json_purefloat.c json_purefloat.goose
```

`bin/emit-c` runs these commands again, and `bin/emit-c --check` compares the result with these files.
The C links with the Goose run-time. `goose --emit-runtime runtime.c` writes that run-time.
The measured binaries come from `goose build <file>.goose -O2 --cc gcc`, which writes the same C and
compiles it and the run-time with `gcc -O2`.

The JSON programs also link `strtod_shim.c` (named in each `.build` file): it calls the C library's `strtod` for long decimals and reads the clock.
