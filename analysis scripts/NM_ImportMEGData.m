%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ImportMEGData.m
%
% Notes:
%   * This function imports the meg recordings with the following stesp:
%       - Copies the files from the acquisition comptuer 
%            - /neurospin/acquisition/neuromag/data/simp_comp
%       - Runs max filter on the raw data
%           * NOTE: This is necessary before the data can be loaded into ft
%       - Deletes the raw files to save space
%       - Checks to make sure that ft_read_header works.
%   * The final result is a set of _sss.fif files in the /meg_data/ folder
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ImportMEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ImportMEGData()

% For now, separate these out...
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'meeg')
    return; 
end

% Make sure we're initialized
NM_LoadSubjectData();

% And see if we have it already
checkForData();

% Get the directory
acq_dir = findAcqDir();

% Need to copy over and run the max filter on each file
global GLA_subject;
global GLA_subject_data;
for r = 1:GLA_subject_data.settings.num_runs
    importMEGRun([acq_dir '/' GLA_subject_data.settings.meg_run_files{r} '.fif'],...
        [GLA_subject '_run_' num2str(r) '.fif']); 
end

% And the baseline
importMEGRun([acq_dir '/' GLA_subject_data.settings.meg_basline_file '.fif'],...
    [GLA_subject '_baseline.fif']);

% And resave with the flag
NM_SaveSubjectData({{'meg_data_imported',1}});



function importMEGRun(src_file, dest_name)

% Copy
global GLA_subject;
disp(['Copying ' dest_name '...']);
dest_dir = [NM_GetRootDirectory() '/meg_data/' GLA_subject];
[succ m m_id] = mkdir(dest_dir); %#ok<NASGU,ASGLU>

dest_file = [dest_dir '/' dest_name];
cp_cmd = ['cp ' src_file ' ' dest_file];
system(cp_cmd);
disp('Done.');

% Maxfilter command
global GLA_subject_data;
filt_file = [dest_file(1:end-4) '_sss.fif'];
disp(['Running maxfilter on ' dest_name '...']);
mf_cmd = ['maxfilter-2.2 -force -f ' dest_file ...
    ' -o ' filt_file ' -v -frame head -origin ' ...
    num2str(GLA_subject_data.settings.max_filter_origin(1)) ' '...
    num2str(GLA_subject_data.settings.max_filter_origin(2)) ' ' ...
    num2str(GLA_subject_data.settings.max_filter_origin(3)) ' '...
    ' -autobad on -badlimit ' num2str(GLA_subject_data.settings.max_filter_badlimit)];
system(mf_cmd);
disp('Done');

% Delete the other
disp(['Removing raw file: ' dest_name '...']);
rm_cmd = ['rm ' dest_file];
system(rm_cmd);

% And test
disp('Testing conversion...');
disp(filt_file)
hdr = ft_read_header(filt_file);
if hdr.nChans ~= 354
    error('Unexpected header.');
end
disp('Done.');




function acq_dir = findAcqDir()

% Look for the data first
global GLA_subject;
meg_acq_dir = '/neurospin/acquisition/neuromag/data/simp_comp';

% FOr now, assume there's only one
% Also, assume the directory is always named with the underscore between
% the letters and the number.
acq_dir = [meg_acq_dir '/' GLA_subject(1:2) '_' GLA_subject(3:end)];
if ~exist(acq_dir,'dir')
    error('Folder not found.');
end
folders = ls(acq_dir);
if size(folders,1) ~= 1
    error('Wrong number of folders.');
end

% Has an odd trailing character...
acq_dir = [acq_dir '/' folders(1:end-1)];



function checkForData()

global GLA_subject;
global GLA_subject_data;
exist_f = {};
data_folder = [NM_GetRootDirectory() '/meg_data/' GLA_subject];
for r = 1:GLA_subject_data.settings.num_runs
    f_name = [data_folder '/' GLA_subject '_run_' num2str(r) '_sss.fif'];
    if exist(f_name,'file')
        exist_f{end+1} = f_name; %#ok<AGROW>
    end
end
if GLA_subject_data.settings.num_blinks > 0
    f_name = [data_folder '/' GLA_subject '_baseline_sss.fif'];
    if exist(f_name,'file')
        exist_f{end+1} = f_name;
    end
end

if ~isempty(exist_f)
    disp('WARNING. MEG data files found: ');
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



