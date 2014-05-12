%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetScanFiles.m
%
% Notes:
%   * Quick helper to unpack the .nii files into their components using the
%       spm_select command
%
% Inputs:
% Outputs:
% Usage: 
%   * files = NM_GetScanFiles(['^' GLA_subject '_loc']);
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function files = NM_GetScanFiles(filter)

% Use the spm command to unpack the .nii list
global GLA_subject;
global GLA_fmri_type;
files = cellstr(spm_select('ExtFPList', ...
    [NM_GetRootDirectory() '/fmri_data/' GLA_subject ...
        '/' GLA_fmri_type],[filter '.nii'], Inf));

