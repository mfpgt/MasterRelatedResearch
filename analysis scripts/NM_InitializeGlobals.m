%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_InitializeGlobals.m
%
% Notes:
%   * This function sets the globals necessary to drive the analysis.
%       - This should (and must at least in some form) be run before any 
%           analysis is started. 
%   * Change the values in this file to run a different analysis.
%       - See comments in the code for the various globals.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_InitializeGlobals()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_InitializeGlobals()

% These are the folders at the top level of the analysis. To begin an
%   analysis, the following folders exist, each containing a folder for
%   each subject, named with their NIP:
%   * logs: Contains the _data.txt and _log.txt file from the experiment.
%       - Any non-used trials (i.e. from aborted runs) should be deleted.
%       * The fMRI analysis should also contain a _localizer_list.csv file
%           containing the localizer stimuli that was run.
%   * eye_tracking_data: Contains the converted eye tracking data.
%       - These should be named NIP_run_#.asc (1-5); NIP_baseline.asc
%   * eeg_data: For the M/EEG experiment, this should contain the converted
%       eeg data for each subject.
%       - Named: NIP_run_#.raw (1-5); NIP_baseline.raw

% Home
% global GLA_meeg_dir; GLA_meeg_dir = '/Users/Doug/Documents/neurospin/meeg';
% global GLA_fmri_dir; GLA_fmri_dir = '/Users/Doug/Documents/neurospin/fmri';

% Work
global GLA_meeg_dir; GLA_meeg_dir = '/neurospin/meg/meg_tmp/SimpComp_Doug_2013';
global GLA_fmri_dir; GLA_fmri_dir = '/neurospin/unicog/protocols/IRMf/SimpComp_Bemis_2013';

% This is the NIP of the subject we're analyzing
global GLA_subject; GLA_subject = 'bd120417';


% This is the type of data we're analyzing. 
%   - Can be either 'fmri' or 'meeg'
global GLA_rec_type; GLA_rec_type = 'fmri';

% And the optional globals
disp(['Set analysis for subject ' GLA_subject ' and ' GLA_rec_type ' data']);


