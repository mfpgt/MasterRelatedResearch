%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_RereferenceEEGData.m
%
% Notes:
%   * Rereferences eeg data to the mean 
%       - Should be called after trials are rejected
%   
% Inputs:
%   * data (optional): The data (ft structure) to rereference.
%       - If this is empty, we will load the GLA_meeg_data and rereference
%           and set it.
%   * should_save (optional): 1 to save the GLA_meeg_data. 
%       - To be effective, needs to be called with data = [].
%
% Outputs:
%   * data: The rereferenced data
%
% Usage: 
%   * data = NM_RereferenceEEGData(GLA_clean_meeg_data.data)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = NM_RereferenceEEGData(data, should_save)

% Make sure we're eeg
global GLA_meeg_type;
if ~strcmp(GLA_meeg_type,'eeg')
    return;
end

% Make sure we really mean it (i.e. can't just leave it out to set
global GLA_meeg_data;
set_data = 0;
if isempty(data)
    NM_LoadMEEGData();
    data = GLA_meeg_data.data;
    set_data = 1;
end

% Defaults to reference to the mean...
disp('Rereferencing data...');
for t = 1:length(data.trial)
    data.trial{t} = ft_preproc_rereference(data.trial{t});
end
disp('Done.');

if set_data
    GLA_meeg_data.data = data; 
end

% Default not to save
if exist('should_save','var') && should_save
    NM_SaveMEEGData(); 
end

