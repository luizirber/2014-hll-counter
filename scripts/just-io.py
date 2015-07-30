#! /usr/bin/env python

import sys

import khmer


p = khmer.ReadParser(sys.argv[1])
for read in p:
    pass
