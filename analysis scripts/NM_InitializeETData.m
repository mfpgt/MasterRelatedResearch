%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_InitializeETData.m
%
% Notes:
%   * This creates the GLA_et_data structure, with two fields:
%       - Settings: Not much - just subject and trial type
%       - data: Holds the parsed data in the following fields:
%           - cond: An array of conditions for each trial
%           - x_pos: The timecourse of the x-position for each trial
%           - y_pos: The timecourse of the y-position for each trial
%           - pupil: The timecourse of the pupil size for each trial
%           - blink_starts: An array of blink starts for each trial, with
%               the following fields
%               - time: The time of the blink start relative to the trigger 
%           - blink_ends: An array of blink ends for each trial, with
%               the following fields
%               - time: The time of the blink end relative to the trigger 
%               - length: The duration of the blink
%               * NOTE: If the subject starts blinking before the start of
%                   the trial or continues after, there will not be an even
%                   number of these.
%           - saccade_starts: An array of saccade starts for each trial, with
%               the following fields
%               - time: The time of the saccade start relative to the trigger 
%           - saccade_ends: An array of saccade ends for each trial, with
%               the following fields
%               - time: The time of the saccade end relative to the trigger 
%               - length: The duration of the saccade
%               - x_start: The x-position the saccade began at
%               - x_end: The x-position the saccade ended at
%               - y_start: The y-position the saccade began at
%               - y_end: The y-position the saccade ended at
%               * NOTE: If the subject starts saccading before the start of
%                   the trial or continues after, there will not be an even
%                   number of these.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_InitializeETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_InitializeETData()

% Initialize the data
global GLA_epoch_type;
global GLA_subject;
disp(['Initializing ' GLA_epoch_type ' eye tracking data for ' GLA_subject '...']);
NM_LoadSubjectData({{'et_data_checked',1},...
    {'log_checked',1},...
    {'timing_adjusted',1},...   % Make sure the triggers are in the right place
    });

% Reset first
NM_ClearETData();

% Then setup the data structure
global GLA_et_data;
global GLA_subject_data;
GLA_et_data.settings.subject = GLA_subject;
GLA_et_data.settings.epoch_type = GLA_epoch_type;
GLA_et_data.data.epoch = ...
    GLA_subject_data.settings.([GLA_epoch_type '_epoch']);
GLA_et_data.data.x_pos = {};
GLA_et_data.data.y_pos = {};
GLA_et_data.data.pupil = {};
GLA_et_data.data.blink_starts = {};
GLA_et_data.data.blink_ends = {};
GLA_et_data.data.saccade_starts = {};
GLA_et_data.data.saccade_ends = {};
GLA_et_data.data.cond = [];

% Grab data for each trial
if strcmp(GLA_epoch_type,'blinks') ||...
        strcmp(GLA_epoch_type,'left_eye_movements') ||...
        strcmp(GLA_epoch_type,'right_eye_movements')
    setRunData('baseline');
elseif strcmp(GLA_epoch_type,'word_5') ||... 
        strcmp(GLA_epoch_type,'word_4')
    for r = 1:length(GLA_subject_data.data.runs)
        setRunData(['run_' num2str(r)]);
    end
else
    error('Unknown type');
end

% And save
NM_SaveETData();
disp('Done.');


function setRunData(run_id)

% Load up the data
global GLA_subject;
global GL_et_run_data;
disp(['Parsing ' run_id '...']);
fid = fopen([NM_GetRootDirectory() '/eye_tracking_data/' ...
    GLA_subject '/' GLA_subject '_' run_id '.asc']);
GL_et_run_data = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s');
fclose(fid);

% Get each trial data
trials = NM_GetTrials(str2double(run_id(end)));

global GLA_et_data;
for t = 1:length(trials)
    
    % Parse the data
    [GLA_et_data.data.x_pos{end+1} GLA_et_data.data.y_pos{end+1} ...
        GLA_et_data.data.pupil{end+1} GLA_et_data.data.blink_starts{end+1}...
        GLA_et_data.data.blink_ends{end+1} GLA_et_data.data.saccade_starts{end+1}...
        GLA_et_data.data.saccade_ends{end+1} GLA_et_data.data.cond(end+1)] = getTrialData(trials(t));
end

% And clear
clear global GL_et_run_data;


function [x_pos y_pos pupil b_starts b_ends s_starts s_ends cond] = getTrialData(trial)

% Get the trigger time
t_time = NM_GetTrialTriggerTime(trial,'et');

