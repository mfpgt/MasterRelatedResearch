%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckLogFile.m
%
% Notes:
%   * This function checks the log file and ensures that the stimuli were 
%       structured how we expected. This includes:
%       - The right number of stimuli per condition were displayed
%       - The right sitmuli was displayed at each trial
%       - All the correct matching was performed
%       - The log record for each trigger is correct
%       - The localizer and baseline runs are correct as well
%       - The timing of the stimuli, as reported in the log
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_CheckLogFile()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckLogFile()

% Load the data and stimuli to check
parseLog();

% This confirms the stimuli shown matched the intended descriptions
checkStimuli();

% This confirms The stimuli were matched on all the proper dimensions
checkMatching();

% Check triggers
checkTriggers();

% Check the localizer
checkLocalizer();

% Check the baseline tasks
checkBaseline();

% And the timing
% NM_CheckTiming('log');

% And resave
disp('Log checked.');
NM_SaveSubjectData({{'log_checked',1}});


function checkBaseline()

checkBaselineStimuli();
checkBaselineTriggers();


function checkBaselineStimuli()

% Make sure we have the right amount
global GLA_subject_data;
checkSimpleBaselineStimuli('blinks', GLA_subject_data.settings.num_blinks);
checkSimpleBaselineStimuli('mouth_movements', GLA_subject_data.settings.num_mouth_movements);
checkSimpleBaselineStimuli('breaths', GLA_subject_data.settings.num_breaths);

% The "hardest" check
if length(GLA_subject_data.data.baseline.eye_movements) ~= ...
        GLA_subject_data.settings.num_eye_movements
    error('Wrong number of eye movements.');
end

% NOTE: Stimuli are not parsed correctly, because they involve spaces
for t = 1:GLA_subject_data.settings.num_eye_movements
    movement_types = zeros(2,1);
    for s = 1:4
        if mod(s,2) == 1 
            if GLA_subject_data.data.baseline.eye_movements(t).log_stims(s).stim_type ~= 1
                error('Bad trial');
            end
        else
            movement_types(s/2) = GLA_subject_data.data.baseline.eye_movements(t).log_stims(s).stim_type;
        end
    end
    movement_types = sort(movement_types);
    if movement_types(1) ~= 2 || movement_types(2) ~= 3
        error('Bad trial.'); 
    end
end
disp('Eye movements are correct.');

% And the easiest
if length(GLA_subject_data.data.baseline.noise) ~= GLA_subject_data.settings.num_noise
    error('Noise is incorrect');
end
disp('Noise is correct.');


function checkSimpleBaselineStimuli(type, num)

global GLA_subject_data;
if length(GLA_subject_data.data.baseline.(type)) ~= num
    error('Wrong number of baseline trials');
end

% Should always alternate back and forth
stims = {'+',''};
for t = 1:length(GLA_subject_data.data.baseline.(type))
    for s = 1:2
        if ~strcmp(GLA_subject_data.data.baseline.(type)(t).log_stims(s).value,stims{s})
            error('Bad stim.');
        end
    end
end
disp([type ' are correct.']);



function checkLocalizer()

% Check block number first
global GLA_subject_data;
if length(GLA_subject_data.data.localizer.blocks) ~= ...
        GLA_subject_data.settings.num_localizer_blocks
    error('Wrong number of localizer blocks');
end

% Might not need anything
if GLA_subject_data.settings.num_localizer_blocks == 0
    return;
end
    
% See if we showed what we wanted to
checkLocalizerStimuli();

% See if we have all the blocks
checkLocalizerMatching();

% See if we have the right triggers
checkLocalizerTriggers();


function checkLocalizerMatching()

checkLocalizerBlockMatching();
checkLocalizerCatchMatching();


function checkLocalizerCatchMatching()

global GLA_subject_data;
catches = {};
for b = 1:GLA_subject_data.settings.num_localizer_blocks
    if ~isempty(GLA_subject_data.data.localizer.blocks(b).params.catch_trial)    
        catches{end+1} = {GLA_subject_data.data.localizer.blocks(b).params.catch_trial{2} ...
            b GLA_subject_data.data.localizer.blocks(b).params.catch_trial{1}}; %#ok<AGROW>
    end
end

if GLA_subject_data.settings.num_localizer_catch_trials ~= length(catches)
    error('Wrong number of catch trials');
end
for c = 1:length(catches)
    if ~strcmp(GLA_subject_data.settings.localizer_catches{(c-1)*3+1},catches{c}{1}) ||...
            str2double(GLA_subject_data.settings.localizer_catches{(c-1)*3+2}) ~= catches{c}{2} ||...
            str2double(GLA_subject_data.settings.localizer_catches{(c-1)*3+3}) ~= catches{c}{3}
        error('Wrong catch trial.');
    end
end
disp('Localizer catch trials as expected.');


function checkLocalizerBlockMatching()

% Not too much to check...
global GLA_subject_data;
conditions = {'sentence','pseudo'};
c_cts = zeros(length(conditions),1);
for b = 1:GLA_subject_data.settings.num_localizer_blocks
    for c = 1:length(conditions)
        if strcmp(GLA_subject_data.data.localizer.blocks(b).params.condition,conditions{c})
            c_cts(c) = c_cts(c)+1;
            
            % Make sure the one before was different
            if b > 1
                if strcmp(GLA_subject_data.data.localizer.blocks(b-1).params.condition,...
                        GLA_subject_data.data.localizer.blocks(b).params.condition)
                    error('Two of the same condition in a row.'); 
                end
            end
        end
    end
end
for c = 2:length(c_cts)
    if c_cts(c) ~= c_cts(1)
        error('Different number of trials.'); 
    end
end
disp('Localizer blocks matched.');

    
function checkLocalizerStimuli()

disp('Checking localizer stimuli...');
global GLA_subject;
global GLA_subject_data;

disp([NM_GetRootDirectory() '/logs/' ...
    GLA_subject '/' GLA_subject '_localizer_stim_list.csv']);

fid = fopen([NM_GetRootDirectory() '/logs/' ...
    GLA_subject '/' GLA_subject '_localizer_stim_list.csv']);
