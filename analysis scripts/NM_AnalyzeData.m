%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzeData.m
%
% Notes:
%   * A high-level wrapper that will perform a first analysis of all of the data
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_AnalyzeData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AnalyzeData()

% Behavioral data
NM_AnalyzeBehavioralData();

% Eye tracking data
NM_AnalyzeETData();

% Both M/EEG data types
global GLA_meeg_type;
m_types = {'meg','eeg'};
for m = 1:length(m_types)
    GLA_meeg_type = m_types{m};
    NM_AnalyzeMEEGData();
end

% And the fMRI experimental data
global GLA_fmri_type;
GLA_fmri_type = 'experiment';
NM_AnalyzefMRIData();

