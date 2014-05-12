%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SanityCheckfMRIData.m
%
% Notes:
%   * Makes sure that the fMRI data looks good.
%       - Plots the movement from both the localizer and experiment.
%       - Analyzes the localizer data.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SanityCheckfMRIData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SanityCheckfMRIData()

% Keep these separate for now
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'fmri')
    return;
end

global GLA_subject;
disp(['Sanity checking fMRI data for ' GLA_subject '...']);

% Check movment for both
global GLA_fmri_type; 
types = {'localizer','experiment'};
for t = 1:length(types)
    GLA_fmri_type = types{t}; %#ok<NASGU>
    NM_CheckfMRIMovement();
end

% Analyze the localizer data
GLA_fmri_type = 'localizer';
NM_AnalyzefMRIData();