line = fgetl(fid);  %#ok<NASGU> % Header
for b = 1:GLA_subject_data.settings.num_localizer_blocks
    GLA_subject_data.data.localizer.blocks(b).params = ...
        checkLocalizerBlockStims(fgetl(fid), ...
        GLA_subject_data.data.localizer.blocks(b).log_stims);
end
fclose(fid);
disp('Localizer stimuli as expected.');

% Check the timing


function params = checkLocalizerBlockStims(line, stims)

params = parseLocalizerStimLine(line);
params.catch_trial = {};

% Check the parameters
for s = 1:length(stims)
    if stims(s).block_num ~= params.block_num || ...
            ~strcmp(stims(s).condition,params.condition)
        error('Wrong block num.');
    end
end

% Then the stims
s_ctr = 1;
for i = 1:length(params.stims)
    for j = 1:length(params.stims{i})
        if ~NM_IsEqualStim(params.stims{i}{j}, stims(s_ctr).value)
            error('Wrong stim.');
        end
        s_ctr = s_ctr+1;
    end
    
    % Could have a catch trial
    if strcmp(stims(s_ctr).value,'cliquez') || ...
            strcmp(stims(s_ctr).value,'appuyez')
        params.catch_trial = {i,stims(s_ctr).value};
        s_ctr = s_ctr+1;
    end
    
    % Blank in between
    if ~strcmp(stims(s_ctr).value,'+')
        error('Wrong stim.');
    end
    s_ctr = s_ctr+1;
end


function values = parseLocalizerStimLine(line)

% The initial values
[values.block_num line] = parseCSVItem(line); 
values.block_num = str2double(values.block_num);
[values.onset line] = strtok(line,',');
values.onset = str2double(values.onset);
[values.condition line] = parseCSVItem(line);
[blank line] = parseCSVItem(line); %#ok<ASGLU>

% And the stims
values.stims = {};
global GLA_subject_data;
for i = 1:GLA_subject_data.settings.num_localizer_block_stims
    values.stims{i} = {};
    for j = 1:GLA_subject_data.settings.num_localizer_stim_words
        [values.stims{i}{j} line] = parseCSVItem(line); 
    end
    for j = 1:3
        [blank line] = parseCSVItem(line); %#ok<ASGLU>
    end
end

function [val line] = parseCSVItem(line)

% In .csv files, with ""
[val line] = strtok(line,',');
val = val(2:end-1);
val = NeuroMod_ConvertToUTF8(val);


function checkLocalizerTriggers()

% Might have none
global GLA_subject_data;
if ~GLA_subject_data.settings.eeg && ...
        ~GLA_subject_data.settings.meg && ...
        ~GLA_subject_data.settings.eye_tracker 
    return;
end

% Should be all or none
disp('Checking localizer triggers...');
for b = 1:GLA_subject_data.settings.num_localizer_blocks
    checkLocalizerBlockTriggers(GLA_subject_data.data.localizer.blocks(b));
end
disp('All localizer triggers have right value and placement.');


function checkLocalizerBlockTriggers(block)

% Check that we have the right number
if strcmp(block.params.condition,'sentence')
    t_value = 1;
elseif strcmp(block.params.condition,'pseudo')
    t_value = 2;
else
    error('Unknown condition.');
end

% All the words are one value, and the blanks are a different one
offset_t = -1;
t_values = [];
for s = 1:length(block.params.stims)
    for i = 1:length(block.params.stims{s})
        t_values(end+1) = t_value;   %#ok<AGROW>
    end
    % Adjust for catch trials
    if ~isempty(block.params.catch_trial) && block.params.catch_trial{1} == s
        t_values(end+1) = 4; %#ok<AGROW>
        offset_t = length(t_values)+1;
    else
        t_values(end+1) = 3; %#ok<AGROW>
    end
end

% And fill to the end
for t = length(t_values)+1:length(block.log_triggers)
    t_values(t) = 3;  %#ok<AGROW>
end


% Check placements
offset = 0;
for t = 1:length(block.log_triggers)
    if block.log_triggers(t).value ~= t_values(t)
        error('Wrong trigger value.');
    end
    if t == offset_t
        offset = 1;
    end
    checkLocalizerTriggerPlacement(block.log_triggers(t), offset);
end


function checkLocalizerTriggerPlacement(trigger, offset)

global GLA_subject_data;

% Find where it is in the stims
t_stim = findClosetStimToTrigger(trigger,...
    GLA_subject_data.data.localizer.blocks(trigger.block_num).log_stims);

% We trigger everything, so should line up
if ~strcmp(t_stim.value,GLA_subject_data.data.localizer.blocks(trigger.block_num).log_stims(trigger.order+offset).value)
    error('Trigger in wrong place.');
end

function checkBaselineTriggers()

disp('Checking triggers...');
global GLA_subject_data;
for b = {'blinks','breaths','mouth_movements'}
    checkBaselineTypeTriggers(GLA_subject_data.data.baseline.(b{1}));
end

% See how many types we expect
if GLA_subject_data.settings.eye_tracker && ...
        (GLA_subject_data.settings.eeg || GLA_subject_data.settings.meg)
    num_trigger_types = 2;
else
    num_trigger_types = 1;
end

% Check the eye movements
for t = 1:length(GLA_subject_data.data.baseline.eye_movements)

    % Should be two triggers
    trial = GLA_subject_data.data.baseline.eye_movements(t);
    if length(trial.log_triggers) ~= num_trigger_types*2
        error('Bad triggers.');
    end
    for i = 1:2
        if num_trigger_types == 2
            checkTriggerPair(trial.log_triggers(i*2-1), trial.log_triggers(i*2))
            t_ind = i*2-1;
        else
            t_ind = i;
        end
        
        % Should be this way...
        t_stim = findClosetStimToTrigger(trial.log_triggers(t_ind),...
            trial.log_stims);
        if t_stim.stim_type+1 ~= trial.log_triggers(t_ind).value
            error('Bad trigger.');
        end
    end
end
disp('All baseline triggers have right value and placement.');


function checkBaselineTypeTriggers(trials)

