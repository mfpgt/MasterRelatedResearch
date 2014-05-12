%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_LoadMEEGData.m
%
% Notes:
%   * Loads the meeg data for the current analysis.
%       - Will use the current GLA_meeg_data, if it matches the settings.
%       - Otherwise, will load the data from the .mat file if it exists.
%       - Otherwise, will initialize the data, if we want.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_LoadMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_LoadMEEGData()

global GLA_subject;
global GLA_epoch_type;
global GLA_meeg_type;
disp(['Loading ' GLA_epoch_type ' ' GLA_meeg_type ' data for ' GLA_subject '...']);
NM_LoadSubjectData();

% Default to use matching data in memory
global GLA_meeg_data;
if isempty(GLA_meeg_data) || ~strcmp(GLA_subject,GLA_meeg_data.settings.subject) ||...
        ~strcmp(GLA_epoch_type,GLA_meeg_data.settings.epoch_type) ||...
        ~strcmp(GLA_meeg_type,GLA_meeg_data.settings.meeg_type)
    
    % Load if we've made one
    f_name = NM_GetMEEGDataFilename();
    if exist(f_name,'file')
        GLA_meeg_data = load(f_name);

    % Otherwise initialize
    else
        while 1
            ch = input([GLA_epoch_type ' ' GLA_meeg_type ' data for '...
                GLA_subject ' not found. Create (y/n)? '],'s');
            if strcmp(ch,'y')
                break;
            elseif strcmp(ch,'n')
                error('Data not loaded.');
            end
        end
        NM_InitializeMEEGData();
    end
end
disp('Done.');
