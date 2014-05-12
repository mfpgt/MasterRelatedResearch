%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CreateDesignFiles.m
%
% Notes:
%   * Writes out the design files used in spm preprocessing. These contain:
%       - names: The names of the conditions
%           - experiment: phrase_#, list_#
%           - localizer: sentence, pseudo, response
%       - onsets: The onset from the first ttl of each event
%           - One array per condition
%       - durations: The length of each event
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_CreateDesignFiles()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CreateDesignFiles()

global GLA_rec_type;
if ~strcmp(GLA_rec_type,'fmri')
    return;
end

% Check the processing
NM_LoadSubjectData({...
    {'fmri_data_imported',1},...
    {'log_checked',1}...
    });

% Create the right design file
global GLA_fmri_type;
global GLA_subject_data;
switch GLA_fmri_type
    case 'localizer'
        createLocalizerDesignFile();
        
    case 'experiment'
        for r = 1:GLA_subject_data.settings.num_runs
            createExperimentRunDesignFile(GLA_subject_data.data.runs(r).trials, ...
                GLA_subject_data.data.runs(r).first_ttl);
        end
        
    otherwise
        error('Unknown type');
end


function createExperimentRunDesignFile(trials, first_ttl)

% Initialize
global GLA_subject_data;
types = {'phrase','list'};
names = {}; onsets = {}; durations = [];
for t = 1:length(types)
    for c = 1:GLA_subject_data.settings.num_critical_stim
        names{end+1} = [types{t} '_' num2str(c)]; %#ok<AGROW>
        onsets{end+1} = []; durations{end+1} = []; %#ok<AGROW>
    end
end

% Go through the run
global GLA_subject;
for t = 1:length(trials)

    onset = trials(t).log_stims(1).log_time;

    % This is the cross after the response
    offset = trials(t).log_stims(end).log_time;

    % Get the duration
    duration = offset-onset;

    % And convert onset 
    onset = onset - first_ttl;

    % And add
    for n = 1:length(names)
        if strcmp(names{n}, ...
            [trials(t).settings.p_l ...
                '_' num2str(trials(t).settings.cond)])
            onsets{n}(end+1) = onset; %#ok<AGROW>
            durations{n}(end+1) = duration; %#ok<AGROW>
            break;
        end
    end
end


% And save it
dir = [NM_GetRootDirectory() '/fmri_data/' ...
    GLA_subject '/experiment'];
[success m m_id] = mkdir(dir); %#ok<NASGU,ASGLU>
design_file_name = [dir '/' GLA_subject ...
    '_run_' num2str(trials(1).settings.run_id) '_design.mat'];
save(design_file_name,'names','onsets','durations');


function createLocalizerDesignFile()

% Need to convert the trials to names, onsets, and durations
global GLA_subject_data;

% Add each block
names = {'sentence','pseudo','response'};
for i = 1:length(names)
    onsets{i} = [];  %#ok<AGROW>
    durations{i} = [];  %#ok<AGROW>
end
for b = 1:GLA_subject_data.settings.num_localizer_blocks
    onset = GLA_subject_data.data.localizer.blocks(b).log_stims(1).log_time;
    
    % NOTE: This last stim is actually the start of the delay between
    % blocks, so it works.
    offset = GLA_subject_data.data.localizer.blocks(b).log_stims(end).log_time;

    % Get the duration
    duration = offset-onset;

    % And convert onset 
    onset = onset - GLA_subject_data.data.localizer.first_ttl;
    
    % And add
    for n = 1:length(names)
        if strcmp(names{n}, GLA_subject_data.data.localizer.blocks(b).log_stims(1).condition)
            onsets{n}(end+1) = onset; %#ok<AGROW>
            durations{n}(end+1) = duration; %#ok<AGROW>
            break;
        end
    end
    
    % And the responses
    if ~isempty(GLA_subject_data.data.localizer.blocks(b).params.catch_trial)
        
        % Take the appearance of the probe
        onsets{3}(end+1) = GLA_subject_data.data.localizer.blocks(b).params.catch_trial{4} - ...
            GLA_subject_data.data.localizer.blocks(b).params.catch_trial{3} -...
            GLA_subject_data.data.localizer.first_ttl; %#ok<AGROW>
        
        % The rt
        durations{3}(end+1) = GLA_subject_data.data.localizer.blocks(b).params.catch_trial{3}; %#ok<AGROW>
    end
end

% Check for no catches
if isempty(onsets{3})
    names = {names{1:2}}; %#ok<CCAT1,NASGU>
    onsets = {onsets{1:2}}; %#ok<CCAT1,NASGU>
    durations = {durations{1:2}}; %#ok<CCAT1,NASGU>
end


% And save it
global GLA_subject;
dir = [NM_GetRootDirectory() '/fmri_data/' ...
    GLA_subject '/localizer'];
[success m m_id] = mkdir(dir); %#ok<NASGU,ASGLU>
design_file_name = [dir '/' GLA_subject '_localizer_design.mat'];
save(design_file_name,'names','onsets','durations');



