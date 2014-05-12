%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_RepairMEEGChannels.m
%
% Notes:
%   * Repairs bad channels in the eeg data.
%       - This is done by maxfilter for the meg data.
%   * First, allows the user to reject channels using ft_rejectvisual
%   * Then, uses ft_channelrepair to interpolate data for the bad channels.
%   
% Inputs:
% Outputs:
% Usage: 
%   * NM_RepairMEEGChannels()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_RepairMEEGChannels()

% This is done by maxfilter for the meg data
global GLA_rec_type;
global GLA_meeg_type;
if ~strcmp(GLA_rec_type,'meeg') || ~strcmp(GLA_meeg_type,'eeg')
    return; 
end

% Load the data
global GLA_meeg_data;
global GLA_subject;
global GLA_epoch_type;
disp(['Repairing eeg channels for ' GLA_epoch_type ' for ' GLA_subject '...']);
NM_LoadMEEGData();

% Find which channels to repair
GLA_meeg_data.settings.bad_channels = getBadChannels();

% And repair
repairBadChannels()

% Take out duplicates and save
NM_SaveMEEGData();
disp('Done.');


function repairBadChannels()

% First, specify the neighbors using the layout
global GLA_meeg_data;
cfg = [];
cfg.method = 'distance';
cfg.neighbourdist = 4;

% add electrode positions information from the sfp file because EGI is not directly supported by ft_repairchannel
cfg.elec = ft_read_sens('GSN-HydroCel-256.sfp'); 
cfg.feedback = 'no';
neighbours = ft_prepare_neighbours(cfg, GLA_meeg_data.data);


% Now, repair the bad channels
cfg = [];
cfg.method = 'nearest'; % 'nearest', 'spline' or 'slap' 
cfg.badchannel = GLA_meeg_data.settings.bad_channels;
cfg.neighbours = neighbours;
cfg.elec = ft_read_sens('GSN-HydroCel-256.sfp');
GLA_meeg_data.data = ft_channelrepair(cfg, GLA_meeg_data.data);



function bad_ch = getBadChannels()

% Use the browser to reject channels
global GLA_meeg_data;
cfg = [];
cfg.channel = 'EEG';
cfg.method = 'summary';
tmp_data = ft_rejectvisual(cfg,GLA_meeg_data.data);

% Find which channels were removed
all_ch = GLA_meeg_data.data.label;
bad_ch = {};
for ch = 1:length(all_ch)
    if sum(strcmp(all_ch{ch},tmp_data.label)) == 0
        bad_ch{end+1} = all_ch{ch}; %#ok<AGROW>
    end
end


