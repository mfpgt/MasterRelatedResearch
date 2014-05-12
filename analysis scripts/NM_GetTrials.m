%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetTrials.m
%
% Notes:
%   * A useful helper to get the trials from the subject data that
%       correspond to the current trial type (GLA_epoch_type).
%       - Need to specify the run number for non-baseline trials.
%
% Inputs:
%   * run_num: The run number we want the trials from
%       - Not applicable for baseline trial types
%
% Outputs:
%   * trials: The trials that we want.
%
% Usage: 
%   * trials = NM_GetTrials(run_num)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function trials = NM_GetTrials(run_num)

% Make sure we've got the right data
NM_LoadSubjectData();

global GLA_subject_data;
global GLA_epoch_type;
if strcmp(GLA_epoch_type,'blinks')
    trials = GLA_subject_data.data.baseline.blinks;

elseif strcmp(GLA_epoch_type,'left_eye_movements') ||...
        strcmp(GLA_epoch_type,'right_eye_movements') 
    trials = GLA_subject_data.data.baseline.eye_movements;

elseif strcmp(GLA_epoch_type,'word_5') ||...
        strcmp(GLA_epoch_type,'word_4')
    trials = GLA_subject_data.data.runs(run_num).trials;

else
    error('Unknown type');
end
