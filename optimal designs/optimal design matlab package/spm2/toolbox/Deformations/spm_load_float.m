function dat = spm_load_float(V)
% Load a volume into a floating point array
% FORMAT dat = spm_load_float(V)
% V   - handle from spm_vol
% dat - a 3D floating point array
%_______________________________________________________________________
% @(#)spm_load_float.m	1.1 John Ashburner 02/08/12

dim = V(1).dim(1:3);
dat = single(0);
dat(dim(1),dim(2),dim(3))=0;
for i=1:V(1).dim(3),
	M = spm_matrix([0 0 i]);
	dat(:,:,i) = single(spm_slice_vol(V(1),M,dim(1:2),1));
end;
return;
