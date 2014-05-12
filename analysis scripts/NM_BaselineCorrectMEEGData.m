%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_BaselineCorrectMEEGData.m
%
% Notes:
%   * Baseline corrects meeg data using ft_preproc_baselinecorrect applied
%       to each trial.
%       - Uses the entire pretrigger portion of th epoch to correct
%   
% Inputs:
%   * data (optional): The data (ft structure) to baseline correct.
%       - If this is empty, we will load the GLA_meeg_data and baseline
%       correct and set it.
%   * should_save (optional): 1 to save the GLA_meeg_data. 
%       - To be effective, needs to be called with data = [].
%
% Outputs:
%   * data: The baseline corrected data
%
% Usage: 
%   * data = NM_BaselineCorrectMEEGData(GLA_clean_meeg_data.data)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = NM_BaselineCorrectMEEGData(data, should_save)

global GLA_meeg_data;
set_data = 0;
if isempty(data)
    NM_LoadMEEGData();
    data = GLA_meeg_data.data;
    set_data = 1;
end

disp('Baseline correcting data...');
for t = 1:length(data.trial)
    data.trial{t} = ft_preproc_baselinecorrect(...
        data.trial{t},1,find(data.time{1} >0,1));
end
disp('Done.');

if set_data
    GLA_meeg_data.data = data; 
end

% Default not to save
if exist('should_save','var') && should_save
    NM_SaveMEEGData(); 
end
