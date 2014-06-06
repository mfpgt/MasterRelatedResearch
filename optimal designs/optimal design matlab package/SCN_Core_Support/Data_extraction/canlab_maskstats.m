function MASKSTATS = canlab_maskstats(maskfiles,imgfiles,varargin)
% stats = canlab_maskstats(maskfiles,imgfiles,[options])
% 
% DESCRIPTION
% Produces comparison of pattern mask and images
% e.g., look at NPS pattern expression in set of beta images
%
% OPTIONS
%   'trinarize'
%      trinarize maskfile (m(m<0) = -1 & m(m>0) = 1)
%   'single'
%      leave data as single (DEFAULT: convert to double)
%   'zeros'
%      don't remove zeros from imgfiles before taking measurements
%   'noreshape'
%      don't attempt to reshape results according to imgfiles array
%
% BUILT-IN MASKS
% The following strings can be given as the MASKFILE argument to
% call up built-in mask files:
%   'nps'                weights_NSF_grouppred_cvpcr.img
%   'nps_thresh'         weights_NSF_grouppred_cvpcr_FDR05.img
%   'nps_thresh_smooth'  weights_NSF_grouppred_cvpcr_FDR05_smoothed_fwhm05.img
%
% MEASURE OPTIONS
%   'all'
%      include: mean, std, dot_product, centered_dot_product,
%               cosine_similarity, and correlation
%      note: all other MEASURE OPTIONS will be ignored
%   'mean' (DEFAULT)
%      apply binarized mask to images and return means
%      mean(img .* abs(bin(mask)))
%   'std'
%      apply binarized mask to images and return standard deviations
%      std(img .* abs(bin(mask)))
%   'nonbinmean'
%      apply mask to images without binarizing mask, return means
%      mean(img .* mask)
%   'nonbinstd'
%      apply mask to images without binarizing mask, return standard deviations
%      std(img .* mask)
%   'dot_product'
%      dot(mask, img)
%   'cosine_similarity'
%      dot(mask, img) / (norm(mask) * norm(img))
%   'correlation'
%      corr(mask, img)
%   'centered_dot_product'
%      dot(mask-mean(mask), img-mean(img))
%
%       


%% parse arguments
OP = {};
ALLOPS = false;
TRINARIZE = false;
SINGLE = false;
ZEROS = false;
RESHAPE = true;

i=1;
while i<=numel(varargin)
    if ischar(varargin{i})
        switch varargin{i}   
            case {'binmean' 'mean' 'std' 'nonbinmean' 'nonbinstd' 'norm' ...
                  'dot_product' 'centered_dot_product' 'cosine_similarity' 'correlation'}
                OP{end+1} = varargin{i}; %#ok    
            case 'all'
                ALLOPS = true;
            case 'zeros'
                ZEROS = true;
            case 'noreshape'
                RESHAPE = false;
            case 'trinarize'
                TRINARIZE = true;
            case 'single'
                SINGLE = true;
            otherwise
                error('Unrecognized argument %s',varargin{i})
        end
    elseif iscellstr(varargin{i})
        for j=1:numel(varargin{i})
            switch varargin{i}{j}
                case {'binmean' 'mean' 'std' 'nonbinmean' 'nonbinstd' 'norm' ...
                        'dot_product' 'centered_dot_product' 'cosine_similarity' 'correlation'}
                    OP{end+1} = varargin{i}{j}; %#ok
                case 'all'
                    ALLOPS = true;
                otherwise
                    error('Unrecognized argument %s',varargin{i}{j})
            end
        end
    else
        disp(varargin{i})
        error('Above argument unrecognized')
    end
    i=i+1;
end

if ALLOPS, OP = {'mean' 'std' 'dot_product' 'centered_dot_product' 'cosine_similarity' 'correlation'}; end
    
if isempty(OP), OP = {'mean'}; end


%% error checking
if isempty(maskfiles), error('Must provide one or more maskfiles'); end
if ischar(maskfiles), maskfiles = cellstr(maskfiles); end
if ~iscellstr(maskfiles), error('maskfiles must be a string or cell array of strings');end

if isempty(imgfiles), error('Must provide one or more imgfiles'); end
if ischar(imgfiles), imgfiles = cellstr(imgfiles); end
if ~iscellstr(imgfiles), error('imgfiles must be string or cell array of strings'); end