global GLA_subject_data;
for t = 1:length(trials)
    
    % Should be only one pair
    if GLA_subject_data.settings.eye_tracker &&...
            (GLA_subject_data.settings.eeg || GLA_subject_data.settings.meg)
        if length(trials(t).log_triggers) ~= 2
            error('Bad triggers.');
        end
        checkTriggerPair(trials(t).log_triggers(1), trials(t).log_triggers(2))
    end
    
    % Should be by the ''
    t_stim = findClosetStimToTrigger(trials(t).log_triggers(1),...
        trials(t).log_stims);
    if ~isempty(t_stim.value)
        error('Bad trigger.');
    end
end

function checkTriggers()

% Might have none
global GLA_subject_data;
if ~GLA_subject_data.settings.eeg && ...
        ~GLA_subject_data.settings.meg && ...
        ~GLA_subject_data.settings.eye_tracker 
    return;
end

disp('Checking triggers...');
for r = 1:length(GLA_subject_data.data.runs)
    for t = 1:length(GLA_subject_data.data.runs(r))
        checkTrialTriggers(GLA_subject_data.data.runs(r).trials(t)); 
    end
end
disp('All triggers have right value and placement.');


function checkTrialTriggers(trial)

% Check if we have paired M/EEG and eyelink triggers
global GLA_subject_data;
if GLA_subject_data.settings.eye_tracker && ...
        (GLA_subject_data.settings.eeg || GLA_subject_data.settings.meg)
    num_trigger_types = 2;
else
    num_trigger_types = 1;     
end
if mod(length(trial.log_triggers),num_trigger_types) ~= 0
    error('Wrong number of triggers.');
end

% If paired, should be the same
if num_trigger_types == 2
    for t = 1:2:length(trial.log_triggers)
        checkTriggerPair(trial.log_triggers(t), trial.log_triggers(t+1));
    end
end

% Use the script creation function to grab the triggers
[stim_trigger critical_trigger delay_trigger probe_trigger] = ...
    NeuroMod_GetTrialTriggerValues(...
    trial.settings.p_l, trial.settings.n_v,...
    trial.settings.cond, trial.settings.answer);

% And transform to what we should have
% NOTE: For both types of triggers...
if num_trigger_types == 2
    t_values(1:8) = stim_trigger;
    t_values(9:10) = critical_trigger;
    t_values(11:12) = delay_trigger;
    t_values(13:14) = probe_trigger;
else    
    t_values(1:4) = stim_trigger;
    t_values(5) = critical_trigger;
    t_values(6) = delay_trigger;
    t_values(7) = probe_trigger;
end

% Check that we have the right number
if length(trial.log_triggers) ~= length(t_values)
    error('Wrong number of triggers.');
end

% And check placements
for t = 1:length(trial.log_triggers)

    % Get the closest stim
    t_stim = findClosetStimToTrigger(trial.log_triggers(t),...
        GLA_subject_data.data.runs(trial.log_triggers(t).run_id).trials(trial.log_triggers(t).trial_num).log_stims);

    % Check the number
    if trial.log_triggers(t).value ~= t_values(t)
        error('Wrong trigger value.');
    end

    % And check
    checkTrigger(trial.log_triggers(t),t_stim,stim_trigger,...
        critical_trigger, delay_trigger, probe_trigger);
end


function checkTrigger(trigger,t_stim,stim_trigger,...
    critical_trigger, delay_trigger, probe_trigger)

% Find out what the stim is
global GLA_subject_data;

% Could be a first stim
for s = 1:GLA_subject_data.settings.num_critical_stim-1
    if strcmp(t_stim.value,t_stim.trial_stim{s})
        if trigger.value == stim_trigger
            return;
        end
    end
end

% Or a critical stim
if strcmp(t_stim.value,t_stim.trial_stim{GLA_subject_data.settings.num_critical_stim})
    if trigger.value == critical_trigger
        return;
    end
end

% Or the probe 
if strcmp(t_stim.value,upper(t_stim.probe))
    if trigger.value == probe_trigger
        return;
    end
end


% Or the delay, which is hard to check for
min_delay = 1.5;    % Nothing else should be this big...
next_stim = GLA_subject_data.data.runs(t_stim.run_id).trials(t_stim.trial_num).log_stims(t_stim.order+1);
if strcmp(t_stim.value,'+') && (next_stim.log_time-t_stim.log_time > min_delay)
    if trigger.value == delay_trigger
        return;
    end    
end

% This means the closest stim is not one that should be triggered
error('Bad trigger.');


function checkTriggerPair(t1, t2)

% Should be all the same except the type
% Good enough to just test the time and value, I think...
if ~strcmp(t1.type,'ParallelPort') || ~strcmp(t2.type,'EyeLink') ||...
        t1.value ~= t2.value || t1.log_time ~= t2.log_time 
    error('Bad trigger pair.');
end

function t_stim = findClosetStimToTrigger(trigger,stims)

t_stim = [];
min_time = 1000;
for s = 1:length(stims)
    time = abs(trigger.log_time - stims(s).log_time);
    if time < min_time
        min_time = time;
        t_stim = stims(s);
    end
end


function checkMatching()

% This confirms:
%   * The right number of runs.
%   * An equal number of trials per condition per run.
checkTrialNumbers();

% This confirms:
%     * An equal number of matching and non-matching trials per condition
%     * An equal number of each non-matching type in each condition
%     * An equal number of matches from each word position (within one)
%     * An equal number of matches from each word position btwn phrase and lists
checkProbes();

% This confirms:
%   * All word appearances are "matched" (i.e. a post_adj appears in an
%       equal number of cond. 1,2,3,4)
%   * Equal number of matched sets for each word between phrases and lists
%   * Equal number of matched sets for each word in a category (within 1)
checkWords();

% This confirms:
%   * The coocurrence of words is more or less random
checkAllCoocurrences();

% This confirms:
%   * No stimuli appear in two trials in a row
checkAllRepetitions();


function checkAllRepetitions()

disp('Checking repetitions...');
global GL_check_stimuli;
s_types = fieldnames(GL_check_stimuli);
for s = 1:length(s_types)
    for w = 1:length(GL_check_stimuli.(s_types{s}))
        checkWordRepetitions(GL_check_stimuli.(s_types{s}){w});
    end
end
disp('Done.');


function checkWordRepetitions(word)

