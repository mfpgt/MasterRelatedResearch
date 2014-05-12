%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetMEEGLayout.m
%
% Notes:
%   * Quick helper to get the right layout name
%
% Inputs:
% Outputs:
%   * layout: The name of the layout
%       - MEG: 'neuromag306all.lay'
%       - EEG: 'GSN-HydroCel-256.sfp'
%
% Usage: 
%   * layout = NM_GetMEEGLayout()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function layout = NM_GetMEEGLayout()

global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'
        layout = 'neuromag306all.lay';
        
    case 'eeg'
        layout = 'GSN-HydroCel-256.sfp';
        
    otherwise
        error('Unknown type.');
end
