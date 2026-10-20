// n2 row: load build.ninja with n2's own loader (n2::load::Loader, which also
// evaluates every command), then do the fixed work and print the checksum
// lines. See ../../README.md. n2 keeps its graph module private, so the ids
// are reached through public fields and converted with transmute: FileId and
// BuildId are both `struct X(u32)`.
use std::path::PathBuf;

fn fnv1a(s: &[u8]) -> u64 {
    let mut h: u64 = 1469598103934665603;
    for &c in s {
        h ^= c as u64;
        h = h.wrapping_mul(1099511628211);
    }
    h
}

fn idx<T: Copy>(id: T) -> usize {
    assert_eq!(std::mem::size_of::<T>(), 4);
    unsafe { std::mem::transmute_copy::<T, u32>(&id) as usize }
}

fn main() {
    let file = std::env::args().nth(1).unwrap_or("build.ninja".to_string());
    let bytes = n2::scanner::read_file_with_nul(file.as_ref()).expect("read");
    let mut loader = n2::load::Loader::new();
    let mut parser = n2::parse::Parser::new(&bytes);
    loader
        .parse_with_parser(&mut parser, PathBuf::from(&file), &[])
        .expect("load");
    let g = &loader.graph;

    // n2 also makes a file for each `include`d manifest; Ninja does not. Count
    // only files that a build names, as Ninja's node table holds.
    let all_ids: Vec<_> = g.files.all_ids().collect();
    let named = |f| {
        let file = g.file(f);
        file.input.is_some() || !file.dependents.is_empty()
    };
    let nnodes = all_ids.iter().filter(|&&f| named(f)).count() as u64;
    let file_ids = &all_ids;
    // "load" as the second argument: stop after loading (print the counts only).
    if std::env::args().nth(2).as_deref() == Some("load") {
        println!("{} {}", nnodes, idx(g.builds.next_id()));
        return;
    }
    // BuildIds are dense from 0; make them from the first file's producer type.
    let nedges = idx(g.builds.next_id()) as u64;
    let build_id = |i: usize| {
        let mut b = g.builds.next_id();
        unsafe { *(&mut b as *mut _ as *mut u32) = i as u32 };
        b
    };

    let (mut ins, mut outs) = (0u64, 0u64);
    let (mut ncmd, mut cmd_bytes, mut cmd_hash) = (0u64, 0u64, 0u64);
    for i in 0..nedges as usize {
        let b = &g.builds[build_id(i)];
        ins += b.ordering_ins().len() as u64;
        outs += b.outs().len() as u64;
        if let Some(c) = &b.cmdline {
            if !c.is_empty() {
                ncmd += 1;
                cmd_bytes += c.len() as u64;
                cmd_hash = cmd_hash.wrapping_add(fnv1a(c.as_bytes()));
            }
        }
    }
    let mut path_hash = 0u64;
    for &f in file_ids.iter().filter(|&&f| named(f)) {
        path_hash = path_hash.wrapping_add(fnv1a(g.file(f).name.as_bytes()));
    }

    let mut x: u64 = 88172645463325252;
    let (mut fanin, mut fanout) = (0u64, 0u64);
    for _ in 0..100000 {
        x ^= x << 13;
        x ^= x >> 7;
        x ^= x << 17;
        let b = &g.builds[build_id((x % nedges) as usize)];
        let t = &g.file(b.outs()[0]).name;
        let f = g.files.lookup(t).unwrap();
        let file = g.file(f);
        fanin += g.builds[file.input.unwrap()].ordering_ins().len() as u64;
        fanout += file.dependents.len() as u64;
    }

    // Longest chain of builds below each file; iterative, memo by FileId.
    let mut depth: Vec<i32> = vec![-1; all_ids.len()];
    let (mut sources, mut maxd, mut sumd) = (0u64, 0u64, 0u64);
    let mut stack: Vec<(usize, bool)> = Vec::new();
    for &f in file_ids.iter().filter(|&&f| named(f)) {
        if g.file(f).input.is_none() {
            sources += 1;
        }
        stack.push((idx(f), false));
        while let Some((n, expanded)) = stack.pop() {
            if !expanded && depth[n] != -1 {
                continue;
            }
            let fid = file_ids[n];
            let input = g.file(fid).input;
            match input {
                None => depth[n] = 0,
                Some(bid) => {
                    let b = &g.builds[bid];
                    if expanded {
                        let mut best = 0;
                        for &i in b.ordering_ins() {
                            best = best.max(depth[idx(i)].max(0) + 1);
                        }
                        if b.ordering_ins().is_empty() {
                            best = 1;
                        }
                        depth[n] = best;
                    } else {
                        depth[n] = -2;
                        stack.push((n, true));
                        for &i in b.ordering_ins() {
                            if depth[idx(i)] == -1 {
                                stack.push((idx(i), false));
                            }
                        }
                    }
                }
            }
        }
        let d = depth[idx(f)] as u64;
        maxd = maxd.max(d);
        sumd += d;
    }

    println!("{} {}\n{} {}\n{}\n{} {} {}\n{} {}\n{} {} {}",
        nnodes, nedges, ins, outs, path_hash, ncmd, cmd_bytes, cmd_hash,
        fanin, fanout, sources, maxd, sumd);
    // The loader, its graph and the file bytes drop here: teardown is timed.
}
