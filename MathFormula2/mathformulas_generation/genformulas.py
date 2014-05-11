#! /usr/bin/env python
# Time-stamp: <2014-03-24 11:02 christophe@pallier.org>

# Generation of math formulas following templates

import random

V = ['x', 'y', 'z', '\\alpha', '\\beta' ]

U = ['\\sin(%s)', '\\cos(%s)', '\\ln(%s)' ]

B = ['%s + %s', '%s - %s', '%s . %s', '(%s + %s)', '(%s - %s)', '(%s . %s)' ]

def generate_U():
    for f in U:
        for v in V:
            yield(f % v)
            
def generate_B():
    for f in B:
        for v1 in V:
            for v2 in V:
                if v1==v2:
                    continue
                yield(f % (v1, v2))

def generate_UB(): 
    for f1 in U:
        for f2 in generate_B():
            yield(f1 % f2)

def generate_BUr():
    for f1 in B:
        for v in V:
            for f2 in generate_U():
                if f2.find(v) > 0:
                    continue
                yield(f1 % (v, f2))

def generate_BUl():
    for f1 in B:
        for v in V:
            for f2 in generate_U():
                if f2.find(v) > 0:
                    continue
                yield(f1 % (f2, v))

def generate_UU():
    for f1 in U:
        for f2 in U:
            if f2==f1:
                continue
            for v in V:
                yield(f1 % (f2 % v))


def generate_BBr():
# bug: operator precedence, ambiguity...
    for f1 in B:
        for f2 in B:
            if f1==f2:
                continue
            for v1 in V:
                for v2 in V:
                    for v3 in V:
                        if (v1==v2) | (v1==v3) | (v2==v3):
                            continue
                        yield(f1 % (v1, f2 % (v2, v3)))




set_U = [x for x in generate_U() ]

set_B = [x for x in generate_B() ]

set_UU = [x for x in generate_UU() ]

set_BB = [x for x in generate_BBr() ]

set_UB = [x for x in generate_UB() ]

set_BU = [x for x in generate_BUr() ]
set_BU = set_BU + [x for x in generate_BUl() ]

def save_formulas(set, fname):
    fout = open(fname, 'w')
    for f in set: 
        fout.write('$ %s $\n' % f)
    fout.close()
    
    latexcmd = '''\\documentclass[12pt]{article}
    \\DeclareMathSizes{12}{20}{14}{10}
    \\everymath{\displaystyle}
    \\begin{document}
    \\input %s
    \\end{document}''' % fname
    fname2 = 'create_%s' % fname
    fout2 = open(fname2, 'w')
    fout2.write(latexcmd)
    fout2.close()
    from subprocess import call
    call(["/usr/bin/pdflatex", fname2 ])
    call(["/usr/bin/latex2html", fname2 ])


save_formulas(set_U, 'fU.tex')
save_formulas(set_B, 'fB.tex')
save_formulas(set_UU, 'fUU.tex')
save_formulas(set_BB, 'fBB.tex')
save_formulas(set_BU, 'fBU.tex')
save_formulas(set_UB, 'fUB.tex')






                
    

