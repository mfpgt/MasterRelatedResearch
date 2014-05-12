%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CreateCleanETData.m
%
% Notes:
%   * Creates a "clean" version of the current eye tracker data. This data is
%       saved to GLA_clean_et_data. This differs from the full data by:
%       - Rejecting trials (determined by NM_SuggestRejections)
%
% Inputs:
%   * cfg (optional): Can automatically set the rejections 
%       - Useful for generating the same clean data repeatedly
%
% Outputs:
% Usage: 
%   * cfg = [];
%   * cfg.rejections = [1 56 9];
%   * NM_CreateCleanETData(cfg)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CreateCleanETData(cfg)

% Should be preprocessed
global GLA_epoch_type;
NM_LoadSubjectData({...
    {['et_' GLA_epoch_type '_data_preprocessed'],1},...
    });

% Load the data
NM_LoadETData();

if ~exist('cfg','var')
    cfg = [];
end

% Get suggested rejections if we're not given them
clear global GLA_clean_et_data;
global GLA_clean_et_data;
if isfield(cfg,'rejections')
    GLA_clean_et_data.rejections = cfg.rejections;
else
    GLA_clean_et_data.rejections = NM_SuggestRejections();
end

% Set the rejected data
% TODO: May need to clear full data for memory
global GLA_et_data;
trials = 1:length(GLA_et_data.data.cond);
for r = 1:length(GLA_clean_et_data.rejections)
    r_ind = find(trials == GLA_clean_et_data.rejections(r),1);
    if ~isempty(r_ind)
        trials = trials([1:r_ind-1 r_ind+1:end]);
    end
end

% And set all of data
data_fields = fieldnames(GLA_et_data.data);
for d = 1:length(data_fields)

    switch data_fields{d}
        case 'epoch'
            GLA_clean_et_data.data.epoch =...
                GLA_et_data.data.epoch;

        otherwise
            GLA_clean_et_data.data.(data_fields{d}) = ...
                GLA_et_data.data.(data_fields{d})(trials);
    end
end


