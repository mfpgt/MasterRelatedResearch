%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   desired frequency
%
%  Reference:
%   Wager and Nichols (2003): NeuroImage p. 293-309
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cFreq = getDFreq(stimList,  numSTYPE, stimFREQ)

% calculates the desired frequency metric
%  zeros are excluded in calculation
%
% Inputs
%  stimList: stimulus sequence
%  numSTYPE: number of active stimulus types (excluding rests)
%  stimFREQ: required frequency of stimulus types
%
% Outputs
%  cFreq: desired frequency measuremnt

NstimFREQ = stimFREQ ./ sum(stimFREQ); %##### normalize the required frequency
stimListN = stimList(find(stimList~=0)); %###### exclude rests
numNonrest = size(stimListN,1); %#### number of nonresting events

freqs = zeros(1,numSTYPE);

for i = 1:numSTYPE
    freqs(i) = sum(stimList == i);
end
cFreq = sum(floor(abs(freqs - numNonrest*NstimFREQ )));
return
