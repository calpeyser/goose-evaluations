// reserve_then_parse.cpp <file>: rapidyaml's bm_ryml_yaml_inplace_reserve, but with the reserve inside the
// timed region. Median of 21 of: new Tree, reserve(1.5 * estimate), parse_in_place; also the reserve alone.
#include <ryml.hpp>
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>
int main(int argc, char **argv) {
    std::ifstream f(argv[1], std::ios::binary); std::stringstream ss; ss << f.rdbuf(); const std::string text = ss.str();
    const ryml::id_type cap = (3 * ryml::estimate_tree_capacity(ryml::csubstr(text.data(), text.size()))) >> 1; // as bm_parse.cpp
    std::vector<double> total, reserve_only;
    for(int r = 0; r < 21; ++r) {
        std::string copy = text; // parse_in_place mutates
        auto t0 = std::chrono::steady_clock::now();
        ryml::Tree tree;
        tree.reserve(cap);
        auto t1 = std::chrono::steady_clock::now();
        ryml::parse_in_place(ryml::substr(&copy[0], copy.size()), &tree);
        auto t2 = std::chrono::steady_clock::now();
        total.push_back(std::chrono::duration<double, std::milli>(t2 - t0).count());
        reserve_only.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
    }
    std::sort(total.begin(), total.end()); std::sort(reserve_only.begin(), reserve_only.end());
    printf("reserve %.2f ms + parse = %.2f ms (medians of 21)\n", reserve_only[10], total[10]);
}
