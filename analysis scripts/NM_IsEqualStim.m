%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_IsEqualStim.m
%
% Notes:
%   * This function checks to see if two log stimuli are "equal".
%       - Despite my best efforts, the formatting seems to vary enough to
%           make this really annoying (along the capitals used in the
%           probes). 
%       - So, essentially this checks all stimuli normally except those
%           with accents, which it just assumes are equal.
%       - I haven't found any problems manually inspecting, but this could
%           obviously be made better...

% Inputs:
%   * stim_1: One stimulus to test
%   * stim_2: The other stimulus to test
%
% Outputs:
%   * is_equal: 1 if equal (or if either stimulus has an accent).
%
%
% Usage: is_equal = NM_IsEqualStim('tot','tôt')
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function is_equal = NM_IsEqualStim(stim_1, stim_2)

% Let capitalization slide...
is_equal = strcmpi(stim_1, stim_2);

% Might allow some wiggle room
if ~is_equal

    % Might be just formatting
    if ~isempty(find(stim_1-0 > 128, 1)) ||...
        	~isempty(find(stim_2-0 > 128,1))
        is_equal = 1;
    end
end