global GLA_subject_data;
filter.trial_stim = {word};
for r = 1:GLA_subject_data.settings.num_runs
    filter.run_id = {r};
    w_trials = NM_FilterTrials(filter);

    % Order
    w_ind = zeros(length(w_trials),1);
    for t = 1:length(w_trials)
        w_ind(t) = w_trials(t).settings.trial_num; 
    end
    w_ind = sort(w_ind);
    if find(diff(w_ind) == 1)
        disp(['WARNING: Repetition of ' word ' in run ' num2str(r) '.']);
    end
end

function checkAllCoocurrences()

disp('Checking coocurrences...');
global GL_check_stimuli;
s_types = fieldnames(GL_check_stimuli);
for s = 1:length(s_types)
    for w = 1:length(GL_check_stimuli.(s_types{s}))
        checkWordCoocurrences(GL_check_stimuli.(s_types{s}){w});
    end
end
disp('Done.');


function checkWordCoocurrences(word)

for p_l = {'all','phrase','list'}
    if strcmp(p_l{1},'all')
        filter.p_l = {};
    else
        filter.p_l = {p_l{1}};
    end
    filter.trial_stim = {word};
    w_trials = NM_FilterTrials(filter);
    num_critical_stim = 5;
    for dist = [-num_critical_stim+1:-1 1:num_critical_stim-1]
        checkCoocurrences(w_trials, word, dist, p_l{1});
    end
end


function checkCoocurrences(w_trials, word, dist, type)

cooccur = {};
global GLA_subject_data;
for t = 1:length(w_trials)
    pos = getWordPos(word,w_trials(t));
    if pos+dist > 0 && pos+dist <= GLA_subject_data.settings.num_critical_stim
        cooccur{end+1} = w_trials(t).settings.trial_stim{pos+dist}; %#ok<AGROW>
    end
end

% Make sure they're not all the same?
% [This is more to look at if we want]
if length(cooccur) < 2
    return;
end

test = cooccur{1};
for c = 1:length(cooccur)
    if ~strcmp(test,cooccur{c})
        return;
    end
end

disp(['WARNING: They''re all the same: ' word ' (' num2str(dist) '), [' type ']']);
cooccur %#ok<NOPRT>


function checkWords()

global GL_check_stimuli;
global GLA_subject_data;
num_trials_per_condition_per_cat = GLA_subject_data.settings.num_trials /...
    GLA_subject_data.settings.num_conditions / GLA_subject_data.settings.num_structure_types;

% Count / check the sets
disp('Counting word sets...');
filter.p_l = {'phrase'};
phrase_set_counts = countAllWordSets(filter,...
    num_trials_per_condition_per_cat/GLA_subject_data.settings.num_structure_types);
filter.p_l = {'list'};
list_set_counts = countAllWordSets(filter,...
    num_trials_per_condition_per_cat/GLA_subject_data.settings.num_structure_types);
disp('All words appeared in sets.');

% Should have exactly the same words in the phrase and list conditions
s_types = fieldnames(GL_check_stimuli);
for s = 1:length(s_types)
    for w = 1:length(GL_check_stimuli.(s_types{s}))    
        if phrase_set_counts.(s_types{s})(w) ~= ...
                list_set_counts.(s_types{s})(w)
            disp(['WARNING: Phrase and list counts mismatch (' ...
                GL_check_stimuli.(s_types{s}){w} ').']);
        end
    end
end 
disp('Done.');


function counts = countAllWordSets(filter,num_trials_per_condition_per_cat)

% Check to make that each word, when it occurs, occurs in every relevant condition
global GL_check_stimuli;
global GLA_subject_data;
filter.cond = {1,2,3,4};
counts.names = countCategoryWordSets(GL_check_stimuli.names,2,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.names));
counts.prep = countCategoryWordSets(GL_check_stimuli.prep,2,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.prep));
counts.det = countCategoryWordSets(GL_check_stimuli.det,3,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.det));
counts.modals = countCategoryWordSets(GL_check_stimuli.modals,3,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.modals));
counts.adj_pre = countCategoryWordSets(GL_check_stimuli.adj_pre,4,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.adj_pre)/GLA_subject_data.settings.num_a_pos);
counts.adv_pre = countCategoryWordSets(GL_check_stimuli.adv_pre,4,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.adv_pre)/GLA_subject_data.settings.num_a_pos);
counts.nouns = countCategoryWordSets(GL_check_stimuli.nouns,4,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.nouns)/GLA_subject_data.settings.num_a_pos);
counts.verbs = countCategoryWordSets(GL_check_stimuli.verbs,4,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.verbs)/GLA_subject_data.settings.num_a_pos);
counts.adj_post = countCategoryWordSets(GL_check_stimuli.adj_post,5,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.adj_post)/GLA_subject_data.settings.num_a_pos);
counts.adv_post = countCategoryWordSets(GL_check_stimuli.adv_post,5,filter,...
    num_trials_per_condition_per_cat/length(GL_check_stimuli.adv_post)/GLA_subject_data.settings.num_a_pos);

% Should have the same number of nouns / verbs in the final position
for s = {'nouns','verbs'}
	alt_counts = countCategoryWordSets(GL_check_stimuli.(s{1}),5,filter,...
        mean(counts.(s{1})));
    for w = 1:length(GL_check_stimuli.(s{1}))
        if alt_counts(w) ~= counts.(s{1})
            error('Wrong number of counts.');
        end
    end
end

% Check the condition 5s...
checkConditionFive(GL_check_stimuli.adj_pre, counts.adj_pre, filter);
checkConditionFive(GL_check_stimuli.adv_pre, counts.adv_pre, filter);
checkConditionFive(GL_check_stimuli.nouns, counts.nouns, filter);
checkConditionFive(GL_check_stimuli.verbs, counts.verbs, filter);


function checkConditionFive(stimuli, counts, filter)

filter.cond = {5};
five_counts = countCategoryWordSets(stimuli,5,filter,mean(counts));
for c = length(five_counts)
    if five_counts(c) ~= counts(c)
        error('Wrong five count.');
    end
end


function counts = countCategoryWordSets(words,pos,filter,expected)
counts = zeros(length(words),1);
for w = 1:length(words)
    counts(w) = countWordSets(words{w},pos,filter);
    if abs(counts(w)-expected) > 1
        disp(['WARNING: Wrong number of sets. (' words{w} ')']);
    end
end

function count = countWordSets(word, pos, filter)

filter.trial_stim = {word};
w_trials = NM_FilterTrials(filter);

