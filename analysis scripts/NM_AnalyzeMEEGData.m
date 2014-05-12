%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzeMEEGData.m
%
% Notes:
%   * Wrapper to run a quick analysis of the m/eeg data using
%      NM_AnalyzeTimeCourse and NM_AnalyzeSingleValues.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_AnalyzeMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AnalyzeMEEGData()

% See if we have anything
NM_LoadSubjectData();
global GLA_subject_data;
global GLA_meeg_type;
if ~GLA_subject_data.settings.(GLA_meeg_type)
    return;
end

% Make sure we're ready
NM_LoadSubjectData({...
    {[GLA_meeg_type '_word_5_data_preprocessed'],1},...
    });

cfg = [];
cfg.data_type = GLA_meeg_type;
cfg.epoch_type = 'word_5';
cfg.time_windows = {[200 300] [300 500]};
cfg.time_window_measure = 'rms';
cfg.baseline_correct = 0;
cfg.rereference = 1;

% Get the rejections once
global GLA_epoch_type;
GLA_epoch_type = cfg.epoch_type;
cfg.rejections = NM_SuggestRejections();

% Analyze the time courses of sensor sets
cfg.measure = 'rms';
s_types = {'all','posterior'};
if strcmp(GLA_meeg_type,'meg')
    s_types{end+1} = 'left';
end
for s = 1:length(s_types)
    cfg.tc_name = [GLA_meeg_type '_' s_types{s}];
    cfg.channels = NM_GetMEEGChannels(s_types{s});
    NM_AnalyzeTimeCourse(cfg);
end
cfg = rmfield(cfg,'channels');
        
% And the different bands
bands = {[4 8], [8 13], [12 30], [30 50], [50 100]};
band_names = {'theta','alpha','beta','low_gamma','high_gamma'};
for b = 1:length(bands)
    cfg.bpf = bands{b};
    cfg.tc_name = [GLA_meeg_type '_' band_names{b}];
    NM_AnalyzeTimeCourse(cfg);
end

