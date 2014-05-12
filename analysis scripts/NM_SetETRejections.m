%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SetETRejections.m
%
% Notes:
%   * This function identifies potential trials to reject based on the eye
%       tracking data. These are stored in GLA_et_data.rejections in the
%       following fields:
%       - blink: Any trial with a blink in it.
%       - saccade: Any trial with a saccade in it.
%   * For the 'blinks' trial type, these criteria are reversed. (I.e. only
%       trials without blinks or saccades are suggested as rejections).
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SetETRejections()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SetETRejections()

% Load the data
global GLA_subject;
global GLA_epoch_type;
if isempty(GLA_epoch_type)
    error('GLA_epoch_type not set.');
end
disp(['Setting eye tracking rejections for ' GLA_epoch_type ' for ' GLA_subject]);
NM_LoadETData();

% See what we want to reject
global GLA_et_data;
GLA_et_data.rejections = {};
types = {'blink','saccade'};
for t = 1:length(types)
    GLA_et_data.rejections(t).trials = getPossibleRejections(types{t});

    % No blinks, for blinks
    if strcmp(GLA_epoch_type,'blinks')
        GLA_et_data.rejections(t).type = ['no_' types{t}];       

    % No saccades for eye movements
    elseif (strcmp(GLA_epoch_type,'left_eye_movements') ||...
                strcmp(GLA_epoch_type,'right_eye_movements')) && ... 
                strcmp(types{t},'saccade')
        GLA_et_data.rejections(t).type = ['no_' types{t}];       
    else
        GLA_et_data.rejections(t).type = types{t};
    end
end
NM_SaveETData();
disp('Done.');


function rej = getPossibleRejections(type)

% Get any trial with a start or end
rej = [];
global GLA_epoch_type;
global GLA_et_data;
starts = GLA_et_data.data.([type '_starts']);
ends = GLA_et_data.data.([type '_starts']);
for t = 1:length(GLA_et_data.data.cond)
    
    % Want no blinks if averaging blinks
    if strcmp(GLA_epoch_type,'blinks') 
        if isempty(starts{t}) || isempty(ends{t})
            rej(end+1) = t; %#ok<AGROW>
        end
    % No saccades for eye movements
    elseif (strcmp(GLA_epoch_type,'left_eye_movements') ||...
                strcmp(GLA_epoch_type,'right_eye_movements')) && ... 
                strcmp(type,'saccade')
        if isempty(starts{t}) || isempty(ends{t})
            rej(end+1) = t; %#ok<AGROW>
        end
    else
        if ~isempty(starts{t}) || ~isempty(ends{t})
            rej(end+1) = t; %#ok<AGROW>
        end
    end
end
