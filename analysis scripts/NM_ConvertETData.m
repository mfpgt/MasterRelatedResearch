%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ConvertETData.m
%
% Notes:
%   * This function converts .edf eye tracking files using the edf2asc
%       converter.
%   * For some reason, the converter doesn't work on Linux, so have to run
%       elsewhere...
%       - I.e. we get an error loading a shared library (libstdc++.so.5).
%   * Will produce .asc files for the NIP_run_#.edf and NIP_baseline.edf 
%       files in the eye_tracking_data folder.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ConvertETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ConvertETData()

global GLA_subject;
disp(['Converting eyetracker data for ' GLA_subject '...']);

% Load the data
NM_LoadSubjectData();

% See if we have anything to do
global GLA_subject_data;
if ~GLA_subject_data.settings.eye_tracker
    return;
end

% Make sure it's not already there
checkForData()

% Get the edf2asc.exe file path
% NOTE: Expecting it here. Not sure how to automatically grab it
conv_file = [NM_GetRootDirectory() '/eye_tracking_data/edf2asc'];
if ~exist(conv_file,'file')
    error('No converter found.');
end

% Just run the edf2asc program on the files
for r = 1:GLA_subject_data.settings.num_runs
    convertFile(['run_' num2str(r)'], conv_file);
end
if GLA_subject_data.settings.num_blinks > 0
    convertFile('baseline', conv_file);
end

% Resave...
NM_SaveSubjectData({{'et_data_converted',1}});
disp(['Eyetracker data for ' GLA_subject ' converted.']);

function convertFile(run_id, conv_file)

global GLA_subject;

% Check for the file
f_name = [NM_GetRootDirectory() '/eye_tracking_data/' GLA_subject '/'...
    GLA_subject '_' run_id '.edf'];
if ~exist(f_name,'file')
    error(['File ' f_name ' does not exist.']);
end

% And run
c_cmd = [conv_file ' ' f_name];
system(c_cmd);



function checkForData()

global GLA_subject;
global GLA_subject_data;
exist_f = {};
data_folder = [NM_GetRootDirectory() '/meg_data/' GLA_subject];
for r = 1:GLA_subject_data.settings.num_runs
    f_name = [data_folder '/' GLA_subject '_run_' num2str(r) '.asc'];
    if exist(f_name,'file')
        exist_f{end+1} = f_name; %#ok<AGROW>
    end
end
if GLA_subject_data.settings.num_blinks > 0
    f_name = [data_folder '/' GLA_subject '_baseline.asc'];
    if exist(f_name,'file')
        exist_f{end+1} = f_name;
    end
end

if ~isempty(exist_f)
    disp('WARNING. Eyetracking .asc files found: ');
    for f = 1:length(exist_f)
        disp(['    ' exist_f{f}]); 
    end
    while 1
        ch = input('Overwrite (y/n)? ','s');
        if strcmp(ch,'y')
            return;
        elseif strcmp(ch,'n')
            error('Fix the files.');
        end
    end
end
