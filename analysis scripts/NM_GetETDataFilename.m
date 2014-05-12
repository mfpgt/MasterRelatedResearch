%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetETDataFilename.m
%
% Notes:
%   * Quick helper to return the file path to the save eye tracker data.
%
% Inputs:
% Outputs:
%   * f_name: The name of the filepath to the saved data
%
% Usage: 
%   * NM_GetETDataFilename()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f_name = NM_GetETDataFilename()

global GLA_epoch_type;
global GLA_subject;
if isempty(GLA_epoch_type)
    error('Need to set a GLA_epoch_type first.');
end

f_name = [NM_GetRootDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' GLA_epoch_type '_et_data.mat']; 
