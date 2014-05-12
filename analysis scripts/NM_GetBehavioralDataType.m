%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetBehavioralDataType.m
%
% Notes:
%   * A quick helper function so that we don't have to set the fmri type
%      for meeg data (which only has one behavioral data type.
%
% Inputs:
% Outputs:
%   * type: Either 'experiment' or 'localizer'.
%
% Usage: 
%   * NM_GetBehavioralDataType()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function type = NM_GetBehavioralDataType()

global GLA_rec_type;
global GLA_fmri_type;
if isempty(GLA_fmri_type)
    error('GLA_fmri_type not set.');
end    

if strcmp(GLA_rec_type,'meeg')
    type = 'experiment';
else
    type = GLA_fmri_type;
end
