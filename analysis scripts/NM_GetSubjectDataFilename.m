%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetSubjectDataFilename.m
%
% Notes:
%   * Returns the file name of the file holding the current subject data.
%
% Inputs:
% Outputs:
%   f_name: The absolute path of the file.
%
% Usage: NM_GetSubjectDataFilename()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f_name = NM_GetSubjectDataFilename()

global GLA_subject;
f_name = [NM_GetRootDirectory() '/analysis/' ...
    GLA_subject '/' GLA_subject '_subject_data.mat'];
