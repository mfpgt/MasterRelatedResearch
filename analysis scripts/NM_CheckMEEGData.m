%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckMEEGData.m
%
% Notes:
%   * Reads in the triggers from the M/EEG file
%   * Adds m/eeg_trigger structures to the GLA_subject_data, with:
%       - m/eeg_time: The time of the trigger according to the acquisition computer.
%       - value: The decimal number (1-256) of the trigger.
%   * EEG triggers just have a problem
%       - Missing triggers are automatically added based on the relative 
%           log timing. 
%           - This is probably close because we make sure we find the first
%               trigger either automatically, or manually be inspecting the
%               data file and adding the value to the
%               meeg_subject_notes.txt file. 
%   * For meg, the diodes are also identified.
%       - Their time and value are also added to the GLA_subject_data 
%   * The timing of these triggers (and diodes) is checked as well.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_CheckMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckMEEGData()

% See if we need to do this
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'meeg')
    return;
end

% Make sure we're parsed
NM_LoadSubjectData({{'log_checked',1}});

global GLA_subject_data;
global GLA_meeg_type;
global GLA_subject;

disp(GLA_meeg_type)

if ~GLA_subject_data.settings.(GLA_meeg_type)
    return;
end

disp(['Checking ' GLA_meeg_type ' data for ' GLA_subject '...']);

% Check the runs
for r = 1:GLA_subject_data.settings.num_runs
    triggers = parseRun(['run_' num2str(r)]);
    GLA_subject_data.data.runs(r).trials = checkRunTriggers(...
        GLA_subject_data.data.runs(r).trials,triggers);
end 

% Check the baseline
triggers = parseRun('baseline');

% NOTE: Will need to generalize if order of baseline tasks changes or are
% not parsed in order
last_t_ind = 0;
b_tasks = fieldnames(GLA_subject_data.data.baseline);
for b = 1:length(b_tasks)
    
    if ~isempty(GLA_subject_data.data.baseline.(b_tasks{b}))
        if ~isempty(triggers)
            triggers = triggers(last_t_ind+1:end);
        end
        [GLA_subject_data.data.baseline.(b_tasks{b}) last_t_ind] = ...
            checkRunTriggers(GLA_subject_data.data.baseline.(b_tasks{b}), triggers);
    end
end

% Check the timing
NM_CheckTiming(GLA_meeg_type);

% For MEG data, get the diode timing
if strcmp(GLA_meeg_type,'meg')
    getDiodeTiming(); 
    NM_CheckTiming('diode');
end


% Resave...
NM_SaveSubjectData({{[GLA_meeg_type '_data_checked'],1}});
disp([GLA_meeg_type ' data checked for ' GLA_subject ]);




% If it's good, it'll add it as well as checking
function [trials last_t_ind last_log_trigger_time last_meeg_trigger_time] = ...
    checkRunTriggers(trials, triggers)

global GLA_meeg_type;
disp(['Checking ' GLA_meeg_type ' triggers...']);
last_t_ind = 0;
[last_log_trigger_time  last_meeg_trigger_time] = setFirstTimes(trials(1), triggers);
for t = 1:length(trials)
    [trials(t).([GLA_meeg_type '_triggers']) last_log_trigger_time last_meeg_trigger_time last_t_ind] = ...
        checkTrial(trials(t),triggers,last_log_trigger_time, last_meeg_trigger_time, last_t_ind); 
end
disp('Checked.');


function [last_log_trigger_time  last_meeg_trigger_time] = setFirstTimes(first_trial, triggers)

% Get the first trigger value
global GLA_meeg_type;
for t = 1:length(first_trial.log_triggers)
    if strcmp(first_trial.log_triggers(t).type,'ParallelPort')
        last_log_trigger_time = first_trial.log_triggers(t).log_time;
        first_val = first_trial.log_triggers(t).value;
        break;
    end
end

% Try to find it
global GLA_subject_data;
for t = 1:length(triggers)
    if isEqualValue(first_val, triggers(t).value)
        if t > 5
            % See if we know about it
            is_ok = 0;
            if isfield(GLA_subject_data.settings,'eeg_start_triggers')
                for i = 1:2:length(GLA_subject_data.settings.eeg_start_triggers)
                    if (str2double(GLA_subject_data.settings.eeg_start_triggers{i}) ==...
                            first_trial.settings.run_id) && ...
                            (str2double(GLA_subject_data.settings.eeg_start_triggers{i+1}) == t)
                        is_ok = 1;
                    end
                end
            end
            if ~is_ok
                error('This is probably not right...');
            end
        end
        last_meeg_trigger_time = triggers(t).([GLA_meeg_type '_time']);
        return;
    end
