%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckTiming.m
%
% Notes:
%   * This function checks the timing of the various stimuli and triggers 
%       during the actual experiment run against the expected timing.
%   * This is first called during the NM_Check* functions.
%       - It will break if called before these have completed.
%
% Inputs:
%   * type: What we're checking:
%       - 'log': The stimuli recorded in the log
%       - 'meg': The meg triggers
%       - 'eeg': The eeg triggers
%       - 'diode': The diode stimuli markers
%       - 'et': The eye tracker triggers 
%
% Outputs:
% Usage: 
%   * NM_CheckTiming('log')
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckTiming(type)

% Keep track of the check
global GLA_subject;
disp(['Checking timing for ' type ' timing for ' GLA_subject '...']);
fid = fopen([NM_GetRootDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_timing_report.txt'],'a');

% No loading because we should be 
%   in the middle of checking one of the data types
global GLA_subject_data;
for r = 1:GLA_subject_data.settings.num_runs
    checkRunTiming(r, type, fid);
end
fclose(fid);
disp('Done.');


function checkRunTiming(r, trigger_type, fid)

global GLA_subject_data;

% Get the intervals
GLA_subject_data.data.runs(r).timing.([trigger_type '_intervals']) = getRunIntervals(trigger_type,r);

% Store some summaries
GLA_subject_data.data.runs(r).timing.([trigger_type '_interval_means']) = ...
    mean(GLA_subject_data.data.runs(r).timing.([trigger_type '_intervals']));
GLA_subject_data.data.runs(r).timing.([trigger_type '_interval_stds']) = ...
    std(GLA_subject_data.data.runs(r).timing.([trigger_type '_intervals']));

% These are the times we expect, in ms
switch trigger_type

    % Log has them all
    case 'log'
        exp_labels = {'fixation','stim_1','ISI_1','stim_2','ISI_2','stim_3','ISI_3',...
            'stim_4','ISI_4','stim_5','ISI_5','delay'};
        exp_times = [600 200 400 200 400 200 400 200 400 200 400 2000];

    % Diode has most of them
    case 'diode'
        exp_labels = {'stim_1','ISI_1','stim_2','ISI_2','stim_3','ISI_3',...
            'stim_4','ISI_4','stim_5','ISI_5+delay'};
        exp_times = [200 400 200 400 200 400 200 400 200 2400];

    % All of the other triggers have one per stim
    otherwise
        exp_labels = {'stim_1+ISI_1','stim_2+ISI_2','stim_3+ISI_3',...
            'stim_4+ISI_4','stim_5+ISI_5','delay'};
        exp_times = [600 600 600 600 600 2000];

end
tolerance = 5;
    
% And check them
for s = 1:length(exp_times)
    checkStimulusTiming(GLA_subject_data.data.runs(r).timing.([trigger_type '_interval_means'])(s),...
        GLA_subject_data.data.runs(r).timing.([trigger_type '_interval_stds'])(s),...
        exp_times(s),exp_labels{s},trigger_type, tolerance, fid);
end



function checkStimulusTiming(observed, deviation, ideal, ...
    label, type, tolerance, fid)

% Convert for log times...
if strcmp(type,'log')
    observed = 1000*observed;
    deviation = 1000*deviation;
end

if abs(observed - ideal) > tolerance
    warn_str = ['WARNING: ' type ' timing is bad for ' label '. Got ' ...
        num2str(observed) ' and expected ' num2str(ideal) '.'];
    disp(warn_str);
    fprintf(fid,[warn_str '\n']);
end

rep_str = [type ': ' label ' timing error: ' num2str((observed-ideal)) 'ms ['...
    num2str(deviation) 'ms std.]'];
disp(rep_str);
fprintf(fid,[rep_str '\n']);



function intervals = getRunIntervals(type, num)

global GLA_subject_data;
for t = 1:length(GLA_subject_data.data.runs(num).trials)
    ints = getTrialIntervals(type, GLA_subject_data.data.runs(num).trials(t));
    
    % Timeouts have fewer intervals
    % Let's hope that's what's going on here.
    % To know for sure we'd have to interleave checks...
    if exist('intervals','var') && length(ints) < size(intervals,2)
        ints = [ints 0];    %#ok<AGROW> % Timeouts should be only one short
    end
    
    % Final trial can have many more
    if t == length(GLA_subject_data.data.runs(num).trials)
        ints = ints(1:size(intervals,2));
    end
    intervals(t,:) = ints; %#ok<AGROW>
    
    % And the ITI
    if t < length(GLA_subject_data.data.runs(num).trials)
        intervals(t,end) = getTime(type, GLA_subject_data.data.runs(num).trials(t+1), 1) -...
            getTime(type, GLA_subject_data.data.runs(num).trials(t), size(intervals,2)); %#ok<AGROW>

    % Just set to the mean if there is no ITI
    else
        intervals(t,end) = mean(intervals(1:end-1,end)); %#ok<AGROW>
    end
end


function intervals = getTrialIntervals(type, trial)

ctr = 1;
intervals = [];
while getTime(type,trial,ctr+1) > 0
    intervals(end+1) = getTime(type, trial, ctr+1) -...
        getTime(type, trial, ctr); %#ok<AGROW>
    ctr = ctr+1;
end

% For the ITI
intervals(end+1) = 0;


function time = getTime(type, trial, pos)

switch type
    case 'log'
        measures = trial.log_stims;
        
    case 'meg'
        measures = trial.meg_triggers;
        
    case 'eeg'
        measures = trial.eeg_triggers;
        
    case 'et'
        measures = trial.et_triggers;
        
    case 'diode'
        measures = trial.diode_times;
        
    otherwise
        error('Unknown type');
end    

if pos > length(measures)
    time = -1;
    
% This one is different...
elseif strcmp(type,'diode')
    time = measures(pos);
else
    time = measures(pos).([type '_time']);
end


