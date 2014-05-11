#! /bin/bash
# Random selection of a few formulas

ls chris_formulas/create_fU/*.png | shuffle.pl  -n 10  > formulas_chris.csv
ls chris_formulas/create_fB/*.png | shuffle.pl  -n 10  >> formulas_chris.csv
ls chris_formulas/create_fUU/*.png | shuffle.pl  -n 10 >> formulas_chris.csv
ls chris_formulas/create_fBB/*.png | shuffle.pl  -n 10 >> formulas_chris.csv
ls chris_formulas/create_fBU/*.png | shuffle.pl  -n 10 >> formulas_chris.csv
ls chris_formulas/create_fUB/*.png | shuffle.pl  -n 10 >> formulas_chris.csv
