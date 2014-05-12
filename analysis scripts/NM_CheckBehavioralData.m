%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckBehavioralData.m
%
% Notes:
%   * Checks to make sure that the responses (in the NIP_data.txt) file are
%       as expected. 
%   * Adds a response field to each trial containing the subfields
%       - rt: The response time relative to the probe
%       - abs_rt: The response time relative to the beginning of the log
%       - acc: 1 if the response is correct
%       - key: The key the subject pressed
%   * For timeouts, key = 'TIMEOUT' and rt / acc = -1
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_CheckBehavioralData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckBehavioralData()

global GLA_subject;
disp(['Checking behavioral data for ' GLA_subject '...']);

% Make sure we've checked the log
NM_LoadSubjectData({{'log_checked',1}});

% Load / create the data
loadBehavioralData();

% Check the runs
checkRuns();

% The localizer
checkLocalizer();

% No responses in the baseline...

% Resave...
disp('Behavioral data checked.');
NM_SaveSubjectData({{'behavioral_data_checked',1}});


function checkLocalizer()

% Might not have it
global GLA_subject_data;
if GLA_subject_data.settings.num_localizer_blocks == 0
    return;
end

% Find the start of the localizer
global GL_response_data;
ttl_ind = find(strcmp('localizer',GL_response_data{7}),1)-1;

% Make sure
if ~strcmp(GL_response_data{1}{ttl_ind},'KEY') ||...
        ~strcmp(GL_response_data{2}{ttl_ind},'s') 
    error('Not the first TTL.');
end
GLA_subject_data.data.localizer.first_ttl = ...
    str2double(GL_response_data{4}{ttl_ind});

% TODO: Check for responses...
ind = ttl_ind+1;
for b = 1:GLA_subject_data.settings.num_localizer_blocks
    ind = checkLocalizerBlockResponses(b,ind);
end



function ind = checkLocalizerBlockResponses(b,ind)

% Check each sentence
global GLA_subject_data;
for s = 1:length(GLA_subject_data.data.localizer.blocks(b).params.stims)
    ind = checkLocalizerSequenceResponses(b,s,ind);
end

% Make sure we got the right amount
if ~isempty(GLA_subject_data.data.localizer.blocks(b).params.catch_trial)
    if length(GLA_subject_data.data.localizer.blocks(b).params.catch_trial) ~= 4
        error('Response not found...');
    else
        disp(['Found localizer response in block ' num2str(b) ', sentence '...
            num2str(GLA_subject_data.data.localizer.blocks(b).params.catch_trial{1}) ...
            ' in ' num2str(1000*GLA_subject_data.data.localizer.blocks(b).params.catch_trial{3}) ' ms']);
    end
end


function ind = checkLocalizerSequenceResponses(b,s,ind)

% Check 
global GLA_subject_data;
global GL_response_data;
for w = 1:length(GLA_subject_data.data.localizer.blocks(b).params.stims{s})
    
    % Check
    if ~strcmp(GL_response_data{7}{ind},'localizer') ||...
            ~strcmp(GL_response_data{8}{ind},num2str(b)) ||...
            ~strcmp(GL_response_data{9}{ind},GLA_subject_data.data.localizer.blocks(b).params.condition)
        error('Bad response');
    end
    
    % Looks like a bug(ish)...
    if w < length(GLA_subject_data.data.localizer.blocks(b).params.stims{s})
        check_ind = w+1;
    else
        check_ind = w;
    end
    if ~NM_IsEqualStim(GL_response_data{10}{ind},...
            GLA_subject_data.data.localizer.blocks(b).params.stims{s}{check_ind})
        error('Bad response');
    end
    
    % Should not be responses.
    % TODO: Deal with false alarms
    if ~strcmp(GL_response_data{1}{ind},'TIMEOUT')
        error('Unimplemented: False alarm!');
    end
    
    ind = ind+1;
end

% See if there was supposed to be a response
if ~isempty(GLA_subject_data.data.localizer.blocks(b).params.catch_trial) 
    if GLA_subject_data.data.localizer.blocks(b).params.catch_trial{1} == s

        % Check
        if ~strcmp(GL_response_data{7}{ind},'localizer') ||...
                ~strcmp(GL_response_data{8}{ind},num2str(b)) ||...
                ~strcmp(GL_response_data{9}{ind},GLA_subject_data.data.localizer.blocks(b).params.condition) ||...
                ~NM_IsEqualStim(GL_response_data{10}{ind},...
                    GLA_subject_data.data.localizer.blocks(b).params.stims{s}{end})
            error('Bad response');
        end

        % Should have the response here
        if ~strcmp(GL_response_data{5}{ind},'Text') ||...
                ~strcmp(GL_response_data{6}{ind},...
                GLA_subject_data.data.localizer.blocks(b).params.catch_trial{2})
            error('Bad catch trial');
        end
        
        % TODO: Implement missed trial checking        
        if ~strcmp(GL_response_data{1}{ind},'KEY')
            error('Unimplemented');
        end
        
        % Check the response
        if ~strcmp(GL_response_data{2}{ind},GLA_subject_data.settings.localizer_response_key)
            error('Unexpected catch trial');
        end
        
        % Record the response
        GLA_subject_data.data.localizer.blocks(b).params.catch_trial{3} = ...
            str2double(GL_response_data{3}{ind});
        
        % Absolute time makes the design file easier
        GLA_subject_data.data.localizer.blocks(b).params.catch_trial{4} = ...
            str2double(GL_response_data{4}{ind});
        ind = ind+1;
    end
