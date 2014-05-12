%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetTrialTriggerTime.m
%
% Notes:
%   * A quick helper to grab the trigger time for a given trial and trigger type.
%   * The trigger in the trial is determined by the current trial type (GLA_epoch_type)
%
% Inputs:
%   * trial: The trial to get the trigger from
%       - i.e. a trial structure from the GLA_subject_data
%   * type: The type of trigger we want
%       - e.g. 'log','meg','et','eeg'
%
% Outputs:
%
% Usage: 
%   * t_time = NM_GetTrialTriggerTime(trials(1),'meg')
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function t_time = NM_GetTrialTriggerTime(trial, type)

global GLA_epoch_type;
switch GLA_epoch_type
    case 'blinks'
        t_time = trial.([type '_triggers'])(1).([type '_time']);
        
    case 'right_eye_movements'
        if trial.et_triggers(1).value == 3
            t_time = trial.([type '_triggers'])(1).([type '_time']);
        else
            t_time = trial.([type '_triggers'])(2).([type '_time']);            
        end
                
    case 'left_eye_movements'
        if trial.et_triggers(1).value == 4
            t_time = trial.([type '_triggers'])(1).([type '_time']);
        else
            t_time = trial.([type '_triggers'])(2).([type '_time']);            
        end
        
    case 'word_5'
        t_time = trial.([type '_triggers'])(5).([type '_time']);
        
    case 'word_4'
        t_time = trial.([type '_triggers'])(4).([type '_time']);
        
    otherwise
        error('Unknown type.');
end


