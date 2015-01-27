#! /usr/bin/env python2

import sys

import khmer


p = khmer.ReadParser(sys.argv[1])
for read in p:
    pass
