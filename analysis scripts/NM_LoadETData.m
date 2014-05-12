%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_LoadETData.m
%
% Notes:
%   * This function sets the GLA_et_data variable
%       - It will use the current data if it matches the current
%           GLA_subject and GLA_epoch_type variables.
%       - Otherwise it will load any saved data.
%       - Finally, it will ask to create the data if none is found.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_LoadETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_LoadETData()

global GLA_subject;
global GLA_epoch_type;
disp(['Loading ' GLA_epoch_type ' eye tracking data for ' GLA_subject '...']);
NM_LoadSubjectData();

% Default to use matching data in memory
global GLA_et_data;
if isempty(GLA_et_data) || ~strcmp(GLA_subject,GLA_et_data.settings.subject) ||...
        ~strcmp(GLA_epoch_type,GLA_et_data.settings.epoch_type)

    % Load if we've made one
    f_name = NM_GetETDataFilename();
    if exist(f_name,'file')
        GLA_et_data = load(f_name);

    % Otherwise, make sure we want to create it
    else
        while 1
            ch = input([GLA_epoch_type ' et data for '...
                GLA_subject ' not found. Create (y/n)? '],'s');
            if strcmp(ch,'y')
                break;
            elseif strcmp(ch,'n')
                error('Data not loaded.');
            end
        end
        NM_InitializeETData();
    end
end
disp('Done.');