end

% Should manually add start time to the subject notes file
run_id = first_trial.log_stims(1).run_id;
if isfield(GLA_subject_data.settings,'eeg_start_times')
    for t = 1:2:length(GLA_subject_data.settings.eeg_start_times)

        if (isnumeric(run_id) && str2double(GLA_subject_data.settings.eeg_start_times{t}) == run_id) ||...
                (ischar(run_id) && strcmp(GLA_subject_data.settings.eeg_start_times{t}, run_id)) 
             last_meeg_trigger_time = round(str2double(...
                 GLA_subject_data.settings.eeg_start_times{t+1}));
             return;
        end
    end
end
error('No start trigger found.');

function [trial_triggers last_log_trigger_time last_meeg_trigger_time last_t_ind] = ...
    checkTrial(trial,triggers,last_log_trigger_time,last_meeg_trigger_time, last_t_ind)

% Find each one
global GLA_meeg_type;
trial_triggers = {};
for t = 1:length(trial.log_triggers)
    if strcmp(trial.log_triggers(t).type,'ParallelPort')
        
        % Advance the time
        interval = trial.log_triggers(t).log_time - last_log_trigger_time;
        exp_time = round(last_meeg_trigger_time + interval*1000);
        
        % Add the trigger
        [trigger last_t_ind] = findTrigger(triggers, exp_time, ...
            trial.log_triggers(t).value, last_t_ind); 
        trial_triggers = NM_AddStructToArray(trigger,trial_triggers);
        
        % And record the actual time
        last_meeg_trigger_time = trial_triggers(end).([GLA_meeg_type '_time']);
        last_log_trigger_time = trial.log_triggers(t).log_time;
    end
end


function [trigger last_t_ind] = findTrigger(triggers, exp_time, ...
    exp_val, last_t_ind)

global GLA_meeg_type;
max_dist = 1000;
rejected = [];
t_val = 0;
while ~isEqualValue(exp_val, t_val)
    t_ind = findClosestTriggerIndex(triggers, exp_time, ...
        last_t_ind, max_dist, rejected);

    % Might not have found it...
    if t_ind <  0
                
        % So, have to make up...
        disp(['WARNING: Trigger value ' num2str(exp_val) ' at time '...
            num2str(exp_time) ' not found. Inserting...']);
        trigger.([GLA_meeg_type '_time']) = exp_time;
        trigger.value = mod(exp_val,128);
        t_ind = last_t_ind;
    else
        trigger = triggers(t_ind);
        rejected(end+1) = t_ind; %#ok<AGROW>
    end
    t_val = trigger.value;
end
last_t_ind = t_ind;


function t_ind = findClosestTriggerIndex(triggers, exp_time, ...
    last_t_ind, max_dist, rejected)

% Look for the trigger closest to that time.
global GLA_meeg_type;
t_ind = -1;
dist = max_dist;
for t = last_t_ind+1:length(triggers)
    
    % Might have already been rejected
    if any(find(rejected == t))
        continue;
    end
    
    % See if it's closer
    if abs(triggers(t).([GLA_meeg_type '_time']) - exp_time) < dist
        dist = abs(triggers(t).([GLA_meeg_type '_time']) - exp_time);
        t_ind = t;
    end
    
    % They should be in order...
    if triggers(t).([GLA_meeg_type '_time']) > exp_time+max_dist
        return;
    end
end



function is_equal = isEqualValue(log_val, trig_val)

% Might be the same, modulo the EGI annoyance
if mod(log_val,128) == trig_val
    is_equal = 1;
    return;
end

% For EEG, it's just not equal...
global GLA_meeg_type;
if strcmp(GLA_meeg_type,'eeg')
    is_equal = 0;
    return;
end

% Check for extraneous values
%   I.e. if the recorded trigger conatins the right value
bin_log_val = getBinVal(log_val);
bin_trig_val = getBinVal(trig_val);
is_equal = 1;
for i = 1:8
    if strcmp(bin_log_val(i),'1') && ~strcmp(bin_trig_val(i),'1')
        is_equal = 0;
        break;
    end
end


function bin_val = getBinVal(dec_val)

% Convert
bin_val = dec2bin(dec_val);

