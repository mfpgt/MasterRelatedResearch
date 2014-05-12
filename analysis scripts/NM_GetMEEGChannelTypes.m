%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetMEEGChannelTypes.m
%
% Notes:
%   * Returns the various types that a sensor is.
%       - It can be multple types, specified in the
%       m/eeg_channelt_types.mat file.
%   * MEG types: 
%       - grad_1: The first set of gradiometers
%       - grad_1: The second set of gradiometers
%       - mag: The magnetometers
%       - posterior: A set of posterior sensors
%       - left: A set of left sensors
%       - all: All the sensors
%   * EEG types: 
%       - posterior: A set of posterior sensors
%       - all: All the sensors
%
% Inputs:
%   * ch_name: The label of the sensor
%
% Outputs:
%   * types: A cell array of the types the sensor falls into
%
% Usage: 
%   * types = NM_GetMEEGChannelTypes('MEG2621')
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function types = NM_GetMEEGChannelTypes(ch_name)

% Load the mappings
types = {};
global GLA_meeg_type;
load([GLA_meeg_type '_channel_types.mat']);
s_types = fieldnames(channel_types);
for t = 1:length(s_types)
    for ch = 1:length(channel_types.(s_types{t}))
        if strcmp(ch_name,channel_types.(s_types{t}){ch})
            types{end+1} = s_types{t}; %#ok<AGROW>
            break;
        end
    end
end
    

    
    