%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ImportfMRIData.m
%
% Notes:
%   * This function imports the fmri data from the acquisition computer
%       - '/neurospin/acquisition/database/TrioTim'
%   * Then converts the data from dcm to nii
%       * The dcm2nii script does not seem to work with linux / matlab so
%           really we write a script to /fmri_data/NIP/. This function then
%           waits until you signal that you have run the script.
%   * This script then produces the NIP_run_#.nii and NIP_anat.nii files in 
%       /fmri_data/NIP/experiment, and NIP_loc.nii / NIP_anat.nii in 
%       /fmri_data/NIP/localizer.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ImportfMRIData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ImportfMRIData()

% Keep these separate for now
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'fmri')
    return;
end

% Make sure we're initialized
NM_LoadSubjectData();

% And see if we have it already
checkForData();

% Get the directory
acq_dir = findAcqDir();

% Unfortunately, have to manually run from the command line
global GLA_subject;

% Just write to whereever we are in matlab
fid = setupImport();

% Need to copy using the conversion script
global GLA_subject_data;
importScan(acq_dir, GLA_subject_data.settings.anat_scan, 'anat', 'experiment', fid);
for r = 1:GLA_subject_data.settings.num_runs
    importScan(acq_dir, GLA_subject_data.settings.run_scans{r}, ...
        ['run_' num2str(r)], 'experiment', fid);
end

% And the localizer
importScan(acq_dir, GLA_subject_data.settings.anat_scan, 'anat', 'localizer', fid);
importScan(acq_dir, GLA_subject_data.settings.loc_scan, 'loc', 'localizer', fid);
fclose('all');

% Now, wait for confirmation of running
disp('You must now run the dcm2nii_script');
disp(['Go to ' NM_GetRootDirectory() '/fmri_data/' GLA_subject ' in the terminal, and ' ...
    'run: ./dcm2nii_script.sh']);
while 1
    ch = input('Did the script run correctly (y/n)? ','s');
    if strcmp(ch,'y')
        break;
    elseif strcmp(ch,'n')
        error('Not ok.');
    end
end
NM_SaveSubjectData({{'fmri_data_imported',1}});
disp(['Imported fmri data for ' GLA_subject '.']);

function fid = setupImport()

% Make the folders, otherwise the copy will be in the wrong place
global GLA_subject;
data_folder = [NM_GetRootDirectory() '/fmri_data/' GLA_subject];
[success message message_id] = mkdir(data_folder); %#ok<NASGU,ASGLU>
[success message message_id] = mkdir([data_folder '/localizer']); %#ok<NASGU,ASGLU>
[success message message_id] = mkdir([data_folder '/experiment']); %#ok<NASGU,ASGLU>


% Start the conversion script
fid = fopen([data_folder '/dcm2nii_script.sh'],'w');
fprintf(fid,'#! /bin/bash\n');
fprintf(fid,['# Conversion of dcm files to nii for ' GLA_subject '.\n\n']);


function importScan(acq_dir, scan_num, label, run_type, fid)

% Get the folder
global GLA_subject;
scan_dir = getScanDir(acq_dir, scan_num);
dest_dir = [NM_GetRootDirectory() '/fmri_data/' GLA_subject '/' run_type];


% Copy 
disp(['Copying run ' scan_num '...']);
cp_cmd = ['cp -r ' acq_dir '/' scan_dir ' ' dest_dir];
system(cp_cmd);
disp('Done.');


% Can't get this to work from matlab, so we'll have to write out a bash
% file and run it...

% The conversion command
fprintf(fid, ['dcm2nii -g n -d n -e n -p n -x n -r n ' dest_dir '/' scan_dir '\n']);

% The move / rename command
fprintf(fid, ['mv ' dest_dir '/' scan_dir '/*nii ' ...
    dest_dir '/' GLA_subject '_' label '.nii\n']);

% And the delete command
fprintf(fid, ['rm -r ' dest_dir '/' scan_dir '\n']);





function scan_dir = getScanDir(acq_dir, scan_num)

% Not dealing with more scans yet. Have to add some zeros...
if str2double(scan_num) > 9
    error('Unimplemented.');
end
scan_dir = '';
folders = dir(acq_dir);
for f = 1:length(folders)
    if ~isempty(strfind(folders(f).name,['00000' scan_num]))
        scan_dir = folders(f).name;
    end
end
if isempty(scan_dir)
    error('Scan not found.');
end



function acq_dir = findAcqDir()

% Look for the data first
fmri_acq_dir = '/neurospin/acquisition/database/TrioTim';

% Get the date from the parameters
global GLA_subject_data;
acq_dir = [fmri_acq_dir '/' GLA_subject_data.settings.rec_date];

% Fr now, assume there's only one
% Also, assume the directory is always named with the underscore between
% the letters and the number.
if ~exist(acq_dir,'dir')
    error('Folder not found.');
end

global GLA_subject;
subj_folder = [];
folders = dir(acq_dir);
disp(acq_dir)
disp(GLA_subject)
for f = 1:length(folders)
    if ~isempty(strfind(folders(f).name, GLA_subject))
        subj_folder = folders(f).name;
    end
end
if isempty(subj_folder)
    error('Folder not found.');
end
acq_dir = [acq_dir '/' subj_folder];


function checkForData()

global GLA_subject;
global GLA_subject_data;
exist_f = {};
data_folder = [NM_GetRootDirectory() '/fmri_data/' GLA_subject];
for r = 1:GLA_subject_data.settings.num_runs
    f_name = [data_folder '/experiment/' GLA_subject '_run_' num2str(r) '.nii'];
    if exist(f_name,'file')
        exist_f{end+1} = f_name; %#ok<AGROW>
    end
end
f_name = [data_folder '/experiment/' GLA_subject '_anat.nii'];
if exist(f_name,'file')
    exist_f{end+1} = f_name;
end

% And the localizer
f_name = [data_folder '/localizer/' GLA_subject '_loc.nii'];
if exist(f_name,'file')
    exist_f{end+1} = f_name;
end
f_name = [data_folder '/localizer/' GLA_subject '_anat.nii'];
if exist(f_name,'file')
    exist_f{end+1} = f_name;
end

if ~isempty(exist_f)
    disp('WARNING. fmri data files found: ');
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