% And pad
for i = 1:8-length(bin_val);
    bin_val = ['0' bin_val]; %#ok<AGROW>
end
        

function triggers = parseRun(run_id)

global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'
        triggers = parseMEGRun(run_id);
        
    case 'eeg'
        triggers = parseEEGRun(run_id);        
        
    otherwise
        error('Unknown type.');
end
        

% This function obtains all of the relevant trigger values from the .fif files.
function triggers = parseMEGRun(run_id)

% Load it up
disp(['Parsing ' run_id '...']);

% Reads the data for all of the separate on triggers
%   * num_trig_line cells, each with an array of onsets
t_times = readMEGTriggerLines(run_id);

% Orders them into a single array with values
%   * 2xnum_onsets: [time decimal_val_of_line]
t_times = orderMEGTriggers(t_times);

% Condenses the ordered array into triggers
%   * Adds the values that occurred at the same time
t_times = condenseMEGTriggers(t_times);

% And convert them to useable structs
triggers = {};
for t = 1:length(t_times)
    triggers = NM_AddStructToArray(createTriggerStruct(t_times(t,1), t_times(t,2)), triggers);
end
disp(['Found ' num2str(length(triggers)) ' triggers in ' run_id '.']);



function t_times = condenseMEGTriggers(all_t_times)

% Give some leeway, so a new trigger has to be at least 30ms away
min_trig_dist = 30;

% Group and add all times that are the same
curr_time = all_t_times(1,1);
curr_val = all_t_times(1,2);
used = [];
t_times = zeros(0,2);
for t = 2:length(all_t_times)
    
    % Might be starting a new one
    if abs(all_t_times(t) - curr_time) > min_trig_dist
        
        % Store the old one
        t_times(end+1,:) = [curr_time curr_val]; %#ok<AGROW>
        
        % And restart
        curr_time = all_t_times(t,1);
        curr_val = all_t_times(t,2);
        used = curr_val;
        
    % Or continuing an old one
    else
        if isempty(find(used == all_t_times(t,2),1))
            curr_val = curr_val + all_t_times(t,2);   
            used(end+1) = all_t_times(t,2); %#ok<AGROW>
        end
    end
end

% And store the last one
t_times(end+1,:) = [curr_time curr_val]; 


function t_times = orderMEGTriggers(line_t_times)

t_times = zeros(0,2);
for line = 1:length(line_t_times)
    for t = 1:length(line_t_times{line})
        t_times(end+1,:) = [line_t_times{line}(t) 2^(line-1)]; %#ok<AGROW>
    end
end

% And order them
[val ord] = sort(t_times(:,1)); %#ok<ASGLU>
t_times = t_times(ord,:);


function t_times = readMEGTriggerLines(run_id)

% Load the info
global GLA_subject;
file_name = [NM_GetRootDirectory() '/meg_data/' GLA_subject '/'...    
    GLA_subject '_' run_id '_sss.fif'];
hdr = ft_read_header(file_name);

% Get the line indices
num_trigger_lines = 8;
line_inds = zeros(num_trigger_lines,1);
for l = 1:num_trigger_lines
    line_inds(l) = find(strcmp(hdr.label,['STI00' num2str(l)]));
end

% Load all at once, unless we start hitting space issues
disp('Loading trigger line data...');
dat = ft_read_data(file_name,'chanindx',line_inds);
disp('Done.');

% Check all of the trigger lines
t_times = {};
trigger_threshold = 2.5;
for l = 1:num_trigger_lines
    
    % For now, we take them all, and then later filter out extraneous
    % values...
    on_ind = find(dat(l,:) > trigger_threshold);
    if ~isempty(on_ind)
        t_times{l} = on_ind([1, find(diff(on_ind) > 1)+1]); %#ok<AGROW>
    else
        t_times{l} = [];  %#ok<AGROW>
    end
end

% And add extraneous where they were on already
for l = 1:num_trigger_lines
    for l2 = l+1:num_trigger_lines
        t_times{l2}  = unique([t_times{l2} ...
            t_times{l}(dat(l2,t_times{l})>trigger_threshold)]); %#ok<AGROW>
    end
end



% This function obtains all of the relevant trigger values from the .fif files.
function triggers = parseEEGRun(run_id)

% Load it up
disp(['Parsing run ' num2str(run_id) '...']);

% Load the data
global GLA_subject
file_name = [NM_GetRootDirectory() '/eeg_data/' GLA_subject '/'...    
    GLA_subject '_' run_id '.raw'];
