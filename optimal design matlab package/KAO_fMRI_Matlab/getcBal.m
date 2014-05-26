%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Obtain Counterbalancing measurement:
%
%  Reference:
%   Wager and Nichols (2003): NeuroImage p. 293-309
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cBal= getcBal(stimList, cbalR, numSTYPE, stimFREQ)

%  Obtain Counterbalancing measurement:
%  zeros are excluded in calculation
%
% Inputs
%  stimList: stimulus sequence (column vector)
%  cbalR: order of counterbalancing
%  numSTYPE: number of active stimulus types (excluding rests)
%  stimFREQ: required frequency of stimulus types
%
% Outputs
%  cBal: counterbalancing fitness value (an array)

NstimFREQ = stimFREQ ./ sum(stimFREQ); %##### normalize the required frequency
stimListN = stimList(find(stimList~=0)); %###### exclude rests
numNonrest = size(stimListN,1); %#### number of nonresting events

ObsN = zeros(numSTYPE, numSTYPE, cbalR); 

for i = 1:numSTYPE
    ObsTPi = find(stimListN == i)';
    clear tempDiff;
    tempDiff(1,:) = diff(ObsTPi);
    lenDiff = size(tempDiff,2);
    sumLft = cbalR - 1;
    m = 1;
    while ((sumLft > 0) & (lenDiff - m + 1) >= 1)
        m = m + 1;
        tempDiff(m,:) = [tempDiff(1,m:lenDiff) + tempDiff(m-1,1:(lenDiff - m + 1)),  zeros(1,m-1)];
        sumLft = sumLft - 1;
    end;
    for k = 1:cbalR
        ObsN(i,i,k) = sum(sum(tempDiff == k));
    end
    for j = 1:numSTYPE
        if j ~= i
            ObsTPj = find(stimListN == j);
            for k = 1:cbalR
                mysum = 0;
                for m = 1:length(ObsTPi)
                    mysum = mysum + sum(ObsTPj-ObsTPi(m) == k);
                end
                ObsN(i,j,k) = mysum;
            end
        end
    end
end

%###  calculating counterbalacing measurement
for r = 1:cbalR
    ExpN(:,:,r) = (numNonrest - r) .* (NstimFREQ' * NstimFREQ); %### expected frequency
end

cBal = sum(sum(sum(floor(abs(ObsN - ExpN)))));

return
