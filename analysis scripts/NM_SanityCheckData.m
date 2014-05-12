%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SanityCheckData.m
%
% Notes:
%   * A high-level wrapper that performs sanity checks on all of the data
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SanityCheckData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SanityCheckData()

% This looks for high accuracy 
NM_SanityCheckBehavioralData();

% Checks the baselines
NM_SanityCheckETData();

% Checks the visual response in the M/EEG data
global GLA_meeg_type;
m_types = {'meg','eeg'};
for t = 1:length(m_types)
    GLA_meeg_type = m_types{t};
    NM_SanityCheckMEEGData();
end

% Analyzes the localizer
NM_SanityCheckfMRIData();