w_cond = [];
for t = 1:length(w_trials)
    if getWordPos(word,w_trials(t)) == pos
        w_cond(end+1) = w_trials(t).settings.cond; %#ok<AGROW>
    end
end

% Make sure each occurrence is in each condition
conds = unique(w_cond);
if isempty(conds)
    count = 0;
else
    count = length(find(w_cond == conds(1)));
end
for c = 2:length(conds)
    if length(find(w_cond == conds(1))) ~= count
        error('Not a full set.');
    end
end


function pos = getWordPos(word,trial)

global GLA_subject_data;
pos = -1;
for s = 1:GLA_subject_data.settings.num_critical_stim
    if strcmp(word,trial.settings.trial_stim{s})
        pos = s;
        return;
    end
end


function checkProbes()

disp('Checking the probes...');

% TODO: Maybe move this earlier. And save...
addProbePosition();

% Make sure the probe types are equal
checkProbeAnswers();
disp('Equal number of answers.');

% Make sure the correct probes come from all possible positions equally
filter = {};
global GLA_subject_data;
% 2 - because match only
exp_total = GLA_subject_data.settings.num_trials / GLA_subject_data.settings.num_conditions /...
    GLA_subject_data.settings.num_structure_types / 2;
checkProbePositions(filter, exp_total);

% Traded approximate matching of noun / verbs x phrase / list
%   for exact matching of phrase / list and less matched noun / verbs
% exp_total = exp_total/2;
% for n_v = {'noun','verb'}
%     filter.n_v = {n_v{1}};
%     checkProbePositions(trials, filter, exp_total);
% end
disp('Equal number of probes in each position.');


function checkProbePositions(filter, exp_total)

% Should be correct (within 1) for each condition
filter.p_l = {'phrase'};
phrase_counts = getProbePositionCounts(filter, exp_total);
filter.p_l = {'list'};
list_counts = getProbePositionCounts(filter, exp_total);

% Should be exactly the same position distribution for phrase and list
global GLA_subject_data;
for c = 1:GLA_subject_data.settings.num_conditions
    for p = 1:GLA_subject_data.settings.num_critical_stim
        if phrase_counts(c,p) ~= list_counts(c,p)
            disp('WARNING: Different number of probe positions.');
        end
    end
end


function counts = getProbePositionCounts(filter, exp_total)

% Check for equal number of probes in each position, for each condition
global GLA_subject_data;
counts = zeros(GLA_subject_data.settings.num_conditions, ...
    GLA_subject_data.settings.num_critical_stim);
for c = 1:GLA_subject_data.settings.num_conditions
    filter.answer = {'match'};
    filter.cond = {c};

    % Check each viable position
    if c == 5
        pos = GLA_subject_data.settings.num_critical_stim;
    else
        pos = GLA_subject_data.settings.num_critical_stim-c+1:GLA_subject_data.settings.num_critical_stim;
    end
    for p = pos
        filter.p_pos = {p};
        counts(c,p) = length(NM_FilterTrials(filter)); 
        
        % Not always exact
        if abs(counts(c,p) - exp_total/length(pos)) > 1
            disp(['Warning: expected ' num2str(exp_total/length(pos)) ...
                ' and found ' num2str(length(NM_FilterTrials(filter))) '.']);
        end
    end
end



function addProbePosition()

global GLA_subject_data;
for r = 1:GLA_subject_data.settings.num_runs
    for t = 1:GLA_subject_data.settings.num_trials / GLA_subject_data.settings.num_runs
        if strcmp(GLA_subject_data.data.runs(r).trials(t).settings.answer,'match')
            for s = 1:GLA_subject_data.settings.num_critical_stim
                if strcmp(GLA_subject_data.data.runs(r).trials(t).settings.probe,...
                        GLA_subject_data.data.runs(r).trials(t).settings.trial_stim{s})
                    p_pos = s;
                    break;
                end
            end
        else
            p_pos = -1;
        end
        
        % Add to the global for later saving
        GLA_subject_data.data.runs(r).trials(t).settings.p_pos = p_pos;
    end
end


function checkProbeAnswers()

% Should be same number of match / nomatch for phrase / list and
%   noun / verb subdivisions. 
%   * Same is true for the two nomatch types
global GLA_subject_data;
for c = 1:GLA_subject_data.settings.num_conditions
    for p_l = {'phrase','list'}
        for n_v = {'noun','verb'}
            
            expected = GLA_subject_data.settings.num_trials / GLA_subject_data.settings.num_conditions /...
                GLA_subject_data.settings.num_structure_types / GLA_subject_data.settings.num_phrase_types;
            filter.p_l = {p_l{1}};
            filter.cond = {c};
            filter.n_v = {n_v{1}};
            filter.answer = {'match'};
            expected = expected / 2;
            if (length(NM_FilterTrials(filter)) ~= expected)
                error('Wrong number of matches');
            end
            for a = {'nomatch_1','nomatch_2'}
                filter.answer = {a{1}}; 
                if (length(NM_FilterTrials(filter)) ~= (expected/GLA_subject_data.settings.num_nomatch_types))
                    error('Wrong number of nomatches');
                end
            end
        end
    end
end


function checkTrialNumbers()

% Check the basics
global GLA_subject_data;
disp('Checking trial counts...');
if length(GLA_subject_data.data.runs) ~= GLA_subject_data.settings.num_runs
    error('Wrong number of runs.');
end

% Check the conditions per run 
for p_l = {'phrase','list'}
    for n_v = {'noun','verb'}
        for c = 1:GLA_subject_data.settings.num_conditions
            filter.p_l = {p_l{1}};
            filter.cond = {c};
            filter.n_v = {n_v{1}};
            expected = GLA_subject_data.settings.num_trials / GLA_subject_data.settings.num_conditions /...
                GLA_subject_data.settings.num_structure_types / GLA_subject_data.settings.num_phrase_types;
            for r = 1:GLA_subject_data.settings.num_runs
                filter.run_id = {r};
                if (length(NM_FilterTrials(filter)) ~= (expected/GLA_subject_data.settings.num_runs))
                    error('Wrong number of trials.');
                end
            end
            filter.run_id = {};
            for a_p = 1:2
                filter.a_p = {a_p};
                if (length(NM_FilterTrials(filter)) ~= (expected/GLA_subject_data.settings.num_a_pos))
                    error('Wrong number of trials.');
                end
            end
            filter.a_p = {};
        end
    end
