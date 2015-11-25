INPUT=inputs/SRR1304364_1.fastq
INPUT_URL=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR130/004/SRR1304364/SRR1304364_1.fastq.gz

INPUT_MEDIUM=inputs/SRR1216679_1.fastq
INPUT_MEDIUM_URL=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR121/009/SRR1216679/SRR1216679_1.fastq.gz

INPUT_SMALL=inputs/SRR797943.fastq
INPUT_SMALL_URL=ftp://ftp.sra.ebi.ac.uk/vol1/fastq/SRR797/SRR797943/SRR797943.fastq.gz


THREADS=32 16 08 04 02 01
REPLICATES=$(shell seq -w 01 10)
TIMING_CMD=/usr/bin/time -v

all: benchmarks/unique-kmers-kseq benchmarks/unique-kmers-seqan \
	 benchmarks/just-io-kseq benchmarks/just-io-seqan \
	 benchmarks/streaming_unique-kmers benchmarks/streaming_just-io \
	 benchmarks/exact-py-small benchmarks/exact-sparsehash-small \
	 benchmarks/exact-py-medium benchmarks/exact-sparsehash-medium \
	 benchmarks/hll-small benchmarks/hll-medium \
	 benchmarks/kmerstrem

install-dependencies:
	pip install -r requirements.txt

#############################################################################

benchmarks/just-io-kseq: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/just-io-kseq_rREP))

benchmarks/just-io-seqan: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/just-io-seqan_rREP))

benchmarks/kmerstream: \
	$(foreach r,$(REPLICATES),\
        $(foreach t,$(THREADS),\
            $(subst REP,$r,\
				$(subst THREAD,$t,benchmarks/kmerstream_rREPtTHREAD))))

benchmarks/unique-kmers: \
	$(foreach r,$(REPLICATES),\
        $(foreach t,$(THREADS),\
            $(subst REP,$r,\
				$(subst THREAD,$t,benchmarks/unique-kmers_rREPtTHREAD))))

#############################################################################

benchmarks/streaming_just-io: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/streaming_just-io_rREP))

benchmarks/streaming_unique-kmers: \
	$(foreach r,$(REPLICATES),\
        $(foreach t,$(THREADS),\
            $(subst REP,$r,\
			    $(subst THREAD,$t,benchmarks/streaming_unique-kmers_rREPtTHREAD))))

#############################################################################

benchmarks/exact-py-small: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/exact-py-small_rREP))

benchmarks/exact-sparsehash-small: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/exact-sparsehash-small_rREP))

benchmarks/hll-small: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/hll-small_rREP))

#############################################################################

benchmarks/exact-py-medium: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/exact-py-medium_rREP))

benchmarks/exact-sparsehash-medium: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/exact-sparsehash-medium_rREP))

benchmarks/hll-medium: \
	$(foreach r,$(REPLICATES),\
        $(subst REP,$r,benchmarks/hll-medium_rREP))

#############################################################################

benchmarks/just-io-kseq_%: scripts/just-io.py ${INPUT}
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT} kseq

benchmarks/just-io-seqan_%: scripts/just-io.py ${INPUT}
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT} seqan

benchmarks/unique-kmers-seqan_%: ${INPUT}
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=$(shell echo $* | cut -d 't' -f2) \
       unique-kmers.py -r seqan -e 0.01 -k 32 ${INPUT}

benchmarks/unique-kmers-kseq_%: ${INPUT}
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=$(shell echo $* | cut -d 't' -f2) \
       unique-kmers.py -r kseq -e 0.01 -k 32 ${INPUT}

benchmarks/kmerstream_%: ${INPUT}
	mkdir -p ${@D}
	mkdir -p out
	${TIMING_CMD} --output $@ -- KmerStream -e 0.01 -k 32 -s 1 \
		-t $(shell echo $* | cut -d 't' -f2) -o out/${@F} ${INPUT}

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

benchmarks/exact-py-medium_%: scripts/unique_kmers_exact.py $(INPUT_MEDIUM)
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT_MEDIUM} 32

benchmarks/exact-sparsehash-medium_%: src/unique_kmers_sparsehash $(INPUT_MEDIUM)
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT_MEDIUM} 32

benchmarks/hll-medium_%: $(INPUT_MEDIUM)
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=16 \
	    unique-kmers.py -e 0.01 -k 32 $<

#############################################################################

benchmarks/exact-py-small_%: scripts/unique_kmers_exact.py $(INPUT_SMALL)
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT_SMALL} 32

benchmarks/exact-sparsehash-small_%: src/unique_kmers_sparsehash $(INPUT_SMALL)
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT_SMALL} 32

benchmarks/hll-small_%: $(INPUT_SMALL)
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=16 \
	    unique-kmers.py -e 0.01 -k 32 $<

#############################################################################

src/unique_kmers_sparsehash: src/unique_kmers.cc
	cd src && \
	  $(MAKE) unique_kmers_sparsehash

#############################################################################

$(INPUT):
	mkdir -p $(@D)
	curl ${INPUT_URL} | gunzip -c > $@

$(INPUT_SMALL):
	mkdir -p $(@D)
	curl ${INPUT_SMALL_URL} | gunzip -c > $@

$(INPUT_MEDIUM):
	mkdir -p $(@D)
	curl ${INPUT_SMALL_URL} | gunzip -c > $@
