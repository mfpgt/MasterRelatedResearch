%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SaveBehavioralData.m
%
% Notes:
%   * Saves the current behavioral data (GLA_behavioral_data) to a mat file
%       - The file given by NM_GetBehavioralDataFilename()
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SaveBehavioralData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SaveBehavioralData()

global GLA_behavioral_data; %#ok<NUSED>
disp('Saving behavioral data...');

% Save the pieces
save(NM_GetBehavioralDataFilename(),'-struct','GLA_behavioral_data');
disp('Done');


