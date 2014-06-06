function canlab_create_wm_ventricle_masks(wm_mask, gm_mask)

% function canlab_create_wm_ventricle_masks(wm_mask, gm_mask)
% This function saves white matter and ventricle masks.
% output: "white_matter.img" and "ventricles.img" in the same folder of
%         the input structural files
%
% input
% wm_mask: white matter structural image file  
%   eg) wm_mask = filenames('Structural/SPGR/wc2*.nii', 'char', 'absolute');
% gm_mask: gray matter structural image file 
%   eg) gm_mask = filenames('Structural/SPGR/wc1*.nii', 'char', 'absolute');
%
% 5/4/2012 by Tor Wager and Wani Woo
% 

canonvent_mask = which('canonical_ventricles.img');
bstem = which('spm2_brainstem.img');
canonical_wm = which('white.nii');

if isempty(canonvent_mask) || isempty(bstem) || isempty(canonical_wm)
    error('If you want to use this function, you need ''canonical_ventricles.img'', ''spm2_brainstem.img'', and ''white.nii'' in your path.');
end

%% WHITE MATTER

wm = statistic_image('image_names', wm_mask);
wm = threshold(wm, [.99 1.1], 'raw-between');
%orthviews(wm)

% mask with canonical
canonwm = statistic_image('image_names', canonical_wm);
canonwm = threshold(canonwm, [.5 1.1], 'raw-between');

wm = apply_mask(wm, canonwm);

%%

bstem = statistic_image('image_names', bstem);
bstem = resample_space(bstem, wm, 'nearest');

wm = replace_empty(wm);
bstem = replace_empty(bstem); 
% remove brainstem voxels
wm = remove_empty(wm, logical(bstem.dat));

% write
d = fileparts(wm.fullpath);
wm.fullpath = fullfile(d, 'white_matter.img');
write(wm)


%% VENTRICLE


% in canonical brain and canonical ventricles
% not in WM or gray matter

% "not gm, not wm"
gm = statistic_image('image_names', gm_mask);
gm = threshold(gm, [.4 1.1], 'raw-between'); 

wm = statistic_image('image_names', wm_mask);
wm = threshold(wm, [.4 1.1], 'raw-between'); 
%wm = resample_space(wm, gm, 'nearest');

%wm.removed_voxels = wm.removed_voxels(wm.volInfo.wh_inmask);
wm = replace_empty(wm);

in_neither = ~(gm.volInfo.image_indx | wm.volInfo.image_indx);

%notgmwm = apply_mask(gm, wm);

%notgmwm = replace_empty(notgmwm);

canonvent_mask = statistic_image('image_names', canonvent_mask);
%canonvent_mask = resample_space(canonvent_mask, gm, 'nearest');

%canonvent_mask.removed_voxels = canonvent_mask.removed_voxels(canonvent_mask.volInfo.wh_inmask);
canonvent_mask = replace_empty(canonvent_mask);

% manually remove and re-form
indx = in_neither & canonvent_mask.volInfo.image_indx;
to_remove = canonvent_mask.volInfo.image_indx & ~indx;
to_remove = find(to_remove(canonvent_mask.volInfo.wh_inmask));
canonvent_mask.volInfo.image_indx = indx;
canonvent_mask.volInfo.wh_inmask = find(indx);
canonvent_mask.volInfo.n_inmask = sum(indx);
canonvent_mask.volInfo.xyzlist(to_remove, :) = [];
canonvent_mask.volInfo.cluster(to_remove, :) = [];
canonvent_mask.dat(to_remove, :) = [];

% write

d = fileparts(wm.fullpath);
canonvent_mask.fullpath = fullfile(d, 'ventricles.img');
write(canonvent_mask)

return
