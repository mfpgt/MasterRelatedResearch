%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_FilterMEEGData.m
%
% Notes:
%   * Filters the current meeg data. 
%   * This should probably be done on the raw data by setting the
%       meeg_filter_raw variable.
%       - This will then be done during initialization.
%   * Will set the appropriate GLA_meeg_data.setting filter variables
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_FilterMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_FilterMEEGData()

global GLA_subject_data;
NM_LoadSubjectData({});

% Make sure we don't want to filter the raw data
if GLA_subject_data.settings.meeg_filter_raw
    error('Settings call for filtering raw data. Call NM_InitializeMEEGData instead.');
end

% Otherwise, load and go
NM_LoadMEEGData();
   
% Set the parameters
global GLA_meeg_data;
GLA_meeg_data.settings.filter_raw = 0;
GLA_meeg_data.settings.hpf = GLA_subject_data.settings.meeg_hpf;
GLA_meeg_data.settings.lpf = GLA_subject_data.settings.meeg_lpf;
GLA_meeg_data.settings.bsf = GLA_subject_data.settings.meeg_bsf;
GLA_meeg_data.settings.bsf_width = GLA_subject_data.settings.meeg_bsf_width;

% High pass...
if ~isempty(GLA_meeg_data.settings.hpf)
    disp(['Applying high pass filter: ' num2str(GLA_meeg_data.settings.hpf) 'Hz...']);
    cfg = []; 
    cfg.hpfilter = 'yes';
    cfg.hpfreq = GLA_meeg_data.settings.hpf;
    if GLA_meeg_data.settings.hpf < 1
        cfg.hpfilttype = 'fir'; % Necessary to not crash
    end
    GLA_meeg_data.data = ft_preprocessing(cfg, GLA_meeg_data.data);
    disp('Done.');
end

% Low pass...
if ~isempty(GLA_meeg_data.settings.lpf)
    disp(['Applying low pass filter: ' num2str(GLA_meeg_data.settings.lpf) 'Hz...']);
    cfg = []; 
    cfg.lpfilter = 'yes';
    cfg.lpfreq = GLA_meeg_data.settings.lpf;
    GLA_meeg_data.data = ft_preprocessing(cfg, GLA_meeg_data.data);
    disp('Done.');
end

% Notches...
for f = 1:length(GLA_meeg_data.settings.bsf)
    disp(['Applying band stop filter: ' num2str(GLA_meeg_data.settings.bsf(f)) 'Hz...']);
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [GLA_meeg_data.settings.bsf(f)-GLA_meeg_data.settings.bsf_width ...
        GLA_meeg_data.settings.bsf(f)+GLA_meeg_data.settings.bsf_width];
    GLA_meeg_data.data = ft_preprocessing(cfg, GLA_meeg_data.data);
    disp('Done.');
end

% And save
NM_SaveMEEGData();



