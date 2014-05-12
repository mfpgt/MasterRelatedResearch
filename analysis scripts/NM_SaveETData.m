%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SaveETData.m
%
% Notes:
%   * Saves GLA_et_data to the current eye tracker data .mat file.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SaveETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SaveETData()

global GLA_epoch_type;
global GLA_et_data;
global GLA_subject;
if isempty(GLA_et_data)
    disp(['WARNING: No ' GLA_epoch_type ' eye tracking data to save for ' GLA_subject '.']);
else
    disp(['Saving ' GLA_et_data.settings.epoch_type ' eye tracking data for '...
        GLA_et_data.settings.subject '...']);
    save(NM_GetETDataFilename(),'-struct','GLA_et_data');
end

disp('Done');


