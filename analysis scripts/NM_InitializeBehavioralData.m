%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_InitializeBehavioralData.m
%
% Notes:
%   * This function creates the behavioral data structure from the 
%       GLA_subject_data, with the fields:
%       - settings: Various parameters (name, type, outlier cutoffs)
%       - data, with the fields:
%           - acc: Cell array of accuracy per trial
%               - 0: wrong; 1: right; []: timeout
%           - rt: Cell array of reaction times per trial
%               - []: timeout
%           - cond: arrary of conditions per trial (1-10)
%           - outliers: array of outlier trials
%           - outliers: array of timeout trials
%           - outliers: array of error trials
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_InitializeBehavioralData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_InitializeBehavioralData()

% Initialize the data
disp(['Initializing ' NM_GetBehavioralDataType() ' behavioral data...']);
NM_LoadSubjectData({{'behavioral_data_checked',1},...
    {'log_checked',1},...
    });

% Reset first
NM_ClearBehavioralData();

% Then setup the data structure
global GLA_subject;
global GLA_behavioral_data;
GLA_behavioral_data.settings.subject = GLA_subject;
GLA_behavioral_data.settings.type = NM_GetBehavioralDataType();

% Set parameters
switch GLA_behavioral_data.settings.type
    case 'experiment'
        initializeExperimentData();

    case 'localizer'
        initializeLocalizerData();
        
    otherwise
        error('Unknown type');
end


% And save
NM_SaveBehavioralData();
disp('Done.');


function initializeLocalizerData()

global GLA_subject_data;
global GLA_behavioral_data;
GLA_behavioral_data.data.rt = {};
for b = 1:length(GLA_subject_data.data.localizer.blocks)
    if ~isempty(GLA_subject_data.data.localizer.blocks(b).params.catch_trial)
        GLA_behavioral_data.data.rt{end+1} = ...
            GLA_subject_data.data.localizer.blocks(b).params.catch_trial{3};
    end
end


function initializeExperimentData()

global GLA_subject_data;
global GLA_behavioral_data;
GLA_behavioral_data.data.acc = {};
GLA_behavioral_data.data.rt = {};
GLA_behavioral_data.data.cond = [];
GLA_behavioral_data.data.outliers = [];
GLA_behavioral_data.data.timeouts = [];
GLA_behavioral_data.data.errors = [];
GLA_behavioral_data.settings.min_resp_time = ...
    GLA_subject_data.settings.min_resp_time;
GLA_behavioral_data.settings.max_resp_time = ...
    GLA_subject_data.settings.max_resp_time;

% Set each trial
for r = 1:GLA_subject_data.settings.num_runs
    for t = 1:length(GLA_subject_data.data.runs(r).trials)
        [GLA_behavioral_data.data.acc{end+1}...
            GLA_behavioral_data.data.rt{end+1}...
            GLA_behavioral_data.data.cond(end+1)] = getTrialData(t,r);
        
        % Set timeouts, outliers, and errors
        if isempty(GLA_behavioral_data.data.acc{end})
            GLA_behavioral_data.data.timeouts(end+1) = ...
                length(GLA_behavioral_data.data.acc);
        else
            if GLA_behavioral_data.data.acc{end} == 0
                GLA_behavioral_data.data.errors(end+1) = ...
                    length(GLA_behavioral_data.data.acc);
            end
            if GLA_behavioral_data.data.rt{t} ~= []
                if (GLA_behavioral_data.data.rt{t} < GLA_behavioral_data.settings.min_resp_time) || ( GLA_behavioral_data.data.rt{t} > GLA_behavioral_data.settings.max_resp_time )
                    GLA_behavioral_data.data.outliers(end+1) = t;
                end
            end
        end
    end
end


function [acc rt cond] = getTrialData(t,r)
       
% Might be a timeout
global GLA_subject_data;
if GLA_subject_data.data.runs(r).trials(t).response.rt == -1
    acc = [];
    rt = [];

% Otherwise, set the rt and accuracy
else
    acc = GLA_subject_data.data.runs(r).trials(t).response.acc;
    rt = GLA_subject_data.data.runs(r).trials(t).response.rt;
end

% And set the condition
cond = GLA_subject_data.data.runs(r).trials(t).settings.cond;
if strcmp(GLA_subject_data.data.runs(1).trials(t).settings.p_l,'list')
    cond = cond + 5;
end
