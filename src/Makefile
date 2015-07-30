SHELL=/bin/bash
CXXFLAGS=--std=c++11

all: unique_kmers_sparsehash

khmer/lib/Makefile:
	git clone https://github.com/dib-lab/khmer

build/lib/libkhmer.a: khmer/lib/Makefile
	cd khmer/lib && \
	$(MAKE) PREFIX=${PWD}/build install all

unique_kmers_sparsehash: unique_kmers.o build/lib/libkhmer.a
	$(CXX) $(CXXFLAGS) $< -o $@ --static $(shell PKG_CONFIG_PATH=build/lib/pkgconfig pkg-config --libs khmer)

unique_kmers.o: unique_kmers.cc
	$(CXX) $(CXXFLAGS) $(shell PKG_CONFIG_PATH=build/lib/pkgconfig pkg-config --cflags khmer) -c $< -o $@

clean:
	cd khmer/lib && $(MAKE) clean;
	-rm *.o unique_kmers_sparsehash

.PHONY: clean
