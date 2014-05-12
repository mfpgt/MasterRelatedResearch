%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_ConvertETData.m
%
% Notes:
%   * Loads  GLA_subject_data or creates it if not initialized.
%       - This data holds all of the analysis parameters for the subject.
%       - This data is stored in the global GLA_subject_data.
%       - This data is stored in analysis/NIP/NIP_subject_data.mat.
%   * This should be called before most functions to make sure everything
%       is set correctly.
%
% Inputs:
%   * settings: A list of cells, each containing a setting name / value
%       pair. The GLA_subject_data is then checked to make sure these value
%       / name pairs are present and match
%       - Value can be either a number or a string
%   
% Outputs:
% Usage: 
%   * NM_LoadSubjectData({{'log_parsed',1}})
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function NM_LoadSubjectData(settings)

% Load up the subject data
disp('Loading subject data...');

% Default to use matching data in memory
global GLA_subject_data;
global GLA_subject;
global GLA_rec_type;
if isempty(GLA_subject_data) || ...
        ~strcmp(GLA_subject,GLA_subject_data.settings.subject) ||...
        ~strcmp(GLA_rec_type,GLA_subject_data.settings.rec_type) 

    % Load if we've made one
    f_name = NM_GetSubjectDataFilename();
    if exist(f_name,'file')
        GLA_subject_data = load(f_name);

    % Or initialize
    else
        while 1
            ch = input(['Subject data for '...
                GLA_subject ' not found. Create (y/n)? '],'s');
            if strcmp(ch,'y')
                break;
            elseif strcmp(ch,'n')
                error('Data not loaded.');
            end
        end
        NM_InitializeSubjectData();
    end
end
disp('Done.');


% Then check the params
if ~exist('settings','var') || isempty(settings)
    return;
end
for s = 1:length(settings)
    checkSetting(settings{s}{1}, settings{s}{2});
end


% Check each setting
function checkSetting(param, val)

global GLA_subject_data;

% Might not exist or is not equal
if ~isfield(GLA_subject_data.settings,param) || ...
        (ischar(val) && ~strcmp(GLA_subject_data.settings.(param),val)) ||...
        (isnumeric(val) && GLA_subject_data.settings.(param) ~= val)
    
    
    % see if we want to go anyway
    disp(['Parameter ' param ' not equal to ' num2str(val) '.']);
    while 1
        ch = input('Set and continue? (y/n) ','s');
        if strcmp(ch,'y')
            NM_SaveSubjectData({{param, val}});
            break;
        elseif strcmp(ch,'n')
            error('Parameter not as expected.'); 
        end
    end
end



