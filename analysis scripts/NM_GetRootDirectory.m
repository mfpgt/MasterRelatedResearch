%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetRootDirectory.m
%
% Notes:
%   * Helper to retrieve the full path to the directory that holds the data
%       and analysis for the current analysis.
%
% Inputs:
% Outputs:
%   * file_path: The full path the the folder holding all of the analysis
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function file_path = NM_GetRootDirectory()

global GLA_meeg_dir;
global GLA_fmri_dir;
global GLA_rec_type;

% Make sure we've set some globals
if isempty(GLA_meeg_dir) && isempty(GLA_fmri_dir)
    error('Globals not set. Run NM_InitializeGlobals.');
end

% Just grab the right one
switch GLA_rec_type
    case 'meeg'
        file_path = GLA_meeg_dir;
        
    case 'fmri'
        file_path = GLA_fmri_dir;

    otherwise
        error('Unknown case');
end
