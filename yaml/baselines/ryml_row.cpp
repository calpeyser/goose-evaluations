// Expert row: rapidyaml, parsed in place (scalars are views into the input buffer).
#include <ryml.hpp>
#include "harness.h"

static void walk(const ryml::Tree &t, ryml::id_type id, Counts &c, std::string &out) {
    if (t.is_map(id)) {
        c.maps++; out.push_back('{');
        for (ryml::id_type ch = t.first_child(id); ch != ryml::NONE; ch = t.next_sibling(ch)) {
            if (ch != t.first_child(id)) out.push_back(',');
            c.keys++;
            if (t.key_is_null(ch)) out.append("null", 4);
            else { ryml::csubstr k = t.key(ch); c.bytes += k.len; emit_str(out, k.str, k.len); }
            out.push_back(':');
            walk(t, ch, c, out);
        }
        out.push_back('}');
    } else if (t.is_seq(id)) {
        c.seqs++; out.push_back('[');
        for (ryml::id_type ch = t.first_child(id); ch != ryml::NONE; ch = t.next_sibling(ch)) {
            if (ch != t.first_child(id)) out.push_back(',');
            walk(t, ch, c, out);
        }
        out.push_back(']');
    } else {
        c.scalars++;
        if (t.val_is_null(id)) { c.nulls++; out.append("null", 4); }
        else { ryml::csubstr v = t.val(id); c.bytes += v.len; emit_str(out, v.str, v.len); }
    }
}

int main(int argc, char **argv) {
    long long t0 = now_ns();
    std::string text = read_all(argv[1]);
    std::string out;
    Counts c;
    long long t1 = now_ns(), t2, t3, t4;
    {
        ryml::substr src(&text[0], text.size());
#ifdef RESERVE
        // Expert+: size the node array up front from rapidyaml's own estimate.
        auto *tp = new ryml::Tree(ryml::estimate_tree_capacity(src));
        ryml::parse_in_place(src, tp);
#else
        auto *tp = new ryml::Tree(ryml::parse_in_place(src));
#endif
        ryml::Tree &t = *tp;
        t2 = now_ns();
        if (getenv("ROW_INFO")) fprintf(stderr, "nodes %zu capacity %zu sizeof(NodeData) %zu arena %zu\n", (size_t)t.size(), (size_t)t.capacity(), sizeof(ryml::NodeData), (size_t)t.arena_capacity());
        ryml::id_type root = t.root_id();
        if (t.is_stream(root)) {
            for (ryml::id_type d = t.first_child(root); d != ryml::NONE; d = t.next_sibling(d)) {
                c.docs++; walk(t, d, c, out); out.push_back('\n');
            }
        } else { c.docs++; walk(t, root, c, out); out.push_back('\n'); }
        t3 = now_ns();
        delete tp;
        t4 = now_ns();
    }
    if (argc > 2) { FILE *f = fopen(argv[2], "wb"); fwrite(out.data(), 1, out.size(), f); fclose(f); }
    print_counts(c, out);
    phases(t0, t1, t2, t3, t4, now_ns());
}
