%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CreateCleanMEEGData.m
%
% Notes:
%   * Creates a "clean" version of the current meeg data. This data is
%       saved to GLA_clean_meeg_data. This differs from the full data by:
%       - Rejecting trials (determined by NM_SuggestRejections)
%       - Rereferencing the data (if wanted)
%       - Baseline correcting the data (if wanted)
%
% Inputs:
%   * cfg (optional): Can include the following fields:
%       - rejections: Set the rejections and do not ask the user
%       - rereference: Set as 1 to rereference
%       - baseline_correct: Set as 1 to baseline correct data
%           * If any of the above fields are omitted, and the user will be asked
%       - channels: A list of channels to include
%       - bpf: A band pass filter to apply ([low high])
%
% Outputs:
% Usage: 
%   * cfg = [];
%   * cfg.rejections = [1 56 9];
%   * cfg.baseline_correct = 0;
%   * cfg.bpf = [4 8];
%   * NM_CreateCleanMEEGData(cfg)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CreateCleanMEEGData(cfg)

% Load the unclean data
NM_LoadMEEGData();

% Default if no input
global GLA_meeg_type;
if ~exist('cfg','var')
    cfg = [];
end

% Get suggested rejections if we're not given them
clear global GLA_clean_meeg_data;
global GLA_clean_meeg_data;
if isfield(cfg,'rejections')
    GLA_clean_meeg_data.rejections = cfg.rejections;
else
    GLA_clean_meeg_data.rejections = NM_SuggestRejections();
end

% Set the rejected data
% TODO: May need to clear full data for memory
global GLA_meeg_data;
rej_cfg = [];
rej_cfg.trials = 1:length(GLA_meeg_data.data.trial);
for r = 1:length(GLA_clean_meeg_data.rejections)
    r_ind = find(rej_cfg.trials == GLA_clean_meeg_data.rejections(r),1);
    if ~isempty(r_ind)
        rej_cfg.trials = rej_cfg.trials([1:r_ind-1 r_ind+1:end]);
    end
end
GLA_clean_meeg_data.data = ft_redefinetrial(rej_cfg,GLA_meeg_data.data);

% Might only want some channels
if isfield(cfg,'channels')
    ch_cfg = [];
    ch_cfg.channel = cfg.channels;
    disp(['Using ' num2str(length(cfg.channels)) ' channels...']);
    GLA_clean_meeg_data.data = ft_preprocessing(ch_cfg,GLA_clean_meeg_data.data);
end

% See if there's a filter
if isfield(cfg,'bpf')
    disp(['Applying band pass filter: ' num2str(cfg.bpf(1)) '-' ...
        num2str(cfg.bpf(2)) 'Hz...']);
    filt_cfg = []; 
    filt_cfg.bpfilter = 'yes';
    filt_cfg.bpfreq = cfg.bpf;
    GLA_clean_meeg_data.data = ft_preprocessing(filt_cfg, GLA_clean_meeg_data.data);
    disp('Done.');
end

% Rereference maybe
GLA_clean_meeg_data.settings.rereference = 0;
if strcmp(GLA_meeg_type,'eeg')
    if isfield(cfg,'rereference')
        if cfg.rereference
            GLA_clean_meeg_data.data = NM_RereferenceEEGData(GLA_clean_meeg_data.data);
            GLA_clean_meeg_data.settings.rereference = 1;
        end
    else
        while 1
            ch = input('Rereference data (y/n)? ','s');
            if strcmp(ch,'y')
                GLA_clean_meeg_data.data = NM_RereferenceEEGData(GLA_clean_meeg_data.data);
                GLA_clean_meeg_data.settings.rereference = 1;
                break;
            elseif strcmp(ch,'n')
                break;
            end
        end
    end
end

% Baseline correct it
GLA_clean_meeg_data.settings.baseline_correct = 0;
if isfield(cfg,'baseline_correct')
    if cfg.baseline_correct
        GLA_clean_meeg_data.data = NM_BaselineCorrectMEEGData(GLA_clean_meeg_data.data);
        GLA_clean_meeg_data.settings.baseline_correct = 1;
    end
    
% Or ask
else
    while 1
        ch = input('Baseline correct data (y/n)? ','s');
        if strcmp(ch,'y')
            GLA_clean_meeg_data.data = NM_BaselineCorrectMEEGData(GLA_clean_meeg_data.data);
            GLA_clean_meeg_data.settings.baseline_correct = 1;
            break;
        elseif strcmp(ch,'n')
            break;
        end
    end
end


