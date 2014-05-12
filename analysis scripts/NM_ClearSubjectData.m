%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ClearSubjectData.m
%
% Notes:
%   * This function clears the GLA_subject_data variable and any saved data.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ClearSubjectData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ClearSubjectData()

% Make sure we're up to date
global GLA_subject;
if isempty(GLA_subject)
    error('No subject set.');
end

% Delete the variable and the file
global GLA_subject_data; %#ok<NUSED>
clear global GLA_subject_data;
if exist(NM_GetSubjectDataFilename(),'file')
    delete(NM_GetSubjectDataFilename());
end

disp(['Cleared subject data for ' GLA_subject '.']);


