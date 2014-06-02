/* @(#)spm_make_lookup.h	2.2 03/05/12
*/

void make_lookup_poly(double coord, int q, int dim, int *d1,
	double *table, double **ptpend);
void make_lookup_poly_grad(double coord, int q, int dim, int *d1,
	double *table, double *dtable, double **ptpend);
void make_lookup_sinc(double coord, int q, int dim, int *d1,
	double *table, double **ptpend);
void make_lookup_sinc_grad(double coord, int q, int dim, int *d1,
	double *table, double *dtable, double **ptpend);
