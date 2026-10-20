enum E { Leaf, Name { t: E..&<u32 in pool> } }
var pool: E..[>..] = [];
var outs: i64[>..<] = [];
recursive fn ev(n: E.Leaf, x: i64) { outs.push(x); }
recursive fn ev(f: E.Name&, x: i64) { ev(f.t, x); outs.push(1); }
fn main() {
    let l .= pool.push(E.Leaf);
    let n .= pool.push(E.Name { t: l });
    ev(n, 7);
    print(outs.len);
}
