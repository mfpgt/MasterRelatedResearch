%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ClearETData.m
%
% Notes:
%   * Removes the current eye tracking data
%       - Both the saved data.mat file and the GLA_et_data variable
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ClearETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ClearETData()

% Make sure we're up to date
NM_LoadSubjectData();

global GLA_et_data; %#ok<NUSED>
clear global GLA_et_data;
if exist(NM_GetETDataFilename(),'file')
    delete(NM_GetETDataFilename());
end

global GLA_subject;
global GLA_epoch_type;
disp(['Cleared ' GLA_epoch_type ' eye tracking data for ' GLA_subject '.']);


