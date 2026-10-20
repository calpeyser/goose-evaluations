// Idiomatic row: yaml-cpp's own DOM (YAML::LoadAll -> YAML::Node trees).
#include <yaml-cpp/yaml.h>
#include "harness.h"

static void walk(const YAML::Node &n, Counts &c, std::string &out) {
    switch (n.Type()) {
    case YAML::NodeType::Null: c.scalars++; c.nulls++; out.append("null", 4); break;
    case YAML::NodeType::Scalar: {
        const std::string &s = n.Scalar();
        c.scalars++; c.bytes += s.size(); emit_str(out, s.data(), s.size()); break;
    }
    case YAML::NodeType::Sequence: {
        c.seqs++; out.push_back('[');
        bool first = true;
        for (const auto &e : n) { if (!first) out.push_back(','); first = false; walk(e, c, out); }
        out.push_back(']'); break;
    }
    case YAML::NodeType::Map: {
        c.maps++; out.push_back('{');
        bool first = true;
        for (const auto &kv : n) {
            if (!first) out.push_back(','); first = false;
            c.keys++;
            if (kv.first.IsNull()) out.append("null", 4);
            else { const std::string &k = kv.first.Scalar(); c.bytes += k.size(); emit_str(out, k.data(), k.size()); }
            out.push_back(':');
            walk(kv.second, c, out);
        }
        out.push_back('}'); break;
    }
    default: break;
    }
}

int main(int argc, char **argv) {
    long long t0 = now_ns();
    std::string text = read_all(argv[1]);
    std::string out;
    Counts c;
    long long t1 = now_ns();
    auto *docs = new std::vector<YAML::Node>(YAML::LoadAll(text));
    long long t2 = now_ns();
    for (const auto &d : *docs) { c.docs++; walk(d, c, out); out.push_back('\n'); }
    long long t3 = now_ns();
    delete docs;  // teardown of every node, inside the timed process
    long long t4 = now_ns();
    if (argc > 2) { FILE *f = fopen(argv[2], "wb"); fwrite(out.data(), 1, out.size(), f); fclose(f); }
    print_counts(c, out);
    phases(t0, t1, t2, t3, t4, now_ns());
}