end


function checkRuns()

global GLA_subject_data;
for r = 1:GLA_subject_data.settings.num_runs
    checkRun(r); 
end


function checkRun(run_id)

% First, parse the responses
global GL_response_data;

% Get the first line
r_ind = find(strcmp('KEY',GL_response_data{1}) &...
    strcmp(num2str(run_id),GL_response_data{7}) & strcmp('1',GL_response_data{8}));

% Might have been a timeout...
if isempty(r_ind)
    r_ind = find(strcmp('TIMEOUT',GL_response_data{1}) &...
        strcmp(num2str(run_id),GL_response_data{7}) & strcmp('1',GL_response_data{8}));
end
if length(r_ind) ~= 1
    error('Bad index');
end

% Set the first ttl
global GLA_subject_data;
global GLA_rec_type;
if strcmp(GLA_rec_type,'fmri')
    if ~strcmp(GL_response_data{1}{r_ind-1},'KEY') ||...
            ~strcmp(GL_response_data{2}{r_ind-1},'s')
        error('Not the ttl');
    end
    GLA_subject_data.data.runs(run_id).first_ttl = str2double(GL_response_data{4}{r_ind-1});
end

% Now, check each and add
for t = 1:length(GLA_subject_data.data.runs(run_id).trials)
    GLA_subject_data.data.runs(run_id).trials(t).response = ...
        checkResponse(GLA_subject_data.data.runs(run_id).trials(t).settings,r_ind);
    GLA_subject_data.data.runs(run_id).trials(t).settings.acc = ...
        GLA_subject_data.data.runs(run_id).trials(t).response.acc;
    r_ind = r_ind+1;
end

% Check a particular response
function response = checkResponse(trial,r_ind)

global GLA_subject_data;
global GL_response_data;

% Check / add all the parameters
if ~strcmp(GL_response_data{1}{r_ind},'KEY') && ...
        ~strcmp(GL_response_data{1}{r_ind},'TIMEOUT')
    error('Bad response');
end

if strcmp(GL_response_data{1}{r_ind},'KEY')
    response.key = GL_response_data{2}{r_ind};

    % Conver to ms
    response.rt = 1000*str2double(GL_response_data{3}{r_ind});
    response.abs_rt = 1000*str2double(GL_response_data{4}{r_ind});
else
    response.key = 'TIMEOUT';
    response.rt = -1;
    response.abs_rt = -1;
end
if ~strcmp(GL_response_data{5}{r_ind},'Text')
    error('Bad response');
end
if ~NM_IsEqualStim(NeuroMod_ConvertToUTF8(GL_response_data{6}{r_ind}),upper(trial.probe)) 
    error('Bad response');
end
if ~strcmp(GL_response_data{7}{r_ind},num2str(trial.run_id))
    error('Bad response');
end
if ~strcmp(GL_response_data{8}{r_ind},num2str(trial.trial_num))
    error('Bad response');
end
if ~strcmp(GL_response_data{9}{r_ind},trial.n_v)
    error('Bad response');
end
if ~strcmp(GL_response_data{10}{r_ind},trial.p_l)
    error('Bad response');
end
if ~strcmp(GL_response_data{11}{r_ind},num2str(trial.cond))
    error('Bad response');
end
if ~strcmp(GL_response_data{12}{r_ind},num2str(trial.a_p))
    error('Bad response');
end
if ~strcmp(GL_response_data{13}{r_ind},num2str(trial.answer))
    error('Bad response');
end

for s = 1:GLA_subject_data.settings.num_critical_stim
     if ~strcmp(NeuroMod_ConvertToUTF8(GL_response_data{13+s}{r_ind}),trial.trial_stim{s})
        error('Bad response');
    end
end
if ~strcmp(NeuroMod_ConvertToUTF8(GL_response_data{13+s+1}{r_ind}),trial.probe)
    error('Bad response');
end

% Add the accuracy
switch response.key
    case '1'
        if strcmp(GLA_subject_data.settings.resp_type,'right')
            resp = 0;
        else
            resp = 1;
        end
        
    case 'p'
        if strcmp(GLA_subject_data.settings.resp_type,'right')
            resp = 0;
        else
            resp = 1;
        end

    case '6'
        if strcmp(GLA_subject_data.settings.resp_type,'right')
            resp = 1;
        else
            resp = 0;
        end

    case 'y'
        if strcmp(GLA_subject_data.settings.resp_type,'right')
            resp = 1;
        else
            resp = 0;
        end
        
    case 'TIMEOUT'
        resp = -1;

    otherwise 
        error('Unknown key pressed.');
end

if (strcmp(trial.answer,'match') && resp == 1) ||...
        (~strcmp(trial.answer,'match') && resp == 0) 
    response.acc = 1;
else    
    response.acc = 0;
end



function loadBehavioralData()

disp('Loading data...');

global GL_response_data;
global GLA_subject;
fid = fopen([NM_GetRootDirectory() '/logs/' ...
    GLA_subject '/' GLA_subject '_data.txt']);
GL_response_data = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s');
fclose(fid);
disp('Done.');

