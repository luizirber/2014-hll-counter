INPUT=inputs/SRR1304364_1.fastq
INPUT_URL=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR130/004/SRR1304364/SRR1304364_1.fastq.gz
THREADS=01 02 04 08 16 32
THREADS=32 16 08 04 02 01
REPLICATES=$(shell seq -w 1 3)
TIMING_CMD=/usr/bin/time -v

all:

install-dependencies:
	pip install -r requirements.txt

benchmarks/just-io: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/just-io_rREP))

benchmarks/unique-kmers: \
	$(foreach r,$(REPLICATES),\
        $(foreach t,$(THREADS),\
            $(subst REP,$r,\
				$(subst THREAD,$t,benchmarks/unique-kmers_rREPtTHREAD))))

benchmarks/streaming_just-io: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/streaming_just-io_rREP))

benchmarks/streaming_unique-kmers: \
	$(foreach r,$(REPLICATES),\
        $(foreach t,$(THREADS),\
            $(subst REP,$r,\
			    $(subst THREAD,$t,benchmarks/streaming_unique-kmers_rREPtTHREAD))))

benchmarks/exact-py: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/exact-py_rREP))

benchmarks/exact-sparsehash: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/exact-sparsehash_rREP))

#############################################################################

benchmarks/just-io_%: scripts/just-io.py
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT}

benchmarks/unique-kmers_%:
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=$(shell echo $* | cut -d 't' -f2) \
       unique-kmers.py -e 0.01 -k 32 ${INPUT}

#############################################################################

benchmarks/streaming_unique-kmers_%:
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=$(shell echo $* | cut -d 't' -f2) \
	    curl ${INPUT_URL} | unique-kmers.py -e 0.01 -k 32 -

benchmarks/streaming_just-io_%:
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=$(shell echo $* | cut -d 't' -f2) \
	    curl ${INPUT_URL} > /dev/null

#############################################################################

benchmarks/exact-py_%: scripts/unique_kmers_exact.py
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT} 32

benchmarks/exact-sparsehash_%: src/unique_kmers_sparsehash
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT} 32

#############################################################################

src/unique_kmers_sparsehash: src/unique_kmers.cc
	cd src && \
	  $(MAKE) unique_kmers_sparsehash

inputs/SRR1304364_1.fastq:
	mkdir -p $(@D)
	curl ${INPUT_URL} | gunzip -c > $@
