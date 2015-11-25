#! /usr/bin/env python

import sys

import khmer


p = khmer.ReadParser(sys.argv[1], sys.argv[2])
for read in p:
    pass
