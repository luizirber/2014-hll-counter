#! /usr/bin/env python
#
# This file is part of khmer, http://github.com/ged-lab/khmer/, and is
# Copyright (C) Michigan State University, 2009-2014. It is licensed under
# the three-clause BSD license; see doc/LICENSE.txt. Contact: ctb@msu.edu
#
## Use a Python set to count unique kmers. This is very memory inneficient.

from __future__ import print_function

import string

import khmer
import sys
import screed


filename = sys.argv[1]
K = int(sys.argv[2])  # size of kmer

TRANSLATE = {'A': 'T', 'C': 'G', 'T': 'A', 'G': 'C'}

counter = set()

with screed.open(filename) as f:
    for n, record in enumerate(f):
        sequence = record['sequence']
        seq_len = len(sequence)
        for n in range(0, seq_len + 1 - K):
            kmer = sequence[n:n + K].replace('N', 'A')
            rc = "".join(TRANSLATE[c] for c in kmer[::-1])

            if rc in counter:
                kmer = rc
            counter.add(kmer)

print('Unique:', len(counter))