% Find the start of the trial in the data
global GLA_subject_data;
global GLA_epoch_type;
global GL_et_run_data;
t_epoch = GLA_subject_data.settings.([GLA_epoch_type '_epoch']);
ind = find(strcmp(GL_et_run_data{1},num2str(t_time+t_epoch(1))));

% Grab the values
curr_t = t_time+t_epoch(1);
x_pos = []; y_pos = []; pupil = [];
b_starts = {}; b_ends = {}; s_starts = {}; s_ends = {};
while isnan(str2double(GL_et_run_data{1}{ind})) || ...
        str2double(GL_et_run_data{1}{ind}) < t_time+t_epoch(2)

    % Add the messages...
    if str2double(GL_et_run_data{1}{ind}) ~= curr_t
        switch GL_et_run_data{1}{ind}
            case 'MSG'
                % Noting to do with the triggers...
                
            case 'EFIX'
                % Nothing to do with fixation ends...
                
            case 'SFIX'
                % Nothing to do with fixation starts...
                
            % Record saccade starts
            case 'SSACC'
                s_starts(end+1).time = str2double(GL_et_run_data{3}{ind})-t_time; %#ok<AGROW>
                
            % Record the saccade ends, and stats
            case 'ESACC'
                s_ends(end+1).time = str2double(GL_et_run_data{4}{ind})-t_time; %#ok<AGROW>
                s_ends(end).length = str2double(GL_et_run_data{5}{ind}); 
                s_ends(end).x_start = str2double(GL_et_run_data{6}{ind});
                s_ends(end).y_start = str2double(GL_et_run_data{7}{ind});
                s_ends(end).x_end = str2double(GL_et_run_data{8}{ind});
                s_ends(end).y_end = str2double(GL_et_run_data{9}{ind});
                s_ends(end).unsure = [str2double(GL_et_run_data{10}{ind}) ...
                    str2double(GL_et_run_data{11}{ind})];

            % Record blink starts
            case 'SBLINK'
                b_starts(end+1).time = str2double(GL_et_run_data{3}{ind})-t_time; %#ok<AGROW>
                b_starts(end).marked = 1;
                
            % Record blink ends
            case 'EBLINK'
                b_ends(end+1).time = str2double(GL_et_run_data{4}{ind})-t_time; %#ok<AGROW>
                b_ends(end).length = str2double(GL_et_run_data{5}{ind});
                b_ends(end).marked = 1;
                
            otherwise
                error('Unimplemented.');
        end
        ind = ind+1;
        continue;
    end
    x_pos(end+1) = str2double(GL_et_run_data{2}{ind}); %#ok<AGROW>
    y_pos(end+1) = str2double(GL_et_run_data{3}{ind}); %#ok<AGROW>
    pupil(end+1) = str2double(GL_et_run_data{4}{ind}); %#ok<AGROW>
    curr_t = curr_t+1;
    ind = ind+1; 
end

% Check for unexpected nans...
nan_starts = find(diff(isnan(x_pos)) == 1) + t_epoch(1);
nan_ends = find(diff(isnan(x_pos)) == -1) + (t_epoch(1)-1);

% Insert any missing
for b = 1:length(nan_starts)
    if (b > length(b_starts)) || (b_starts(b).time ~= nan_starts(b))
        disp(['WARNING: Inserting blink start at ' num2str(nan_starts(b)) '.']);
        tmp = b_starts;
        b_starts = tmp(1:b-1);
        b_starts(b).time = nan_starts(b);
        b_starts(b).marked = 0;
        if length(tmp) >= b
            b_starts(b+1:length(tmp)+1) = tmp(b:end);
        end
    end
end
for b = 1:length(nan_ends)
    if (b > length(b_ends)) || (b_ends(b).time ~= nan_ends(b))
        disp(['WARNING: Inserting blink end at ' num2str(nan_ends(b)) '.']);
        tmp = b_ends;
        b_ends = tmp(1:b-1);
        b_ends(b).time = nan_ends(b);
        b_ends(b).marked = 0;
        b_ends(b).length = -1;
        if length(tmp) >= b
            b_ends(b+1:length(tmp)+1) = tmp(b:end);
        end
    end
end

% Make sure we have them all accounted for now
if (length(b_starts) ~= length(nan_starts)) 
    error('Blinks bad');
end
if (length(b_ends) ~= length(nan_ends))

    % Ok, if we're just at the end
    if (length(b_ends) == length(nan_ends)+1) &&...
            (b_ends(end).time == t_epoch(2)-1)        
    else
        error('Blinks bad.');
    end
end

% Set the condition
cond = NM_GetTrialCondition(trial);





