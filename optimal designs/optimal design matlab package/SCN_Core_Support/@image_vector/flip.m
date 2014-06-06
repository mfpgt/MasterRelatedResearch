function dat = flip(dat, varargin)
% Flips an image_vector object left to right
%
% Optional: input 'mirror' to make a symmetrical image, averaging the left
% and right hemispheres
%
% dat = flip(dat, ['mirror'])
%
% tor. may 2012


vdat = reconstruct_image(dat);

for i = 1:size(vdat, 3)
    slice = vdat(:, :, i);
    slice = flipdim(slice, 1);
    vdat(:, :, i) = slice;
end

vdat = vdat(:);
vdat = vdat(dat.volInfo.image_indx);

if length(varargin) > 0 && strcmp(varargin{1}, 'mirror')
    
    % mirror
    dat.dat = (dat.dat + vdat) ./ 2;
else
    
    % flip
    dat.dat = vdat;
    
end

end

