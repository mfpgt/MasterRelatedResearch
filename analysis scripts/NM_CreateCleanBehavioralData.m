%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CreateCleanBehavioralData.m
%
% Notes:
%   * Creates a "clean" version of the current behavioral data. This data is
%       saved to GLA_clean_behavioral_data. This differs from the full data by:
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
%   * NM_CreateCleanBehavioralData(cfg)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CreateCleanBehavioralData(cfg)

% Load the data
NM_LoadBehavioralData();

if ~exist('cfg','var')
    cfg = [];
end

% Get suggested rejections if we're not given them
clear global GLA_clean_behavioral_data;
global GLA_clean_behavioral_data;
if isfield(cfg,'rejections')
    GLA_clean_behavioral_data.rejections = cfg.rejections;
else
    GLA_clean_behavioral_data.rejections = NM_SuggestRejections();
end

% Set the rejected data
global GLA_behavioral_data;
trials = 1:length(GLA_behavioral_data.data.cond);
for r = 1:length(GLA_clean_behavioral_data.rejections)
    r_ind = find(trials == GLA_clean_behavioral_data.rejections(r),1);
    if ~isempty(r_ind)
        trials = trials([1:r_ind-1 r_ind+1:end]);
    end
end

% And set all of data
data_fields = fieldnames(GLA_behavioral_data.data);
for d = 1:length(data_fields)

    % Only these are needed
    if sum(strcmp(data_fields{d},{'acc','rt','cond'})) > 0
        GLA_clean_behavioral_data.data.(data_fields{d}) = ...
                GLA_behavioral_data.data.(data_fields{d})(trials);
    end
end


