%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_InitializeSubjectData.m
%
% Notes:
%   * This function initializes the settings field of the GLA_subject_data global
%       - This includes (in theory) all of the parameters needed to run the
%           analysis.
%       - Virtually all functions check this field (e.g. for processing the
%           data, parsing the logs, etc., etc.)
%       - Subject specific settings / overrides are read from the
%           appropriate _subject_notes.txt file.
%   * IMPORTANT: After changing a settings, to update the existing subject
%       data, call this function with the optional argument set to 0 to not
%       delete the old data.
%
% Inputs:
%   * should_clear (optional): 0 - does not clea
%       - Defaults to 1
%
% Outputs:
%
% Usage: NM_InitializeSubjectData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_InitializeSubjectData(should_clear)

global GLA_subject;
disp(['Initializing subject data for ' GLA_subject '...']);

% Clear any old data by default
if ~exist('should_clear','var') || should_clear
    NM_ClearSubjectData();
end

% Begin the data
global GLA_rec_type;
global GLA_subject_data;
GLA_subject_data.settings.subject = GLA_subject;
GLA_subject_data.settings.rec_type = GLA_rec_type;

% Set the run parameters
setRunParameters();

% Behavioral analysis settings
setBehavioralParameters();

% Epoch settings
setEpochs();

% Recording specific parameters
switch GLA_rec_type
    case 'meeg'
        setMEEGParameters();
        
    case 'fmri'
        setfMRIParameters();

    otherwise
        error('Unknown type');
end


% Subject specific
setSubjectParameters();


% And save
NM_SaveSubjectData();
disp(['Initialized ' GLA_subject ' for analysis.']);

function setMEEGParameters()

global GLA_subject_data;

% These are for parsing the data
GLA_subject_data.settings.num_trials = 400;
GLA_subject_data.settings.num_runs = 5;
GLA_subject_data.settings.num_localizer_blocks = 0;
GLA_subject_data.settings.eeg = 1;
GLA_subject_data.settings.meg = 1;
GLA_subject_data.settings.fmri = 0;
GLA_subject_data.settings.num_noise = 1;

% For the initial maxfilter stop
GLA_subject_data.settings.max_filter_origin = [0 0 40];
GLA_subject_data.settings.max_filter_badlimit = 4;


% MEEG analysis settings
GLA_subject_data.settings.meeg_rej_type = 'summary';  % summary, raw
GLA_subject_data.settings.meeg_decomp_method = 'pca'; % pca, fastica, runica
GLA_subject_data.settings.meeg_decomp_comp_num = 10; 
GLA_subject_data.settings.meeg_decomp_type = 'combined';  % combined, separate (wrt decomposing)
GLA_subject_data.settings.meeg_decomp_baseline_correct = 'no';  % Should we baseline correct before decomposing
GLA_subject_data.settings.meeg_filter_raw = 1;    % 1 - will filter the raw data
GLA_subject_data.settings.meeg_hpf = 1;  % .1 / [] for none
GLA_subject_data.settings.meeg_lpf = 120; % 120 / [] for none
GLA_subject_data.settings.meeg_bsf = [50 100];    % [50 100]
GLA_subject_data.settings.meeg_bsf_width = 1;


% These are used to define the trials for the eye tracking, meg, eeg data
function setEpochs()
global GLA_subject_data;
GLA_subject_data.settings.blinks_epoch = [-200 600];
GLA_subject_data.settings.left_eye_movements_epoch = [-200 600];
GLA_subject_data.settings.right_eye_movements_epoch = [-200 600];
GLA_subject_data.settings.word_5_epoch = [-200 600];
GLA_subject_data.settings.word_4_epoch = [-200 600];
GLA_subject_data.settings.word_3_epoch = [-200 600];
GLA_subject_data.settings.word_2_epoch = [-200 600];
GLA_subject_data.settings.word_1_epoch = [-200 600];
GLA_subject_data.settings.target_epoch = [-200 1000];
GLA_subject_data.settings.delay_epoch = [-200 2000];
GLA_subject_data.settings.all_epoch = [-200 6000];


function setBehavioralParameters()
global GLA_subject_data;
GLA_subject_data.settings.min_resp_time = 200;  % Fastest response to keep
GLA_subject_data.settings.max_resp_time = 2500;  % Slowest response to keep


function setfMRIParameters()
global GLA_subject_data;