[data.head data.event_data] = NM_ReadEGITriggers(file_name);

min_trig_dist = 30;
t_times = [];
for i = 1:length(data.head.eventcode)

    % This is how to identify the trigger lines...
    if strcmp(data.head.eventcode(i,2),'1') || ...
          strcmp(data.head.eventcode(i,2),'2')
        
        % Find and add to the times
        code = str2double(data.head.eventcode(i,2:end))-128;
        onsets = find(data.event_data(i,:)>0)';
        
        % Don't take those that are too close
        last_time = 0;
        for o = 1:length(onsets)
            if onsets(o) > last_time+min_trig_dist
                t_times(end+1,:) = [onsets(o) code]; %#ok<AGROW>
                last_time = onsets(o);
            end
        end
    end
end

% These can be a problem sometimes
triggers = {};
if isempty(t_times)
    return;
end

% And order them
[val ord] = sort(t_times(:,1)); %#ok<ASGLU>
t_times = t_times(ord,:);


% And convert them to useable structs
for t = 1:length(t_times)
    triggers = NM_AddStructToArray(createTriggerStruct(t_times(t,1), t_times(t,2)), triggers);
end
disp(['Found ' num2str(length(triggers)) ' triggers in run ' num2str(run_id) '.']);


function trigger = createTriggerStruct(time, val)

global GLA_meeg_type;
trigger.([GLA_meeg_type '_time']) = time;
trigger.value = val;

% Helper to make sure we're keeping good time

function getDiodeTiming()

% Load the data
disp('Finding diode timing...');

% Find for each run
global GLA_subject_data;
for r = 1:GLA_subject_data.settings.num_runs
    GLA_subject_data.data.runs(r).trials = setRunDiodes(...
        ['run_' num2str(r)], GLA_subject_data.data.runs(r).trials);
end

b_types = {'blinks','eye_movements','noise'};
for t = 1:length(b_types)
    GLA_subject_data.data.baseline.(b_types{t}) = setRunDiodes(...
        'baseline', GLA_subject_data.data.baseline.(b_types{t}));
end
GLA_subject_data.settings.diodes = 1;
disp('Diodes set.');


function trials = setRunDiodes(run_id, trials)

% Get the diode times
d_times = readDiodeTimes(run_id);

% Find the first trigger diode
for d = 1:length(d_times)
    if abs(d_times(d) - trials(1).meg_triggers(1).meg_time) < 200
        d_times = d_times(d:end);
        break;
    end
end


% Check and set
for t = 1:length(trials)
    [trials(t).diode_times d_times] = setTrialDiodes(trials(t), d_times);
end


function [trial_diodes d_times] = setTrialDiodes(trial, d_times)

% Check against each meg trigger
max_delay = 100;     
trial_diodes = [];
for t = 1:length(trial.meg_triggers)

    % Could do this automatically, but faster and more secure to make sure
    % we have all of them and they occur in order
    % NOTE: Always expecting the diode after the trigger.
    next_d_time = d_times(1); 
    if (next_d_time - trial.meg_triggers(t).meg_time) > max_delay ||...
            (next_d_time < trial.meg_triggers(t).meg_time)
        
        % No diode for the delay start
        if t == 6
            continue;
        end
        error('Bad diode time.');
    end
    d_times = d_times(2:end);    
    trial_diodes(end+1) = next_d_time; %#ok<AGROW>

    % Nothing to check the offsets against...
    next_d_time = d_times(1); d_times = d_times(2:end);
    trial_diodes(end+1) = next_d_time; %#ok<AGROW>
end


    

function d_times = readDiodeTimes(run_id)

% Load the info
global GLA_subject;
file_name = [NM_GetRootDirectory() '/meg_data/' GLA_subject '/'...    
    GLA_subject '_' run_id '_sss.fif'];
hdr = ft_read_header(file_name);

% Get the diode index
d_ind = find(strcmp(hdr.label,'MISC004'));

% Load all at once, unless we start hitting space issues
disp('Loading trigger line data...');
dat = ft_read_data(file_name,'chanindx',d_ind);
disp('Done.');

% Get all of the onsets and offsets
diode_threshold = 0.1;
on_ind = find(dat > diode_threshold);
d_times = sort(on_ind([1,find(diff(on_ind) > 1)+1, find(diff(on_ind) > 1)-1, end]));





