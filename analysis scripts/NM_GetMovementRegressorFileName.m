%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetMovementRegressorFileName.m
%
% Notes:
%   * Helper to find the movement report from an fmri run.
%       - Looks for any rp*.txt file in the fmri_data subject folder
%           - For the experiment, a rp*#.txt file for a given run number
%
% Inputs:
%   * run_num: The run number to find the movement for (1-4)
%       - Not needed for the localizer
%
% Outputs:
%   * file_name: The full file path to the movement file
%
% Usage: 
%   * file_name = NM_GetMovementRegressorFileName(1)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function file_name = NM_GetMovementRegressorFileName(run_num)
    
% Look for the rp...txt file
global GLA_fmri_type;
global GLA_subject;
data_dir = [NM_GetRootDirectory() '/fmri_data/'...
    GLA_subject '/' GLA_fmri_type];
files = dir(data_dir);
for f = 1:length(files)
    if length(files(f).name) > 5 && strcmp(files(f).name(1:2),'rp') &&...        
            ((strcmp(GLA_fmri_type,'localizer') && strcmp(files(f).name(end-3:end),'.txt')) ||...
             (strcmp(GLA_fmri_type,'experiment') && strcmp(files(f).name(end-4:end),[num2str(run_num) '.txt'])))
        file_name = [data_dir '/' files(f).name];
        return;
    end
end
error('Movement file not found.');

