#! /usr/bin/env python

import csv, random
import itertools

sentences = [ i for i in csv.reader(open('localizer_sentences.csv')) ]
pseudos = [ i for i in csv.reader(open('localizer_control.csv')) ]

for subj in range(32):
    random.shuffle(pseudos)
    random.shuffle(sentences)
    sequences = list(itertools.chain(*zip(sentences, pseudos)))
    fname = "loc_sub%03d.csv" % (subj+1)
    outf = csv.writer(open(fname, "w"))
    outf.writerows(sequences)

