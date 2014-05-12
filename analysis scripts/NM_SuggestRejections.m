%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SuggestRejections.m
%
% Notes:
%   * This function returns a set of trials to reject for the current
%       analysis.
%   * For each data type, it will load the saved data and ask the user if
%       they would like to use any of the rejections saved in the
%       rejections field of the data.
%   * The chosen rejctions will then be saved for future reusing ease.
%
% Inputs:
% Outputs:
%   * rejections: The trials the user has decided to reject.
%
% Usage: 
%   * rejections = NM_SuggestRejections()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function rejections = NM_SuggestRejections()

% First check if we have some saved to use
global GLA_subject;
global GLA_epoch_type;
rej_file_name = [NM_GetRootDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' GLA_epoch_type '_rejections.mat'];
if exist(rej_file_name,'file')
    while 1
        ch = input(['Use saved rejections for ' GLA_epoch_type ' (y/n)? '],'s');
        if strcmp(ch,'y')
            load(rej_file_name);
            return;
        elseif strcmp(ch,'n')
            break;
        end
    end
end

% If not, search for any we might have set
rejections = [];
r_types = {'behavioral','et','meg','eeg'};
for r = 1:length(r_types)
    rejections = getDataRejections(r_types{r}, rejections);
end
rejections = sort(unique(rejections));

% And save for later
save(rej_file_name,'rejections');


function rej_to_use = getDataRejections(r_type, rej_to_use)

% Load the rejections, if we have them
global GLA_meeg_type;
global GLA_epoch_type;
switch r_type
    case 'behavioral'
        
        % Nothing to do for blinks
        if strcmp(GLA_epoch_type,'blinks')
            return;
        end
        
        if ~exist(NM_GetBehavioralDataFilename(),'file')
            return;
        end
        load(NM_GetBehavioralDataFilename(),'rejections');

    case 'et'
        if ~exist(NM_GetETDataFilename(),'file')
            return;
        end
        load(NM_GetETDataFilename(),'rejections');

    case 'meg'
        curr_meeg_type = GLA_meeg_type;
        GLA_meeg_type = 'meg'; %#ok<NASGU>
        if ~exist(NM_GetMEEGDataFilename(),'file')
            GLA_meeg_type = curr_meeg_type;
            return;
        end
        load(NM_GetMEEGDataFilename(),'rejections');
        GLA_meeg_type = curr_meeg_type;
        
    case 'eeg'
        curr_meeg_type = GLA_meeg_type;
        GLA_meeg_type = 'eeg'; %#ok<NASGU>
        if ~exist(NM_GetMEEGDataFilename(),'file')
            GLA_meeg_type = curr_meeg_type;
            return;
        end
        load(NM_GetMEEGDataFilename(),'rejections');
        GLA_meeg_type = curr_meeg_type;

    otherwise
        error('Unknown rejection type.');
        
end

% May have none
if ~exist('rejections','var')
    return;
    
end

% And suggest each type
disp(['Suggesting ' r_type ' rejections...']);
for r = 1:length(rejections)
    rej_to_use = suggestRejections(rejections(r), rej_to_use);
end
disp('Done.');


function rej_to_use = suggestRejections(rejections, rej_to_use)

% Might be nothing to do
if isempty(rejections.trials)
    return;
end

% Otherwise see if we want them
rej_str = ['Apply ' rejections.type ' rejections [('...
    num2str(length(rejections.trials)) ') -'];
for t = 1:length(rejections.trials)
    rej_str = [rej_str ' ' num2str(rejections.trials(t))];  %#ok<AGROW>
end
rej_str = [rej_str ']? (y/n): '];
while 1
    ch = input(rej_str,'s');
    if strcmp(ch,'y')
        rej_to_use(end+1:end+length(rejections.trials)) = rejections.trials;
        return;
    elseif strcmp(ch,'n')
        return;
    end
end


