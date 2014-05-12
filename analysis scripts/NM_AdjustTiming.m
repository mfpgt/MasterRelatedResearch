%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AdjustTiming.m
%
% Notes:
%   * This function adjusts the timing of the triggers by the delay between
%       the meg trigger and corresponding diode.
%   * All triggers (et, eeg, meg) are adjusted by the same amount.
%   * The new times overwrite the trial.TYPE_trigger.TYPE_time field.
%       - The old times are saved in the trial.TYPE_trigger.unadjusted_TYPE_time
%   * A log of the adjustments is appended to NIP_timing_report.txt
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_AdjustTiming()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AdjustTiming()

% Load the data
global GLA_subject;
disp(['Adjusting timing for ' GLA_subject '...']);
NM_LoadSubjectData({{'log_checked',1},... % Need to have checked the log
    {'meg_data_checked',1},...      % And all the triggers...
    });

% Nothing to do, if no diodes
global GLA_subject_data;
if ~isfield(GLA_subject_data.settings,'diodes') ||...
        GLA_subject_data.settings.diodes == 0
    return;
end

% These are always there if the diodes are...
trigger_types = {'meg'};

% These are sometimes missing...
if GLA_subject_data.settings.eeg
    if ~isfield(GLA_subject_data.settings,'eeg_data_checked') ||...
            ~GLA_subject_data.settings.eeg_data_checked
        error('Need to check eeg data first.');
    end
    trigger_types{end+1} = 'eeg';
end
if GLA_subject_data.settings.eye_tracker
    if ~isfield(GLA_subject_data.settings,'et_data_checked') ||...
            ~GLA_subject_data.settings.et_data_checked
        error('Need to check eye tracker data first.');
    end
    trigger_types{end+1} = 'et';
end


% Don't do it twice
if isfield(GLA_subject_data.settings,'timing_adjusted') && ...
        GLA_subject_data.settings.timing_adjusted
    error('Cannot adjust timing twice.'); 
end

% Record the adjustments
fid = fopen([NM_GetRootDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_timing_report.txt'],'a');

% The run triggers...
all_adjusts = [];
for r = 1:GLA_subject_data.settings.num_runs
    for t = 1:length(GLA_subject_data.data.runs(r).trials)
        [GLA_subject_data.data.runs(r).trials(t) ...
            all_adjusts(end+1:end+length(GLA_subject_data.data.runs(r).trials(t).meg_triggers))] = ...
                readjustTrialTriggers(GLA_subject_data.data.runs(r).trials(t), trigger_types);
    end
end

adj_str = ['Adjusted run triggers by ' num2str(mean(all_adjusts)) ' ms avg. [' ...
    num2str(std(all_adjusts)) ' ms std.]'];
disp(adj_str);
fprintf(fid,[adj_str '\n']);


% And the baseline triggers...
all_adjusts = [];
b_types = {'blinks','eye_movements','noise'};
for b = 1:length(b_types)
    for t = 1:length(GLA_subject_data.data.baseline.(b_types{b}))
        [GLA_subject_data.data.baseline.(b_types{b})(t) ...
            all_adjusts(end+1:end+length(GLA_subject_data.data.baseline.(b_types{b})(t).meg_triggers))] = ...
            readjustTrialTriggers(GLA_subject_data.data.baseline.(b_types{b})(t), trigger_types);
    end
end
adj_str = ['Adjusted baseline triggers by ' num2str(mean(all_adjusts)) ' ms avg. [' ...
    num2str(std(all_adjusts)) ' ms std.]'];
disp(adj_str);
fprintf(fid,[adj_str '\n']);


% And save
fclose(fid);
NM_SaveSubjectData({{'timing_adjusted',1}});
disp('Done.');



function [trial adjusts] = readjustTrialTriggers(trial, trigger_types)

adjusts = zeros(length(trial.meg_triggers),1);
max_adjust = 150;
for t = 1:length(trial.meg_triggers)
        
    % Find the closest diode and set
    t_time = trial.meg_triggers(t).meg_time;
    adjusts(t) = max_adjust+1;
    for d = 1:length(trial.diode_times)
        if abs(trial.diode_times(d) - t_time) < abs(adjusts(t))
            adjusts(t) = trial.diode_times(d) - t_time;
        end
    end

    % Check
    if abs(adjusts(t)) > max_adjust
        
        % Might be the delay, so just use the average so far...
        if t == 6
             adjusts(t) = round(mean(adjusts(1:t-1)));
        else
            error('Adjustment too big.');
        end
    end
    
    % And reset them 
    for i = 1:length(trigger_types)
        
        % Make sure we have them
        if isfield(trial,[trigger_types{i} '_triggers'])

            trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_unadjusted_time']) = ...
                trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_time']);
            trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_time']) = ...
                trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_time']) + adjusts(t);
        end
    end
end



