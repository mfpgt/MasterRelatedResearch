%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckFileStructure.m
%
% Notes:
%   * Checks to make sure that all of the data files necessary to run the
%   analysis exist.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_CheckFileStructure()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckFileStructure()

% Make sure we know what we're doing
NM_LoadSubjectData();

% Log files
checkLogFiles();

% Eye tracking files
checkETFiles();

% MEG files
checkMEGFiles();

% EEG files
checkEEGFiles();

% fMRI files
% checkfMRIFiles();

global GLA_subject;
global GLA_rec_type;
disp(['All files expected for the ' GLA_rec_type ...
    ' analysis of ' GLA_subject ' found.']);



function checkfMRIFiles()

global GLA_subject_data;
if ~GLA_subject_data.settings.fmri
    return;
end

global GLA_subject;
fmri_folder = [NM_GetRootDirectory() '/fmri_data/' GLA_subject];
for r = 1:GLA_subject_data.settings.num_runs
    checkFile([fmri_folder '/experiment/' GLA_subject '_run_' num2str(r) '.nii']);
end
checkFile([fmri_folder '/experiment/' GLA_subject '_anat.nii']);

% And the localizer
checkFile([fmri_folder '/localizer/' GLA_subject '_loc.nii']);
checkFile([fmri_folder '/localizer/' GLA_subject '_anat.nii']);


function checkEEGFiles()

global GLA_subject_data;
if ~GLA_subject_data.settings.eeg
    return;
end


global GLA_subject;
eeg_folder = [NM_GetRootDirectory() '/eeg_data/' GLA_subject];
for r = 1:GLA_subject_data.settings.num_runs
    checkFile([eeg_folder '/' GLA_subject '_run_' num2str(r) '.raw']);
end
checkFile([eeg_folder '/' GLA_subject '_baseline.raw']);


function checkMEGFiles()

global GLA_subject_data;
if ~GLA_subject_data.settings.meg
    return;
end


global GLA_subject;
meg_folder = [NM_GetRootDirectory() '/meg_data/' GLA_subject];
for r = 1:GLA_subject_data.settings.num_runs
    checkFile([meg_folder '/' GLA_subject '_run_' num2str(r) '_sss.fif']);
end
checkFile([meg_folder '/' GLA_subject '_baseline_sss.fif']);
    


function checkETFiles()

global GLA_subject_data;
if ~GLA_subject_data.settings.eye_tracker
    return;
end


global GLA_subject;
et_folder = [NM_GetRootDirectory() '/eye_tracking_data/' GLA_subject];
for r = 1:GLA_subject_data.settings.num_runs
    checkFile([et_folder '/' GLA_subject '_run_' num2str(r) '.asc']);
end
checkFile([et_folder '/' GLA_subject '_baseline.asc']);


function checkLogFiles()

% Everyone needs these
global GLA_subject;
log_folder = [NM_GetRootDirectory() '/logs/' GLA_subject];
checkFile([log_folder '/' GLA_subject '_log.txt']);
checkFile([log_folder '/' GLA_subject '_data.txt']);

% fMRI has the localizer stim as well
global GLA_rec_type;
if strcmp(GLA_rec_type,'fmir')
    checkFile([log_folder '/' GLA_subject '_localizer_list.csv']);
end


function checkFile(f_name)

if ~exist(f_name,'file')
    error([f_name ' not found.']);
end










