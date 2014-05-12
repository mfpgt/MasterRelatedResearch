%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_FilterTrials.m
%
% Notes:
%   * This returns all experimental trials that pass a given filter.
%   * Filters are structures that have fields similar to a parsed
%       trial.settings structure.
%       - Only trials that have the same parameter values as the filter
%           will be passed back.
%       - If a field does not exist in the filter, all values for that
%           field will be passed.
%
% Inputs:
%   * filter: The filter for the trials.   
%
% Outputs:
%   * f_trials: The trials that pass the filter.
%
% Usage: 
%   * filter.p_l = {'phrase'};
%   * filter.cond = {1,2,3};
%   * f_trials = NM_FilterTrials(filter)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f_trials = NM_FilterTrials(filter)

% Check all the run trials
global GLA_subject_data;
f_trials = {};
for r = 1:length(GLA_subject_data.data.runs)
    for t = 1:length(GLA_subject_data.data.runs(r).trials)

        % Check the filters
        if matchesFilter(GLA_subject_data.data.runs(r).trials(t),filter)
            f_trials = NM_AddStructToArray(GLA_subject_data.data.runs(r).trials(t),f_trials);
        end
    end
end


function matches = matchesFilter(trial, filter)

matches = 1;
if isempty(filter)
    return;
end

% Check all the fields in the filter
chk_f = fieldnames(filter);
for f = 1:length(chk_f)
    if isempty(filter.(chk_f{f}))
        continue;
    end
    
    % If our trial is not in the filter list, filter it
    matches = 0;
    for v = 1:length(filter.(chk_f{f}))
        
        % NOTE: Expect to have checked trials by now
        chk = filter.(chk_f{f}){v};
        if ischar(trial.settings.(chk_f{f}))
            if strcmp(chk,trial.settings.(chk_f{f}))
                matches = 1;
                break;
            end
            
        elseif isnumeric(trial.settings.(chk_f{f}))
            if chk == trial.settings.(chk_f{f})
                matches = 1;
                break;
            end
        elseif iscell(trial.settings.(chk_f{f}))
            for i = 1:length(trial.settings.(chk_f{f}))
                if strcmp(chk,trial.settings.(chk_f{f}){i})
                    matches = 1;
                    break;
                end
            end            
        else
            error('Unknown data type');
        end
    end
    if ~matches
        return;
    end
end

