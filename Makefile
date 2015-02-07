INPUT=inputs/Gallus_3.longest25.fasta
THREADS=01 02 04 08 16 32
REPLICATES=$(shell seq -w 1 30)
TIMING_CMD=/usr/bin/time -v

all:

install-dependencies:
	pip install -r requirements.txt

benchmarks/just-io: $(foreach r,$(REPLICATES),\
                       $(subst REP,$r,benchmarks/just-io_rREP))

benchmarks/unique-kmers: $(foreach r,$(REPLICATES),\
                            $(foreach t,$(THREADS),\
                               $(subst REP,$r,\
					              $(subst THREAD,$t,benchmarks/unique-kmers_rREPtTHREAD))))

benchmarks/just-io_%: scripts/just-io.py
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ $< ${INPUT}

benchmarks/unique-kmers_%: scripts/unique-kmers.py
	mkdir -p ${@D}
	${TIMING_CMD} --output $@ -- env OMP_NUM_THREADS=$(shell echo $* | cut -d 't' -f2) $< -e 0.01 -k 32 ${INPUT}