end
disp('Correct number of trials.');


function checkStimuli()

% Now check each trial description to make sure we got what we think we got
disp('Checking the stimuli...');
global GLA_subject_data;
if length(GLA_subject_data.data.runs) ~= GLA_subject_data.settings.num_runs
    error('Wrong number of runs.');
end
for r = 1:length(GLA_subject_data.data.runs)
    
    % And a quick check of the trial numbers
    if length(GLA_subject_data.data.runs(r).trials) ~= ...
            round(GLA_subject_data.settings.num_trials / ...
                GLA_subject_data.settings.num_runs)
        error('Wrong number of trials.');
    end
    
    % Check and consolidate
    for t = 1:length(GLA_subject_data.data.runs(r).trials)
        checkTrialStimuli(GLA_subject_data.data.runs(r).trials(t).log_stims);
    end
end

% Can can consolidate now
consolidateAllTrialParameters();
disp('All stimuli as expected.');


function consolidateAllTrialParameters()

global GLA_subject_data;
for r = 1:length(GLA_subject_data.data.runs)
    c_trials = {};
    for t = 1:length(GLA_subject_data.data.runs(r).trials)
        c_trials = NM_AddStructToArray(...
            consolidateTrialParameters(GLA_subject_data.data.runs(r).trials(t)), c_trials);
    end
    GLA_subject_data.data.runs(r).trials = c_trials;
end

function trial = consolidateTrialParameters(trial)

trial.settings.run_id = trial.log_stims(1).run_id;
trial.settings.trial_num = trial.log_stims(1).trial_num;
trial.settings.n_v = trial.log_stims(1).n_v;
trial.settings.p_l = trial.log_stims(1).p_l;
trial.settings.cond = trial.log_stims(1).cond;
trial.settings.a_p = trial.log_stims(1).a_p;
trial.settings.answer = trial.log_stims(1).answer;
trial.settings.trial_stim = trial.log_stims(1).trial_stim;
trial.settings.probe = trial.log_stims(1).probe;



function checkTrialStimuli(stims)

% Make sure all the descriptions are the same
[n_v p_l a_p cond trial_stim answer probe] = checkTrialStimDescriptions(stims);

checkStims(n_v, p_l, a_p, cond, trial_stim);
checkProbe(probe, trial_stim, cond, answer,n_v, p_l, a_p);


function checkProbe(probe, stim, cond, answer,n_v, p_l, a_p)

probe_exp = setProbeExpectations(stim, cond, answer,n_v, p_l, a_p);
if ~checkArray(probe,probe_exp)
    error('Bad stim');
end


function probe_exp = setProbeExpectations(stims,cond,answer,n_v, p_l, a_p)

% Depends on the answer
switch answer
    case 'match'
        probe_exp = setMatchProbeExpectations(stims, cond);

    case 'nomatch_1'
        probe_exp = setNomatchProbeExpectations_1(stims,...
            n_v, p_l, a_p, cond);
        
    case 'nomatch_2'
        probe_exp = setNomatchProbeExpectations_2(...
            n_v, p_l, a_p, cond);
end



% This expects the probe from a category NOT shown in
%   the trial
function probe_exp = setNomatchProbeExpectations_2(...
    n_v, p_l, a_p, cond)

% Get what we expect
exp = setExpectations(n_v, p_l, a_p,cond);

% Add only those not in the expectations
global GL_check_stimuli;
probe_exp = {};
stim_types = fieldnames(GL_check_stimuli);
for s = 1:length(stim_types)
    probe_exp = addNotUsed(probe_exp,GL_check_stimuli.(stim_types{s}),exp);
end


function probe_exp = addNotUsed(probe_exp,possible,exp)

% Either all of the possible words are expected or none
%   of them are. So, just check the first one
for e = 1:length(exp)
    for w = 1:length(exp{e})
        if strcmp(possible{1},exp{e}{w})
            return;
        end
    end
end

% Not expected, so add
for p = 1:length(possible)
    probe_exp{end+1} = possible{p}; %#ok<AGROW>
end

        
% This expects a probe from the categories used in the trial.
function probe_exp = setNomatchProbeExpectations_1(stims,...
    n_v, p_l, a_p, cond)

% Get what we expect
exp = setExpectations(n_v, p_l, a_p,cond);

% Only add those not used in the trial
probe_exp = {};
for e = 1:length(exp) 
    for w = 1:length(exp{e})
        used = 0;
        for s = 1:length(stims)
            if strcmp(stims{s},exp{e}{w})
                used = 1;
                break;
            end
        end
        if ~used
            probe_exp{end+1} = exp{e}{w}; %#ok<AGROW>
        end
    end
end


% Simply expects a probe from the trial
function probe_exp = setMatchProbeExpectations(stims, cond)

global GLA_subject_data;
if cond < GLA_subject_data.settings.num_conditions
    probe_exp = {stims{GLA_subject_data.settings.num_critical_stim-cond:GLA_subject_data.settings.num_conditions}}; %#ok<*CCAT1>
else
    probe_exp = {stims{GLA_subject_data.settings.num_conditions}};
end


function checkStims(n_v, p_l, a_p, cond, stim)

% Get the expectations based on the descriptions
exp = setExpectations(n_v, p_l, a_p, cond);

for i = 1:length(exp)
    
    % Empty expectation means any consonant string
    if isempty(exp{i})
        if ~isConsonant(stim{i})
            error('Bad stim');
        end
        
    % Otherwise, check the expectation
    else
        if ~checkArray(stim{i},exp{i})
            error('Bad stim');
        end
    end
end



function val = isConsonant(item)

% Simply check all of the words...
val = 1;
global GL_check_stimuli;
stim_types = fieldnames(GL_check_stimuli);
for s = 1:length(stim_types)
    if checkArray(item,GL_check_stimuli.(stim_types{s}))
        val = 0;
        return;
    end
end

function found = checkArray(item, array)

found = 0;
for a = 1:length(array)
    if strcmp(item,array{a})
        found = 1;
        return;
    end
end


function exp = setExpectations(n_v, p_l, a_p, cond)

