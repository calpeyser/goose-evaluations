// Ninja row: load build.ninja with Ninja's own parser and graph (libninja),
// then do the fixed work and print the checksum lines. See ../README.md.
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <string>
#include <vector>
#include <algorithm>

#include "disk_interface.h"
#include "graph.h"
#include "manifest_parser.h"
#include "state.h"

static uint64_t fnv1a(const std::string& s) {
  uint64_t h = 1469598103934665603ULL;
  for (unsigned char c : s) { h ^= c; h *= 1099511628211ULL; }
  return h;
}

// Longest chain of edges below n. The memo is Node::id_ (unused here:
// Ninja sets it only when it loads .ninja_deps). -1 = not seen, -2 = on stack.
static int Depth(Node* n) {
  int d = n->id();
  if (d >= 0) return d;
  if (d == -2) return 0;
  n->set_id(-2);
  int best = 0;
  if (Edge* e = n->in_edge()) {
    for (Node* in : e->inputs_) best = std::max(best, Depth(in) + 1);
    if (e->inputs_.empty()) best = 1;
  }
  n->set_id(best);
  return best;
}

int main(int argc, char** argv) {
  const char* file = argc > 1 ? argv[1] : "build.ninja";
  State state;
  RealDiskInterface disk;
  ManifestParser parser(&state, &disk);
  std::string err;
  if (!parser.Load(file, &err)) { fprintf(stderr, "ninja_harness: %s\n", err.c_str()); return 1; }

  const std::vector<Edge*>& edges = state.edges_;
  // "load" as the second argument: stop after loading (print the counts only).
  bool load_only = argc > 2 && std::string(argv[2]) == "load";
  if (load_only) {
    printf("%llu %llu\n", (unsigned long long)state.paths_.size(), (unsigned long long)edges.size());
    fflush(stdout);
    goto teardown;
  }
  {
  uint64_t nnodes = state.paths_.size(), nedges = edges.size();
  uint64_t ins = 0, outs = 0;
  for (Edge* e : edges) { ins += e->inputs_.size(); outs += e->outputs_.size(); }
  uint64_t path_hash = 0;
  for (auto& kv : state.paths_) path_hash += fnv1a(kv.second->path());

  uint64_t ncmd = 0, cmd_bytes = 0, cmd_hash = 0;
  for (Edge* e : edges) {
    std::string c = e->EvaluateCommand();
    if (c.empty()) continue;
    ncmd++; cmd_bytes += c.size(); cmd_hash += fnv1a(c);
  }

  uint64_t x = 88172645463325252ULL, fanin = 0, fanout = 0;
  for (int q = 0; q < 100000; q++) {
    x ^= x << 13; x ^= x >> 7; x ^= x << 17;
    const std::string& t = edges[x % nedges]->outputs_[0]->path();
    Node* n = state.LookupNode(t);
    fanin += n->in_edge()->inputs_.size();
    fanout += n->out_edges().size();
  }

  uint64_t sources = 0, maxd = 0, sumd = 0;
  for (auto& kv : state.paths_) {
    Node* n = kv.second;
    if (!n->in_edge()) sources++;
    uint64_t d = Depth(n);
    maxd = std::max(maxd, d); sumd += d;
  }

  printf("%llu %llu\n%llu %llu\n%llu\n%llu %llu %llu\n%llu %llu\n%llu %llu %llu\n",
         (unsigned long long)nnodes, (unsigned long long)nedges,
         (unsigned long long)ins, (unsigned long long)outs,
         (unsigned long long)path_hash,
         (unsigned long long)ncmd, (unsigned long long)cmd_bytes, (unsigned long long)cmd_hash,
         (unsigned long long)fanin, (unsigned long long)fanout,
         (unsigned long long)sources, (unsigned long long)maxd, (unsigned long long)sumd);
  fflush(stdout);
  }

teardown:
  // Teardown inside the timed region, as Goose's suite asks. Ninja itself
  // exits without freeing its graph; NO_TEARDOWN=1 measures that.
  if (!getenv("NO_TEARDOWN")) {
    for (Edge* e : edges) { if (e->env_ != &state.bindings_) delete e->env_; delete e; }
    for (auto& kv : state.paths_) delete kv.second;
    state.edges_.clear();
    state.paths_.clear();
  }
  return 0;
}
