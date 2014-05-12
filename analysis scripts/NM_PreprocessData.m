%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_PreprocessData.m
%
% Notes:
%   * A wrapper for preprocessing the data. 
%       - Mostly likely you will run these separately, but this gives all
%           of the functions and settings that are needed to perform the
%           sanity checks.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_PreprocessData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_PreprocessData()

% The easy stuff
global GLA_fmri_type;
f_types = {'localizer','experiment'};
for t = 1:length(f_types)
    GLA_fmri_type = f_types{t};
    NM_PreprocessBehavioralData();
end

% Adjust the timing of the triggers with the relative diode timings
NM_AdjustTiming();

% Process these for the sanity check, and then to support the meeg data
global GLA_epoch_type;
epoch_types = {'blinks','right_eye_movements','left_eye_movements','word_5'};
for t = 1:length(epoch_types)
    GLA_epoch_type = epoch_types{t};
    NM_PreprocessETData();
end

% Process these two for now...
epoch_types = {'blinks','word_5'};
global GLA_meeg_type;
meeg_types = {'meg','eeg'};
for m = 1:length(meeg_types)
    GLA_meeg_type = meeg_types{m};
    for t = 1:length(epoch_types)
        GLA_epoch_type = epoch_types{t};
        NM_PreprocessMEEGData();
    end
end

% And both fmri datas
for t = 1:length(f_types)
    GLA_fmri_type = f_types{t};
    NM_PreprocessfMRIData();
end
    
