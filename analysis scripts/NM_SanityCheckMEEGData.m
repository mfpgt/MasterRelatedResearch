%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SanityCheckMEEGData.m
%
% Notes:
%   * Checks to make sure that the m/eeg data looks ok. 
%   * Creates and saves the averages for the 'blinks' and 'word_5' trials
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SanityCheckMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SanityCheckMEEGData()

% Might be nothing to do
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'meeg')
    return;
end

% Make sure our data is ready
global GLA_subject;
global GLA_meeg_type;
global GLA_subject_data;
if ~GLA_subject_data.settings.(GLA_meeg_type)
    return;
end
disp(['Sanity checking ' GLA_meeg_type ' data for ' GLA_subject '...']);
NM_LoadSubjectData({...
    {[GLA_meeg_type '_blinks_data_preprocessed'],1},...
    {[GLA_meeg_type '_word_5_data_preprocessed'],1},...
    });

% Plot the averages for the blinks and the final word
global GLA_epoch_type;
types = {'blinks','word_5'};
for t = 1:length(types)
    GLA_epoch_type = types{t};
    cfg = [];
    cfg.save_name = [types{t} '_' GLA_meeg_type '_averages'];
    NM_DisplayMEEGAverages(cfg);
end

