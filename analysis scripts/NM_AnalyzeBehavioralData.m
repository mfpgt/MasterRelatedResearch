%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzeBehavioralData.m
%
% Notes:
%   * Wrapper to analyze the behavioral data.
%   * For now, just runs an analysis on the rts
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_AnalyzeBehavioralData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AnalyzeBehavioralData()

% Make sure we're ready
NM_LoadSubjectData({...
    {[NM_GetBehavioralDataType() '_behavioral_data_preprocessed'],1},...
    });

% Set up the configuration for the analysis
cfg = [];
cfg.data_type = 'behavioral';

% Get the rejections once
% Use the critical trials for now
global GLA_epoch_type;
GLA_epoch_type = 'word_5';
cfg.rejections = NM_SuggestRejections();

% Analyze the measures
measures =  {'rt'};     % Acc
for m = 1:length(measures)
    cfg.measure = measures{m};
    cfg.sv_name = 'rt';
    NM_AnalyzeSingleValues(cfg);
end
