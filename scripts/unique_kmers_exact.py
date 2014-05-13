#! /usr/bin/env python
#
# This file is part of khmer, http://github.com/ged-lab/khmer/, and is
# Copyright (C) Michigan State University, 2009-2014. It is licensed under
# the three-clause BSD license; see doc/LICENSE.txt. Contact: ctb@msu.edu
#
## Use a Python set to count unique kmers. This is very memory inneficient.

import string

import khmer
import sys
from screed.fasta import fasta_iter


filename = sys.argv[1]
K = int(sys.argv[2])  # size of kmer

TT = string.maketrans('ACGT', 'TGCA')

counter = set()

for n, record in enumerate(fasta_iter(open(filename))):
    sequence = record['sequence']
    seq_len = len(sequence)
    for n in range(0, seq_len + 1 - K):
        kmer = sequence[n:n + K]
        rc = kmer[::-1].translate(TT)

        if rc in counter:
            kmer = rc
        counter.add(kmer)

print 'Unique:', len(counter)
