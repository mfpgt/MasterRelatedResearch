%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_DefineMEEGTrial.m
%
% Notes:
%   * This function is called by ft_definetrial, which should be called
%       before calling ft_preprocessing to epoch the data.
%   * Returns the definition of each trial in a particular run for later processing
%       required by ft_preprocessing
%
% Inputs:
%   * cfg: The cfg struct given to ft_definetrial
%       - This must contain a run_id field that is expected to be a string
%           with the final character the number of run we're defining
%           trials for.
%
% Outputs:
%   * trl: contains one row per trial and columns:
%       - beginsample     endsample   offset    cond
%       - Uses the NM_GetTrialCondition and NM_GetTrialTriggerTime helpers
%           to set these columns for each trial, and the appropriate epoch
%           in the GLA_subject_data.settings.
%
%
% Usage: 
%   * cfg = [];
%   * cfg.trialfun = 'NM_DefineMEEGTrial';
%   * cfg.run_id = run_id;
%   * cfg = ft_definetrial(cfg);
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function trl = NM_DefineMEEGTrial(cfg)

% Set the trials
trl = [];
trials = NM_GetTrials(str2double(cfg.run_id(end)));
global GLA_subject_data;
global GLA_epoch_type;
if isempty(GLA_epoch_type)
    error('GLA_epoch_type not set.');
end
global GLA_meeg_type;
for t = 1:length(trials)
    cond = NM_GetTrialCondition(trials(t));
    trigger_time = NM_GetTrialTriggerTime(trials(t),GLA_meeg_type);
    trl(end+1,:) = [trigger_time + GLA_subject_data.settings.([GLA_epoch_type '_epoch'])(1)...
        trigger_time + GLA_subject_data.settings.([GLA_epoch_type '_epoch'])(2)-1 ...
        GLA_subject_data.settings.([GLA_epoch_type '_epoch'])(1) cond]; %#ok<AGROW>
end


