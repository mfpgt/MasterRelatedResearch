%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzeETData.m
%
% Notes:
%   * Wrapper to run a quick analysis of the eye tracking data using
%      NM_AnalyzeTimeCourse.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_AnalyzeETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AnalyzeETData()

% Make sure we have something to do
NM_LoadSubjectData();
global GLA_subject_data;
if ~GLA_subject_data.settings.eye_tracker
    return;
end

% Make sure we're ready
NM_LoadSubjectData({...
    {'et_word_5_data_preprocessed',1},...
    });

% Set the config
cfg = [];
cfg.data_type = 'et';
cfg.epoch_type = 'word_5';
cfg.time_windows = {[200 300] [300 500]};
cfg.time_window_measure = 'rms';

% Get the rejections once
global GLA_epoch_type;
GLA_epoch_type = cfg.epoch_type;
cfg.rejections = NM_SuggestRejections();

% Analyze the time courses
measures =  {'x_pos','y_pos','pupil','x_vel','y_vel'};
for m = 1:length(measures)
    cfg.measure = measures{m};
    cfg.tc_name = cfg.measure;
    NM_AnalyzeTimeCourse(cfg);
end

% And the saccades
measures =  {'num_saccades','saccade_length'};
for m = 1:length(measures)
    cfg.measure = measures{m};
    cfg.sv_name = cfg.measure;
    NM_AnalyzeSingleValues(cfg);
end