% For parsing the data
GLA_subject_data.settings.num_trials = 320;
GLA_subject_data.settings.num_runs = 4;
GLA_subject_data.settings.num_localizer_blocks = 16;
GLA_subject_data.settings.eeg = 0;
GLA_subject_data.settings.meg = 0;
GLA_subject_data.settings.fmri = 1;
GLA_subject_data.settings.num_noise = 0;


% For the analysis
GLA_subject_data.settings.fmri_do_slicetiming = 0;
GLA_subject_data.settings.fmri_num_slices = 80;
GLA_subject_data.settings.fmri_tr = 1.5;

% Set the ta correctly...
GLA_subject_data.settings.fmri_ta = GLA_subject_data.settings.fmri_tr* ...
    (1-1/GLA_subject_data.settings.fmri_num_slices);
GLA_subject_data.settings.fmri_ref_slice = 1;
GLA_subject_data.settings.fmri_voxel_size = [1.5 1.5 1.5];


% Set all of the parameters describing the experimental run
function setRunParameters()
global GLA_subject_data;
GLA_subject_data.settings.localizer_catches = {'cliquez','2','1','appuyez','7','2'};
GLA_subject_data.settings.num_critical_stim = 5;
GLA_subject_data.settings.num_conditions = 5; % NOTE: Means within each structure type
GLA_subject_data.settings.num_structure_types = 2;
GLA_subject_data.settings.num_critical_stim = 5;
GLA_subject_data.settings.num_phrase_types = 2;   % Noun / list
GLA_subject_data.settings.num_a_pos = 2;  % Adjectives before and after nouns
GLA_subject_data.settings.num_nomatch_types = 2;
GLA_subject_data.settings.num_all_stim = 13;  % Including crosses, etc... 
GLA_subject_data.settings.num_localizer_block_stims = 3;
GLA_subject_data.settings.num_localizer_stim_words = 12;
GLA_subject_data.settings.num_localizer_catch_trials = 2;
GLA_subject_data.settings.localizer_response_key = 'r';
GLA_subject_data.settings.num_blinks = 15;
GLA_subject_data.settings.blinks_trigger = 2;
GLA_subject_data.settings.num_mouth_movements = 0;
GLA_subject_data.settings.mouth_movements_trigger = 5;
GLA_subject_data.settings.num_breaths = 0;    
GLA_subject_data.settings.breaths_trigger = 6;
GLA_subject_data.settings.noise_trigger = 1;
GLA_subject_data.settings.num_eye_movements = 10;
GLA_subject_data.settings.eye_tracker = 1;
GLA_subject_data.settings.eye_movements_triggers = [3 4];


% This will load specific parameters from the notes file for the subject.
function setSubjectParameters()

% Load the subject notes file and parse
global GLA_rec_type;
fid = fopen(['/neurospin/unicog/resources/neuromod/experiment/' GLA_rec_type '_subject_notes.txt']);

% Go through and look for the subject
global GLA_subject;
global GLA_subject_data;
in_subject = 0;
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    [label rest] = strtok(line);

    % Flag when we find it
    if strcmp(label,'subject') 
        if strcmp(GLA_subject,strtok(rest))
            in_subject = 1;
        else
            
            % If we've found it, then we're done
            if in_subject
                fclose(fid);
                return;
            end
        end
        continue;
    end
    
    % And parse if we need to
    if in_subject
        
        % # Marks a comment
        if ~isempty(line) && ~strcmp(line(1),'#')
            
            % These are intended to be:
            %   1 - parameter name
            %   2 - parameter type
            %   3 - parameter value
            C = textscan(line,'%s%s%s');
            val = C{3}{1};
            switch C{2}{1}
                case 'number'
                    val = str2double(val);
                    
                case 'string'
                    % Nothing to do here

                case 'cell'
                    val = parseCellParameter(line);
                    
                otherwise 
                    error('Unknown parameter type');
                    
            end
            
            % And set the value
            GLA_subject_data.settings.(C{1}{1}) = val;
        end
    end
end
fclose(fid);

% If we got here and we're not in the last subject,
%   then the subject is not in the file yet
if ~in_subject
    error('Subject not found.');
end

function val = parseCellParameter(line)

% Comma delimited 3rd argument
% First two are just the labels parsed above
val = {};
[label rest] = strtok(line); [label rest] = strtok(rest); %#ok<ASGLU>
while ~isempty(rest)
    [val{end+1} rest] = strtok(rest); %#ok<AGROW,STTOK>
end




