#include <iostream>
#include <google/sparse_hash_set>

#include "khmer.hh"
#include "kmer_hash.hh"
#include "read_parsers.hh"
#include "MurmurHash3.h"

using google::sparse_hash_set;      // namespace where class lives by default

template<typename T>
struct MurmurHash {
    size_t operator()(const T& t) const {
        khmer::HashIntoType out[2];
        MurmurHash3_x64_128(&t, sizeof(t), 0, &out);
        return out[0];
    }
};

template<>
struct MurmurHash<std::string> {
    size_t operator()(const std::string& t) const {
        khmer::HashIntoType result;
        result = khmer::_hash_murmur(t);
        return result;
    }
};

bool cmp_revcomp(const std::string k1, const std::string k2)
{
    if (k1.size() != k2.size())
        return false;
    int ksize = k1.size();

    for (int i=0; i < ksize; ++i) {
      char complement = '\0';

      switch(k1[i]) {
        case 'A':
          complement = 'T';
          break;
        case 'C':
          complement = 'G';
          break;
        case 'G':
          complement = 'C';
          break;
        case 'T':
          complement = 'A';
          break;
        default:
          //complement = k1[i];
          break;
      }
      if (k2[ksize - i - 1] != complement)
        return false;
    }
    return true;
}

struct eqkmer
{
  bool operator()(const std::string s1, const std::string s2) const
  {
    return (s1 == s2) || (cmp_revcomp(s1, s2));
  }
};

int main(int argc, char** argv) {
  std::string filename = argv[1];
  uint K = atoi(argv[2]);
  sparse_hash_set<std::string, MurmurHash<std::string>, eqkmer> Set;

  khmer::read_parsers::Read read;
  khmer::read_parsers::IParser * parser = khmer::read_parsers::IParser::get_parser(filename);
  std::string kmer = "";

  while (!parser->is_complete()) {
    try {
      read = parser->get_next_read();
      kmer = "";

      for(auto & c : read.sequence) {
          if (c == 'N') c = 'A';
          kmer.push_back(c);
          if (kmer.size() < K) {
              continue;
          }
          Set.insert(kmer);

          kmer.erase(0, 1);
      }
    } catch (khmer::read_parsers::NoMoreReadsAvailable) {
    }
  }

  std::cout << Set.size() << std::endl;

  return 0;
}
