SHELL=/bin/bash
CXXFLAGS=-std=c++11 -Isparsehash/src

all: unique_kmers_sparsehash

khmer/lib/Makefile:
	git clone https://github.com/dib-lab/khmer -b feature/kseq_parser

sparsehash/src/google/sparse_hash_set:
	wget -c https://github.com/sparsehash/sparsehash/archive/sparsehash-2.0.3.tar.gz
	tar xf sparsehash-2.0.3.tar.gz
	mv sparsehash-sparsehash-2.0.3/ sparsehash
	rm sparsehash-2.0.3.tar.gz
	cd sparsehash && ./configure && make

build/lib/liboxli.a: khmer/lib/Makefile
	cd khmer/lib && \
	$(MAKE) PREFIX=${PWD}/build install all

unique_kmers_sparsehash: unique_kmers.o sparsehash/src/google/sparse_hash_set
	$(CXX) $(CXXFLAGS) $< -o $@ --static $(shell PKG_CONFIG_PATH=build/lib/pkgconfig pkg-config --libs oxli)

unique_kmers.o: unique_kmers.cc build/lib/liboxli.a
	$(CXX) $(CXXFLAGS) $(shell PKG_CONFIG_PATH=build/lib/pkgconfig pkg-config --cflags oxli) -c $< -o $@

clean:
	cd khmer/lib && $(MAKE) clean;
	-rm *.o unique_kmers_sparsehash

.PHONY: clean
