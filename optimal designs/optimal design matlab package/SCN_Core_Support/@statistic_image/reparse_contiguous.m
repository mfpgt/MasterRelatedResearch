function obj = reparse_contiguous(obj, varargin)
% obj = reparse_contiguous(obj, ['nonempty'])
%
% Re-construct list of contiguous voxels in an image based on in-image
% voxel coordinates.  Coordinates are taken from obj.volInfo.xyzlist.
% Results are saved in obj.volInfo.cluster.
% xyzlist can be generated from iimg_read_img, and is done automatically by
% object-oriented fMRI image classes (fmri_image, image_vector,
% statistic_image)
%
% If 'nonempty' is entered as an optional argument, will use only voxels
% that are non-zero, non-nan in the first column of obj.dat.
%
% The statistic_image object version of reparse_contiguous uses 
% the significance of the first image in the object (obj.sig(:, 1)) as a
% filter as well, so clustering will be based on the latest threshold applied.
% it is not usually necessary to enter 'nonempty'.
%
% Examples:
% ----------------------------------------
% Given timg, a statistic_image object:
% test = reparse_contiguous(timg, 'nonempty');
% cl = region(test, 'contiguous_regions');
% cluster_orthviews(cl, 'unique')
%
% copyright tor wager, 2011

wh = true(size(obj.volInfo.cluster));   %obj.volInfo.wh_inmask;
obj.volInfo(1).cluster = zeros(size(wh));

obj = replace_empty(obj);

% restrict to voxels with actual data if desired
if any(strcmp(varargin, 'nonempty'))
        
    wh = obj.dat(:, 1) ~= 0 & ~isnan(obj.dat);
    
end

% 6/22/13 Tor Added to enforce consistency in objects across usage cases
if isempty(obj.sig) || (numel(obj.sig) == 1 && ~obj.sig)
    obj.sig = true(size(obj.dat));
end

% .cluster can be either the size of a reduced, in-mask dataset after removing empties
% or the size of the full in-mask dataset that defined the image
% (volInfo.nvox).  We have to switch behavior according to which it is.
if size(obj.volInfo(1).cluster, 1) == size(obj.volInfo(1).xyzlist, 1)

    newcl = spm_clusters(obj.volInfo(1).xyzlist')';
    obj.volInfo(1).cluster = newcl;
    
    %wh = logical(obj.sig(:, 1)); < 6/22/13 THIS LINE UNNECESSARY

else % full in-mask -- assign to correct voxels
    wh = wh & logical(obj.sig(:, 1));

    obj.volInfo(1).cluster(wh) = spm_clusters(obj.volInfo(1).xyzlist(wh, :)')';
end

obj = remove_empty(obj);

end



