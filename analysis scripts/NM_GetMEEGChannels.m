%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetMEEGChannels.m
%
% Notes:
%   * Helper to get all of the sensor labels of a certain type. 
%       - Reads from handmade sets saved to m/eeg_channel_types.mat
%   * MEG types: 
%       - grad_1: The first set of gradiometers
%       - grad_2: The second set of gradiometers
%       - mag: The magnetometers
%       - posterior: A set of posterior sensors
%       - left: A set of left sensors
%       - all: All the sensors
%   * EEG types: 
%       - posterior: A set of posterior sensors
%       - all: All the sensors
%
% Inputs:
%   * s_type: The type of sensor to get
%   * data (optional): If provided, will only return those sensors that are
%       in the data.
%        - Otherwise, uses the 'all' type of the loaded file.
%
% Outputs:
%   * channels: The selected channels
%
% Usage: 
%   * channels = NM_GetMEEGChannels('mag')
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function channels = NM_GetMEEGChannels(s_type, data)

% Get the type channels
global GLA_meeg_type;
load([GLA_meeg_type '_channel_types.mat']);

% Make sure it's gooda
avail = fieldnames(channel_types);
found = 0;
for s = 1:length(avail)
    if strcmp(avail{s},s_type)
        found = 1;
        break;
    end
end
if ~found
    error([s_type ' sensor type not found.']);
end
type_ch = channel_types.(s_type);

% Could only have some of the channels
if exist('data','var')
    data_ch = data.label;
else
    data_ch = channel_types.all; 
end

channels = {};
for d = 1:length(data_ch)
    for t = 1:length(type_ch)
        if strcmp(data_ch{d},type_ch{t})
            channels{end+1} = data_ch{d}; %#ok<AGROW>
            break;
        end
    end
end

