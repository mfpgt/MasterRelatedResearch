%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AddStructToArray.m
%
% Notes:
%   * This is a useful helper function to add a struct type to an array
%       - Basically it just checks to see if the array is empty and adds
%       appropriately.
%
% Inputs:
%   * s: The structure to add
%   * a: The array to add it to
%
% Outputs:
%   * a: The array with the struct added
%   
% Usage: 
%   * trial_triggers = NM_AddStructToArray(triggers(t_ind),trial_triggers)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function a = NM_AddStructToArray(s, a)
if isempty(a)
    a = s;
else
    a(end+1) = s(1); 
end

