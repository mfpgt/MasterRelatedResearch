%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SaveMEEGData.m
%
% Notes:
%   * Saves the current GLA_meeg_data into the correct .mat file.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SaveMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SaveMEEGData()

global GLA_meeg_data;
global GLA_meeg_type;
global GLA_epoch_type;
global GLA_subject;

% Check that we're right
if isempty(GLA_meeg_type)
    error('GLA_meeg_type not set yet.');
end
if isempty(GLA_epoch_type)
    error('GLA_epoch_type not set yet.');
end
if ~isempty(GLA_meeg_data)
    if ~strcmp(GLA_meeg_data.settings.subject,GLA_subject) ||...
            ~strcmp(GLA_meeg_data.settings.epoch_type,GLA_epoch_type) ||...
            ~strcmp(GLA_meeg_data.settings.meeg_type,GLA_meeg_type)
        error('GLA_meeg_data does not match current settings.');
    end
end


disp(['Saving ' GLA_meeg_data.settings.epoch_type ' ' ...
    GLA_meeg_data.settings.meeg_type ' data for ' ...
    GLA_meeg_data.settings.subject '...']);

% NOTE: If you run out of space, add the following option:
%   - save(NM_GetMEEGDataFilename,'-struct','GLA_meeg_data','-v7.3');
%   * But, this seems to add a lot of overhead, so use it sparingly...
save(NM_GetMEEGDataFilename,'-struct','GLA_meeg_data');
disp('Done');


