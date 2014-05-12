%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SaveSubjectData.m
%
% Notes:
%   * This saves the data associated with the subject 
%
% Inputs:
%   * params (optional): A list of parameters to add to the data.
%       - Each cell should be {param_name, param_value}
%
% Outputs:
% Usage: 
%   * NM_SaveSubjectData({'data_preprocessed',1}}
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SaveSubjectData(params)

% Pretty simple...
global GLA_subject_data;
global GLA_subject;

% Shouldn't be called before we've loaded the data
if isempty(GLA_subject_data)
    error(['No data loaded for ' GLA_subject '.']);
end

% Default to not add anything
if ~exist('params','var')
    params = [];
end

% Add each parameter
for p = 1:length(params)
    GLA_subject_data.settings.(params{p}{1}) = params{p}{2};
end

% And save
if ~exist([NM_GetRootDirectory() '/analysis/' GLA_subject],'dir')
    mkdir([NM_GetRootDirectory() '/analysis/', GLA_subject]); 
end
save(NM_GetSubjectDataFilename(),'-struct','GLA_subject_data');
disp(['Saved subject data for ' GLA_subject '.']);


