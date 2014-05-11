#! /usr/bin/env python
# Time-stamp: <2014-02-11 14:34 christophe@pallier.org>

import random, sys
c = "bbbbccccddddffffggghhjjjjkkllllmmmnnnnppppqqqrrrrrsssssstttttvvvwxxz"


def pseudo(len):
    return "".join([ random.choice(c) for x in range(len) ])

if __name__ == '__main__':
    infile = file(sys.argv[1],'r',)
    for line in infile:
        lens = [ len(w) for w in line.split(",")]
        output = ",".join([ pseudo(i) for i in lens ])
        print(output)