%% prepare mask
for m = 1:numel(maskfiles)
    switch maskfiles{m}
        case 'nps'
            maskfiles{m} = which('weights_NSF_grouppred_cvpcr.img');
        case 'nps_thresh'
            maskfiles{m} = which('weights_NSF_grouppred_cvpcr_FDR05.img');
        case 'nps_thresh_smooth'
            maskfiles{m} = which('weights_NSF_grouppred_cvpcr_FDR05_smoothed_fwhm05.img');
        otherwise
            if ~exist(maskfiles{m},'file')
                error('No such file: %s',maskfiles{m})
            end
    end
    MASKSTATS(m).maskfile = maskfiles{m}; %#ok
    evalc('mask{m} = fmri_data(maskfiles{m},maskfiles{m});');
end

if TRINARIZE
    mask{m}.dat(mask{m}.dat<0) = -1; %#ok
    mask{m}.dat(mask{m}.dat>0) = 1;
end

if ~SINGLE, mask{m}.dat = double(mask{m}.dat); end


%% prepare data
% fprintf('LOADING IMAGE FILES\n')
% data = fmri_data(imgfiles);
  % this option is SLOOOW compared to scn_map_image (~10x)


%% produce comparison
for m = 1:numel(mask)
    clear tmpdata datcent maskcent datnorm masknorm
    
    fprintf('GETTING DATA FOR MASK: %s\n',maskfiles{m})
    MASKSTATS(m).imgfiles = imgfiles; %#ok
        
    %%% prepare data    
    %     tmpdata = data.resample_space(mask{m});
      % this option is SLOOOW compared to scn_map_image (~10x)
    evalc('tmpdata = fmri_data(imgfiles,maskfiles{m},''sample2mask'');');    
    
    if ~SINGLE, tmpdata.dat = double(tmpdata.dat); end
    if ~ZEROS, tmpdata.dat(tmpdata.dat==0) = NaN; end
    
    for i = 1:numel(OP)
        switch OP{i}
            case 'mean'
                MASKSTATS(m).stats.mean = nanmean(tmpdata.dat)'; %#ok
            case 'std'
                MASKSTATS(m).stats.std = nanstd(tmpdata.dat)'; %#ok
                
            case 'nonbinmean'
                MASKSTATS(m).stats.nonbinmean = nanmean(bsxfun(@times,tmpdata.dat,mask{m}.dat))'; %#ok
            case 'nonbinstd'
                MASKSTATS(m).stats.nonbinstd = nanstd(bsxfun(@times,tmpdata.dat,mask{m}.dat))'; %#ok
                
            case 'norm'
                MASKSTATS(m).stats.norm = (nansum(tmpdata.dat .^ 2) .^ .5)'; %#ok
                
            case 'dot_product'                
                MASKSTATS(m).stats.dot_product = nansum(bsxfun(@times,tmpdata.dat,mask{m}.dat))'; %#ok
                
            case 'centered_dot_product'                
                datcent = bsxfun(@minus,tmpdata.dat,nanmean(tmpdata.dat));
                maskcent = bsxfun(@minus,mask{m}.dat,nanmean(mask{m}.dat));
                MASKSTATS(m).stats.centered_dot_product = nansum(bsxfun(@times,datcent,maskcent)); %#ok
                
            case 'cosine_similarity'
                datnorm = nansum(tmpdata.dat .^ 2) .^ .5;
                masknorm = nansum(mask{m}.dat .^ 2) .^ .5;
                MASKSTATS(m).stats.cosine_similarity = (nansum(bsxfun(@times,tmpdata.dat,mask{m}.dat)) ./ (datnorm .* masknorm))'; %#ok                               
                
            case 'correlation'
                MASKSTATS(m).stats.correlation = corr(tmpdata.dat,mask{m}.dat,'rows','pairwise'); %#ok
                
            otherwise
                error('Comparison type (%s) unrecognized',OP{i})
        end
        
        if RESHAPE, try MASKSTATS(m).stats.(OP{i}) = reshape(MASKSTATS(m).stats.(OP{i}),size(imgfiles)); end; end %#ok
    end    
end

end