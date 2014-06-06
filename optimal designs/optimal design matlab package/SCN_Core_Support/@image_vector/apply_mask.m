function [dat, mask] = apply_mask(dat, mask, varargin)
% Apply a mask image (image filename or fmri_mask_image object) to an image_vector object
% stored in dat
%
% This can be used to:
% - Mask an image_vector or fmri_data object with a mask
% - Obtain "pattern expression" for a weight map (entered as the
%   mask, here) in a series of images stored in dat.
%
% The mask or weight map does not have to be in the same space as the dat;
% it will be resampled to the space of the data in dat.
%
% Optional inputs:
% 'pattern_expression' : calculate and return the cross-product of each
% image in dat and the values in the mask.
%
% 'ignore_missing': use with pattern expression only. Ignore weights on voxels
% with zero values in test image. If this is not entered, the function will
% check for these values and give a warning.
%
% [dat, mask] = apply_mask(dat, mask)
% [dat, mask] = apply_mask(dat, mask image name)
% [dat, mask] = apply_mask(dat, mask image vector object)
% [pattern_exp_values] = apply_mask(dat, weight map image, 'pattern_expression', 'ignore_missing')
%
% Last modified: 10/30/11 to add support for masks that are weight maps

% set options
dopatternexpression = 0;
donorm = 0;
doignoremissing = 0;

if any(strcmp(varargin, 'pattern_expression'))
    dopatternexpression = 1;
    
    if any(strcmp(varargin, 'ignore_missing'))
        doignoremissing = 1;
    end
    
end

if any(strcmp(varargin, 'norm_mask')) % only good for pattern expression
    donorm = 1;
end

% create mask_image object if we have a filename
if ischar(mask)
    mask = fmri_mask_image(mask);
end

isdiff = compare_space(dat, mask);

if isdiff == 1 || isdiff == 2 % diff space, not just diff voxels
    
    % Both work, but resample_space does not require going back to original
    % images on disk.
    %mask = resample_to_image_space(mask, dat);
    mask = resample_space(mask, dat);
    
    % tor added may 1 - removed voxels was not legal otherwise
    %mask.removed_voxels = mask.removed_voxels(mask.volInfo.wh_inmask);
    % resample_space is not *always* returning legal sizes for removed
    % vox? maybe this was updated to be legal
    if length(mask.removed_voxels) == mask.volInfo.nvox
        disp('Warning: resample_space returned illegal length for removed voxels. Fixing...');
        mask.removed_voxels = mask.removed_voxels(mask.volInfo.wh_inmask);
    end
    
end

dat = remove_empty(dat);
nonemptydat = ~dat.removed_voxels; % remove these

dat = replace_empty(dat);

% Check/remove NaNs. This could be done in-object...
mask.dat(isnan(mask.dat)) = 0;

% Replace if necessary
mask = replace_empty(mask);

% save which are in mask, but do not replace with logical, because mask may
% have weights we want to preserve
inmaskdat = logical(mask.dat);


% Remove out-of-mask voxels
% ---------------------------------------------------

% mask.dat has full list of voxels
% need vox in both mask and original data mask

if size(mask.volInfo.image_indx, 1) == size(dat.volInfo.image_indx, 1)
    n = size(mask.volInfo.image_indx, 1);
    
    if size(nonemptydat, 1) ~= n % should be all vox OR non-empty vox
        nonemptydat = zeroinsert(~dat.volInfo.image_indx, nonemptydat);
    end
    
    if size(inmaskdat, 1) ~= n
        inmaskdat = zeroinsert(~mask.volInfo.image_indx, inmaskdat);
    end
    
    inboth = inmaskdat & nonemptydat;
    
    % List in space of in-mask voxels in dat object.
    % Remove these from the dat object
    to_remove = ~inboth(dat.volInfo.wh_inmask);

    to_remove_mask = ~inboth(mask.volInfo.wh_inmask);

elseif size(mask.dat, 1) == size(dat.volInfo.image_indx, 1)
    
    % mask vox are same as total image vox
    nonemptydat = zeroinsert(~dat.volInfo.image_indx, nonemptydat);
    inboth = inmaskdat & dat.volInfo.image_indx & nonemptydat;

    % List in space of in-mask voxels in dat object.
    to_remove = ~inboth(dat.volInfo.wh_inmask);

    to_remove_mask = ~inboth(mask.volInfo.wh_inmask);

elseif size(mask.dat, 1) == size(dat.volInfo.wh_inmask, 1)
    % mask vox are same as in-mask voxels in dat
    inboth = inmaskdat & dat.volInfo.image_indx(dat.volInfo.wh_inmask) & nonemptydat;
    
    % List in space of in-mask voxels in .dat field.
    to_remove = ~inboth;
    
    to_remove_mask = ~inboth;

else
    fprintf('Sizes do not match!  Likely bug in resample_to_image_space.\n')
    fprintf('Vox in mask: %3.0f\n', size(mask.dat, 1))
    fprintf('Vox in dat - image volume: %3.0f\n', size(dat.volInfo.image_indx, 1));
    fprintf('Vox in dat - image in-mask area: %3.0f\n', size(dat.volInfo.wh_inmask, 1));
    disp('Stopping to debug');
    keyboard
end

dat = remove_empty(dat, to_remove);
mask = remove_empty(mask, to_remove_mask);

if dopatternexpression
    %mask = replace_empty(mask); % need for weights to match

    weights = double(mask.dat); % force double b/c of matlab instabilities
    
    dat.dat = double(dat.dat); % force double b/c of matlab instabilities
    
    if donorm, weights = weights ./ norm(weights); end
    
    % CHECK and weight
    % ---------------------------------------------------------
    inmask = weights ~= 0 & ~isnan(weights);
    badvals = sum(dat.dat(inmask, :) == 0);

    if ~any(badvals)
        %weights(to_remove_mask) = []; 
        dat = dat.dat' * weights;
    
    elseif doignoremissing
    
        for i = 1:size(dat.dat, 2)
            mydat = dat.dat(:, i);
            myweights = weights;
            myweights(mydat == 0 | isnan(mydat)) = 0;
            mypeval(i, 1) = mydat' * myweights;
            
        end
        
        dat = mypeval;
    
    else
        
        disp('WARNING!!! SOME SUBJECTS HAVE ZERO VALUES WITHIN WEIGHT MASK.');
        disp('This could artifactually influence their scores if these 0 values are out of test data image.');
        
        wh = find(badvals);

        fprintf('Total voxels in weight mask: %3.0f\n', sum(inmask));
        disp('Test images with bad values:');
        for i = 1:length(wh)
            fprintf('Test image %3.0f: %3.0f zero values\n', wh(i), badvals(:, wh(i)));
        end
        
        dat = dat.dat' * weights;
    end
    % End check and weight ---------------------------------------------------------


end


end
