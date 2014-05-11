# /usr/bin/env python
# Time-stamp: <2011-03-24 12:30:26 pallier>

# converts a csv file into python code
# example:
# csv2py('listes/suj01_sess01.dat','outvar.py')
# from outvar import *


def csv2py(csvfile, pyfile, sep=""):
    f = file(csvfile)
    lines = f.readlines()

    f = open(pyfile,'w')
    f.write("# generated from " + csvfile + " by read_csv.csv2py\n\n")
# process columns names
    if sep=="":
	colnames = lines[0].rstrip().split()
    else:
	colnames = lines[0].rstrip().split(sep)

    f.write("varnames = " + str(colnames) + "\n") 
    ncols = len(colnames)
    x = {}
    for i in range(ncols):
        x[colnames[i]] = []

    f.write("row = []\n")
    nrows = len(lines) 
    for l in range(1,nrows):
        h0 = lines[l].rstrip()
	if sep=="":
		h = h0.split()
	else:
		h = h0.split(sep)
        if (len(h)) != ncols:
            print "Error: line ", l+1, " does not contain ", nrows, "elements"
            break
        f.write("row.append(" + str(h) + ")\n")
        for icol in range(len(colnames)):
            x[colnames[icol]].append(h[icol])

    for col in colnames:
        try:
            x[col] = map(int,x[col])
        except ValueError:
            pass
        expr = "\n%s = %s\n" % (col , x[col])
        f.write(expr)
        


