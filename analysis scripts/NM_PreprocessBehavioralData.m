%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_PreprocessBehavioralData.m
%
% Notes:
%   * A wrapper function to run all of the steps necessary to create the
%       behavioral data for analysis.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_PreprocessBehavioralData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_PreprocessBehavioralData()

global GLA_subject;
type = NM_GetBehavioralDataType();
disp(['Preprocessing ' type ' behavioral data for ' GLA_subject '...']);

% Make sure we're ready
NM_LoadSubjectData({{'behavioral_data_checked',1}});

% Initialize
NM_InitializeBehavioralData()

% Remove outliers, etc.
NM_SetBehavioralRejections();

% Resave...
NM_SaveSubjectData({{[NM_GetBehavioralDataType() '_behavioral_data_preprocessed'],1}});
disp(['Behavioral data for ' NM_GetBehavioralDataType()  ' preprocessed for ' GLA_subject '.']);