% Don't know a smarter way...
global GL_check_stimuli;
if strcmp(n_v,'noun') && strcmp(p_l,'phrase')
    if a_p == 1
        exp = {[],GL_check_stimuli.prep, GL_check_stimuli.det,...
            GL_check_stimuli.adj_pre, GL_check_stimuli.nouns};
    else
        exp = {[],GL_check_stimuli.prep, GL_check_stimuli.det,...
            GL_check_stimuli.nouns, GL_check_stimuli.adj_post};
    end
elseif strcmp(n_v,'noun') && strcmp(p_l,'list')
    if a_p == 1
        exp = {[],GL_check_stimuli.names, GL_check_stimuli.det,...
            GL_check_stimuli.adv_pre, GL_check_stimuli.nouns};
    else
        exp = {[],GL_check_stimuli.prep, GL_check_stimuli.modals,...
            GL_check_stimuli.nouns, GL_check_stimuli.adv_post};
    end
elseif strcmp(n_v,'verb') && strcmp(p_l,'phrase')
    if a_p == 1
        exp = {[],GL_check_stimuli.names, GL_check_stimuli.modals,...
            GL_check_stimuli.adv_pre, GL_check_stimuli.verbs};
    else
        exp = {[],GL_check_stimuli.names, GL_check_stimuli.modals,...
            GL_check_stimuli.verbs, GL_check_stimuli.adv_post};
    end
else
    if a_p == 1
        exp = {[],GL_check_stimuli.prep, GL_check_stimuli.modals,...
            GL_check_stimuli.adj_pre, GL_check_stimuli.verbs};
    else
        exp = {[],GL_check_stimuli.names, GL_check_stimuli.det,...
            GL_check_stimuli.verbs, GL_check_stimuli.adj_post};        
    end    
end

% Set consonant places to []
exp = removeConsonantPlaces(exp, cond);


function exp = removeConsonantPlaces(exp, cond)

switch cond
    case 1
        exp{2} = []; exp{3} = []; exp{4} = [];
        
    case 2
        exp{2} = []; exp{3} = []; 
        
    case 3
        exp{2} = []; 
        
    case 4
        
    case 5
        exp{5} = exp{4};
        exp{2} = []; exp{3} = []; exp{4} = [];
end


function [n_v p_l a_p cond trial_stim answer probe] = checkTrialStimDescriptions(stims)

global GLA_subject_data;
n_v = stims(1).n_v; p_l = stims(1).p_l; 
a_p = stims(1).a_p; cond = stims(1).cond;
answer = stims(1).answer; trial_stim = stims(1).trial_stim;
probe = stims(1).probe;

% This is what we expect...
if ~NM_IsEqualStim(stims(1).value,'+') || ~NM_IsEqualStim(stims(2).value,trial_stim{1}) ||...
    ~NM_IsEqualStim(stims(3).value,'+') || ~NM_IsEqualStim(stims(4).value,trial_stim{2}) ||...
    ~NM_IsEqualStim(stims(5).value,'+') || ~NM_IsEqualStim(stims(6).value,trial_stim{3}) ||...
    ~NM_IsEqualStim(stims(7).value,'+') || ~NM_IsEqualStim(stims(8).value,trial_stim{4}) ||...
    ~NM_IsEqualStim(stims(9).value,'+') || ~NM_IsEqualStim(stims(10).value,trial_stim{5}) ||...
    ~NM_IsEqualStim(stims(11).value,'+') || ~NM_IsEqualStim(stims(12).value,'+') ||...
    ~NM_IsEqualStim(stims(13).value,upper(probe))  
        error('Bad trial.');
end

% Then make sure all the rest are the same
for s = 2:GLA_subject_data.settings.num_all_stim
    if ~strcmp(n_v,stims(s).n_v) || ~strcmp(p_l,stims(s).p_l) || ...
            a_p ~= stims(s).a_p || cond ~= stims(s).cond || ...
            ~strcmp(answer,stims(s).answer)
        error('Trial description mismatch.');
    end
    for i = 1:GLA_subject_data.settings.num_critical_stim
        if ~strcmp(trial_stim{i},stims(s).trial_stim{i})
            error('Trial stim mismatch.');
        end
    end
end


% Helper to check the log and data file of a run

function parseLog()

% Don't need to pass these everywhere
global GL_check_stimuli;
GL_check_stimuli.prep = NeuroMod_ReadStimFile('prepositions');
GL_check_stimuli.det = NeuroMod_ReadStimFile('determiners');
GL_check_stimuli.adj_pre = NeuroMod_ReadStimFile('adj_pre');
GL_check_stimuli.nouns = NeuroMod_ReadStimFile('nouns');
GL_check_stimuli.adj_post = NeuroMod_ReadStimFile('adj_post');
GL_check_stimuli.names = NeuroMod_ReadStimFile('firstnames');
GL_check_stimuli.modals = NeuroMod_ReadStimFile('modals');
GL_check_stimuli.adv_pre = NeuroMod_ReadStimFile('adv_pre');
GL_check_stimuli.verbs = NeuroMod_ReadStimFile('verbs');
GL_check_stimuli.adv_post = NeuroMod_ReadStimFile('adv_post');

% Load / create the data
global GLA_subject;
global GLA_subject_data;
disp(['Parsing log file for ' GLA_subject '...']);
NM_LoadSubjectData();

% Load the runs
GLA_subject_data.data.runs = parseRuns();

% Then the localizer
GLA_subject_data.data.localizer = parseLocalizer();

% And the baseline
GLA_subject_data.data.baseline = parseBaseline();



% Any baseline data log
function baseline = parseBaseline()

for b = {'blinks','eye_movements','noise','mouth_movements','breaths'}
    baseline.(b{1}) = parseRun(b{1});
end


% Then the localizer
function localizer = parseLocalizer()
localizer.blocks = parseRun('localizer');



function runs = parseRuns()

% Slow but automatic...
runs = {};
while 1
    next_run.trials = parseRun(length(runs)+1);
    if ~isempty(next_run.trials)
        runs = NM_AddStructToArray(next_run, runs);
    else
        break; 
    end
end



function trials = parseRun(run_id)

% Set the options for the run type
global GLA_subject;
disp(['Parsing run ' num2str(run_id) '...']);
fid = fopen([NM_GetRootDirectory() '/logs/' ...
    GLA_subject '/' GLA_subject '_log.txt']);
