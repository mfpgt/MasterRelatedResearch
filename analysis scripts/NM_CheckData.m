%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckData.m
%
% Notes:
%   * This is another wrapper function. When run the whole way through, it
%       will check all of the data (e.g. triggers, timing, stimuli, etc.)
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_CheckData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckData()

% Make sure all of the files are there
%NM_CheckFileStructure();

% This ensures we showed what we meant to
NM_CheckLogFile();

% This checks and adds the responses from the data file
NM_CheckBehavioralData();

% This checks and adds the eye tracking triggers
NM_CheckETData();

% Check the M/EEG triggers 
global GLA_meeg_type;
curr_type = GLA_meeg_type;
%meeg_types = {'meg','eeg'};
meeg_types = {'meg'}; 

for t = 1:length(meeg_types)
    GLA_meeg_type = meeg_types{t}; %#ok<NASGU>
    NM_CheckMEEGData();
end
GLA_meeg_type = curr_type;