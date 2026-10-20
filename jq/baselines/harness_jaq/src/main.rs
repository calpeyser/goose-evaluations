// Usage: harness_jaq [-o] '<filter>' < input
// Reads standard input with jaq's streaming JSON reader, runs the filter on each
// value, writes each output compactly with a newline into a buffer, and folds
// the bytes into FNV-1a. Prints the same four checksum lines as jqg.
use jaq_all::data::{compile, run, Runner};
use jaq_all::jaq_core::Vars;
use jaq_all::json::{read, write::{write, Pp}};
use std::cell::Cell;
use std::io::{self, Write};

#[global_allocator]
static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let (show, fi) = if args.len() > 1 && args[1] == "-o" { (true, 2) } else { (false, 1) };
    let filter = compile(&args[fi]).unwrap_or_else(|_| { eprintln!("compile failed"); std::process::exit(3) });
    let runner = Runner::default();
    let pp = Pp::default();
    let stdin = io::stdin();
    let nin = Cell::new(0u64);
    let inputs = read::read_many(stdin.lock()).inspect(|_| nin.set(nin.get() + 1));
    let mut h: u64 = 14695981039346656037;
    let (mut nout, mut nbytes) = (0u64, 0u64);
    let mut buf: Vec<u8> = Vec::with_capacity(1 << 16);
    let out = io::stdout();
    let mut out = out.lock();
    let r = run(&runner, &filter, Vars::new([]), inputs, |e| e, |v| {
        let v = v.map_err(|e| format!("{e:?}"))?;
        buf.clear();
        write(&mut buf, &pp, 0, &v).map_err(|e| e.to_string())?;
        buf.push(b'\n');
        for &c in &buf { h = (h ^ c as u64).wrapping_mul(1099511628211); }
        nbytes += buf.len() as u64;
        nout += 1;
        if show { out.write_all(&buf).unwrap(); }
        Ok(())
    });
    if let Err(e) = r { eprintln!("jaq error: {e}"); std::process::exit(5); }
    out.flush().unwrap();
    println!("inputs {}\noutputs {}\nbytes {}\nfnv {}", nin.get(), nout, nbytes, h);
}