line = findLine(fid,{{{'ANY'},{'ANY'},{'ANY'},{'ANY'},run_id,1}});

% Find the start
trials = {};
while ~isempty(line) && ischar(line)
    [next_trial line] = parseTrial(line, run_id, length(trials)+1, fid);
    if ~isempty(next_trial) && ~isempty(next_trial.log_stims) && ...
            ((ischar(run_id) && strcmp(run_id,next_trial.log_stims(1).run_id)) ||...
            (isnumeric(run_id) && run_id == next_trial.log_stims(1).run_id))
        trials = NM_AddStructToArray(next_trial, trials);
    else
        break;
    end    
end
disp(['Parsed run ' num2str(run_id) ' with '...
    num2str(length(trials)) ' trials.']);
fclose(fid);



function [trial line] = parseTrial(line,r,t, fid)

trial.log_stims = {};
trial.log_triggers = {};
while 1
    
    % Parse to the end of the trial
    item = parseLogLine(line,r,t);
    
    % See if we've reached a log end
    if isempty(item)
        break;
    end

    % See if we're done with the trial
    if item.trial_num ~= t
        break;
    end
    
    % Or the run
    if (ischar(r) && ~strcmp(r,item.run_id)) ||...
            (isnumeric(r) && r ~= item.run_id)
        break;
    end
        
    
    % Add it to the correct list
    switch item.label
        case 'STIM'
            item.order = length(trial.log_stims)+1;
            trial.log_stims = NM_AddStructToArray(item, trial.log_stims); 

        case 'TRIGGER'
            item.value = str2double(item.value);
            item.order = length(trial.log_triggers)+1;
            trial.log_triggers = NM_AddStructToArray(item, trial.log_triggers); 

        case 'ignored_line'
            % Nothing to do with these...
            
        case 'STIM_PREPARE'
            % Nothing to do with these...
            
        otherwise
            error('Unknown log file line.');
    end
    line = fgetl(fid);
end

function item = parseLogLine(line, run, t_num)

% Might be nothing to do
if isempty(line) || ~ischar(line)
    item = [];
    return;
end

% See which we're parsing
if ischar(run)
    if strcmp(run,'localizer')
        item = parseLocalizerLine(line, run, t_num);
    elseif strcmp(run, 'blinks') || strcmp(run, 'eye_movements') ||...
            strcmp(run, 'noise') || strcmp(run, 'mouth_movements') ||...
            strcmp(run, 'breaths') 
        item = parseBaselineLine(line, run, t_num);
    else
        error('Bad run type.');        
    end
else
    if run > 0
        item = parseRunLine(line,run,t_num);
    else
        error('Bad run num.');
    end
end


function item = parseBaselineLine(line,run,t_num)

C = textscan(line,'%s%s%s%f%s%d%d%d');

% Blanks are structured differently for now....
if isIgnored(C)
    item.label = 'ignored_line';
    item.trial_num = t_num;
    item.run_id = run;
    return;
end

% Unfortunately, some of these are "blanks" which 
%   don't parse right
if isempty(C{4})
    C = textscan(line,'%s%s%f%s%d%d%d');
    for i = length(C):-1:4
        C{i} = C{i-1};
    end
    C{3} = {''};
end

item.label = C{1}{1};
item.type = C{2}{1};
item.value = C{3}{1};
item.log_time = C{4};
item.run_id = C{5}{1};
item.trial_num = C{6};
item.stim_type = C{7};



function item = parseLocalizerLine(line,run,t_num)

C = textscan(line,'%s%s%s%f%s%d%s%s');

% Blanks are structured differently for now....
if isIgnored(C)
    item.label = 'ignored_line';
    item.trial_num = t_num;
    item.run_id = run;
    return;
end
item.label = C{1}{1};
item.type = C{2}{1};
item.value = NeuroMod_ConvertToUTF8(C{3}{1});
item.log_time = C{4};
item.run_id = C{5}{1};
item.trial_num = C{6};
item.block_num = C{6};
item.condition = C{7}{1};
item.stim = NeuroMod_ConvertToUTF8(C{8}{1});



function item = parseRunLine(line,run,t_num)

num_critical_stim = 5;
C = textscan(line,'%s%s%s%f%d%d%s%s%d%d%s%s%s%s%s%s%s');

% Blanks are structured differently for now....
if isIgnored(C)
    item.label = 'ignored_line';
    item.run_id = run;
    item.trial_num = t_num;
    return;
end
item.label = C{1}{1};
item.type = C{2}{1};
item.value = NeuroMod_ConvertToUTF8(C{3}{1});
item.log_time = C{4};
item.run_id = C{5};
item.trial_num = C{6};
item.n_v = C{7}{1};
item.p_l = C{8}{1};
item.cond = C{9};
item.a_p = C{10};
item.answer = C{11}{1};
item.trial_stim = {};
for s = 1:num_critical_stim
    item.trial_stim{s} = NeuroMod_ConvertToUTF8(C{11+s}{1});
end
item.probe = NeuroMod_ConvertToUTF8(C{17}{1});


function is = isIgnored(parse)

% Ignoring blanks and cleanup lines
is = (strcmp(parse{2}{1},'Blank')) ||...
    (strcmp(parse{2}{1},'Cleanup')) ||...
    (strcmp(parse{2}{1},'Paragraph'));


function line = findLine(fid,value_sets)

line = '';
while ischar(line)
    line = fgetl(fid);

    % Check each of the sets
    for v = 1:length(value_sets)
        found = testValueSet(line, value_sets{v});
        if found
            return;
        end
    end
end

% Signal failure
line = '';


function found = testValueSet(line, values)

found = 1;
for v = 1:length(values)
    if isempty(line)
        found = 0;
        return;
    end
    [test_val line] = strtok(line); %#ok<STTOK>
    if ischar(values{v})
        if ~strcmp(values{v}, test_val)
            found = 0;
            return;
        end
    elseif isnumeric(values{v})
        if values{v} ~= str2double(test_val)
            found = 0;
            return;
        end
    else
        switch values{v}{1}
            case 'ANY'
                continue;

            otherwise
                error('Unknown value.');
        end
    end
end





