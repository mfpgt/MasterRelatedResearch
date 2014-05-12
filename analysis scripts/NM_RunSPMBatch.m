%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_RunSPMBatch.m
%
% Notes:
%   * Small helper to run a constructed spm batch file.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_RunSPMBatch([GLA_subject '_preprocess_batch.mat'])
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_RunSPMBatch(mat_file)

% Initialize the jobman
disp(['Running batch: ' mat_file '...']);
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% And run the preprocessing job
spm_jobman('run', mat_file);
disp('Done.');
