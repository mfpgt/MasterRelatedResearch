%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SetBehavioralRejections.m
%
% Notes:
%   * Sets the 'rejections' field of GLA_behavioral_data. For now, we will
%       set outliers, timeouts, and errors.
%   * IMPORTANT: This function does not actually reject the trials. This is
%       done with NM_CreateCleanBehavioralData()
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SetBehavioralRejections()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SetBehavioralRejections()

% Nothing to do for the localizer
if strcmp(NM_GetBehavioralDataType(),'localizer')
    return;
end

% Load the data
global GLA_subject;
disp(['Setting ' NM_GetBehavioralDataType() ' behavioral rejections for ' GLA_subject]);
NM_LoadBehavioralData();

% See what we have to reject
global GLA_behavioral_data;
GLA_behavioral_data.rejections = {};
types = {'outliers','timeouts','errors'};
for t = 1:length(types)
    GLA_behavioral_data.rejections(t).type = types{t};
    GLA_behavioral_data.rejections(t).trials = GLA_behavioral_data.data.(types{t});
end

% And save
NM_SaveBehavioralData();
disp('Done.');

