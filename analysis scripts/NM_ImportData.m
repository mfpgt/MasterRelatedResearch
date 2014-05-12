%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Run_Analysis.m
%
% Notes:
%   * This function will import and convert (though see NM_ImportfMRIData)
%       the raw data from the acquisition folders for the analysis.
%   - The only requirement is that the subject_notes.txt file is correct.
%       - Each analysis has a _subject_notes.txt file (in the experiment
%           folder) that should have an entry for each subject. 
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_ImportData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_ImportData()

% For now, this needs to be done manually on Linux. Works on a Mac...
% NM_ConvertETData();

% Import our two big data sets and convert for later analysis.
NM_ImportMEGData();
NM_ImportfMRIData();



