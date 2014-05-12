%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetBehavioralDataFilename.m
%
% Notes:
%   * Quick helper to get the full path to the behavioral data
%
% Inputs:
% Outputs:
%   * f_name: The filepath to the current saved behavioral data.
%
% Usage: 
%   * f_name = NM_GetBehavioralDataFilename()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f_name = NM_GetBehavioralDataFilename()

global GLA_subject;
f_name = [NM_GetRootDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' NM_GetBehavioralDataType() '_behavioral_data.mat']; 
