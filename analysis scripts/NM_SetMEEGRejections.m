%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SetMEEGRejections.m
%
% Notes:
%   * Sets potential trial rejections for the current meeg data using one
%       of two methods (set in GLA_subject_data.settings.meeg_rej_type)
%       - raw: Uses ft_databrowser and allows inspection of the data
%       - summary: Uses ft_rejectvisual to present trials for rejection
%   * Stores the rejected trials in GLA_meeg_data.rejections
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SetMEEGRejections()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SetMEEGRejections()

% Load the data
global GLA_meeg_type;
global GLA_subject;
global GLA_epoch_type;
if isempty(GLA_epoch_type)
    error('GLA_epoch_type not set.');
end
disp(['Setting ' GLA_meeg_type ' rejections for ' GLA_epoch_type ' for ' GLA_subject]);
NM_LoadMEEGData();

% Use whichever type we set
global GLA_subject_data;
global GLA_meeg_data;
if ~isfield(GLA_meeg_data, 'rejections')
    GLA_meeg_data.rejections = {};
    GLA_meeg_data.rejections(1).type = ...
        GLA_subject_data.settings.meeg_rej_type;
else
    GLA_meeg_data.rejections(end+1).type = ...
        GLA_subject_data.settings.meeg_rej_type;    
end
switch GLA_subject_data.settings.meeg_rej_type
    case 'raw'
        GLA_meeg_data.rejections(end).trials = ...
            rejectArtifacts_Raw();
        
    case 'summary'
        GLA_meeg_data.rejections(end).trials = ...
            rejectArtifacts_Summary();
        
    otherwise
        error('Unknown type');
end

% Take out duplicates and save
NM_SaveMEEGData();
disp('Done.');


function rej = rejectArtifacts_Raw()

% Artifact rejection
global GLA_meeg_data;
global GLA_meeg_type;
cfg = [];
cfg.channel = GLA_meeg_data.settings.channel;
if strcmp(GLA_meeg_type,'meg')
    cfg.magscale = 10;
end
cfg = ft_databrowser(cfg,GLA_meeg_data.data);
rej = findTrialRejections(cfg.artfctdef.visual.artifact);


function rej = rejectArtifacts_Summary()

global GLA_meeg_data;
global GLA_meeg_type;
cfg = [];
cfg.channel = GLA_meeg_data.settings.channel;
if strcmp(GLA_meeg_type,'meg')
    cfg.magscale = 10;
end
cfg.method = 'summary';   % 'trial', 'channel', 'summary'
tmp_data = ft_rejectvisual(cfg,GLA_meeg_data.data);
rej = findTrialRejections(tmp_data.cfg.artifact);


function r_trials = findTrialRejections(rejections)

% Create sample data, if not there
% NOTE: It gets deleted when we append runs
global GLA_meeg_data;
if ~isfield(GLA_meeg_data.data, 'sampleinfo')
    
    % Set to be contiguous
    t_len = round((GLA_meeg_data.data.time{1}(end) - GLA_meeg_data.data.time{1}(1))*1000)+1;
    sampleinfo(:,1) = 1:t_len:length(GLA_meeg_data.data.trial)*t_len;
    sampleinfo(:,2) = t_len:t_len:length(GLA_meeg_data.data.trial)*t_len;
else
    sampleinfo = GLA_meeg_data.data.sampleinfo;
end

% We're going to hope they always treat these as continuous
r_trials = [];
for r = 1:size(rejections,1)
    
    % Make sure all is as it's supposed to be
    rej_beg = find(sampleinfo(:,2) >= rejections(r,1),1);
    rej_end = find(sampleinfo(:,2) >= rejections(r,2),1);
    if rej_beg ~= rej_end
        error('Rejection not as expected.');
    end
    r_trials(end+1) = rej_beg; %#ok<AGROW>
end

