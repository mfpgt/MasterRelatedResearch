%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ClearBehavioralData.m
%
% Notes:
%   * Clears all of the behavioral data accumulated to date
%       - The global GLA_behavioral_data variable
%       - The saved .mat file.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ClearBehavioralData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ClearBehavioralData()

% Make sure we're up to date
NM_LoadSubjectData();

global GLA_behavioral_data; %#ok<NUSED>
clear global GLA_behavioral_data;
if exist(NM_GetBehavioralDataFilename(),'file')
    delete(NM_GetBehavioralDataFilename());
end

global GLA_subject;
disp(['Cleared ' NM_GetBehavioralDataType() ' behavioral data for ' GLA_subject '.']);


