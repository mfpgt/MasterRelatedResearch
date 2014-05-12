%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ClearMEEGData.m
%
% Notes:
%   * Deletes the data for the current meeg analysis.
%       - Both the current GLA_meeg_data, and the corresponding .mat file.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ClearMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ClearMEEGData()

% Make sure we're up to date
NM_LoadSubjectData();

global GLA_meeg_data; %#ok<NUSED>
global GLA_subject;
global GLA_meeg_type;
global GLA_epoch_type;

% Check that we're right
if isempty(GLA_meeg_type)
    error('GLA_meeg_type not set yet.');
end
if isempty(GLA_epoch_type)
    error('GLA_epoch_type not set yet.');
end

% Then delete
clear global GLA_meeg_data;
if exist(NM_GetMEEGDataFilename(),'file')
    delete(NM_GetMEEGDataFilename());
end
disp(['Cleared ' GLA_meeg_type ' ' GLA_epoch_type ' data for ' GLA_subject '.']);

