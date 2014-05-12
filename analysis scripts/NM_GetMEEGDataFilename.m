%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetMEEGDataFilename.m
%
% Notes:
%   * Quick helper to get the name of the .mat file holding the
%       GLA_meeg_data corresponding to the current analysis.
%
% Inputs:
% Outputs:
% Usage: 
%   * f_name = NM_GetMEEGDataFilename()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f_name = NM_GetMEEGDataFilename()

global GLA_subject;
global GLA_meeg_type;
global GLA_epoch_type;
if isempty(GLA_meeg_type)
    error('GLA_meeg_type not set yet.');
end
if isempty(GLA_epoch_type)
    error('GLA_epoch_type not set yet.');
end
f_name = [NM_GetRootDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' GLA_meeg_type '_' GLA_epoch_type '_data.mat']; 
