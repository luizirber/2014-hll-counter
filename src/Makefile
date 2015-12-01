SHELL=/bin/bash
CXXFLAGS=-std=c++11 -Isparsehash/src

all: unique_kmers_sparsehash KmerStream

khmer_cpp/lib/Makefile:
	git clone https://github.com/dib-lab/khmer -b feature/kseq_parser khmer_cpp

sparsehash/src/google/sparse_hash_set:
	wget -c https://github.com/sparsehash/sparsehash/archive/sparsehash-2.0.3.tar.gz
	tar xf sparsehash-2.0.3.tar.gz
	mv sparsehash-sparsehash-2.0.3/ sparsehash
	rm sparsehash-2.0.3.tar.gz
	cd sparsehash && ./configure && make

build/lib/liboxli.a: khmer_cpp/lib/Makefile
	cd khmer_cpp/lib && \
	$(MAKE) PREFIX=${PWD}/build install all

unique_kmers_sparsehash: unique_kmers.o sparsehash/src/google/sparse_hash_set
	$(CXX) $(CXXFLAGS) $< -o $@ -static $(shell PKG_CONFIG_PATH=build/lib/pkgconfig pkg-config --libs oxli)

unique_kmers_hll: unique_kmers_hll.o
	$(CXX) $(CXXFLAGS) $< -o $@ -fopenmp $(shell PKG_CONFIG_PATH=build/lib/pkgconfig pkg-config --libs oxli)

unique_kmers%.o: unique_kmers%.cc build/lib/liboxli.a
	$(CXX) $(CXXFLAGS) $(shell PKG_CONFIG_PATH=build/lib/pkgconfig pkg-config --cflags oxli) -c $< -o $@

KmerStream:
	wget -c https://github.com/pmelsted/KmerStream/archive/v1.0.tar.gz
	tar xf v1.0.tar.gz
	rm v1.0.tar.gz
	cd KmerStream-1.0/ && make
	mv KmerStream-1.0/KmerStream .
	rm -rf KmerStream-1.0/

clean:
	cd khmer_cpp/lib && $(MAKE) clean;
	-rm *.o unique_kmers_sparsehash

.PHONY: clean
