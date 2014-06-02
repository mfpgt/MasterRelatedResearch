%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Generate a deconvoluted matrix
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function deconvM = DconvMTX(stimList, numScan, numSTYPE, tempHRF, ITI, TR, dT)
%
% Generate the deconvoluted matrix
% Inputs:
%   stimList: stimulus sequence
%   numScan: number of scans
%   numSTYPE: number of stimulus types
%   tempHRF: length of HRF
%   ITI: interval between stimulus onsets
%   TR: interval between scans
%   dT: discretization interval

% Output:
%   dconvM: deconvoluted Matrix

lagHRF = floor(tempHRF/dT) + 1;

deconvM = [];

if (ITI == TR)
    deltas = zeros(numScan, numSTYPE);
    for i = 1:numSTYPE
        deltas(find(stimList ==i),i) = 1;
    end
    deconvM = zeros(numScan, lagHRF*numSTYPE); %% tempHRF starts from 0
    idx = [1:numSTYPE];
    deconvM(:,(idx - 1)*(lagHRF*1)+1) = deltas;
    for j = 2:lagHRF
        deconvM(j:end, (idx - 1)*(lagHRF*1) + j) = deltas(1:numScan-j+1,:);
    end
else
    TRT = TR/dT;
    maxlag = ceil(lagHRF/TRT);
    deltasM = zeros(numScan, TRT, numSTYPE);
    deconvMM = [];
    for i = 1:numSTYPE
        onsets = find(stimList==i) .* ITI;     %% onset time of stimuli
        scans = ceil(onsets ./ TR);            %% next scan
        gaps= (scans .* TR - onsets) ./dT;     %% gaps between stimulus and next scan, in terms of dT
        deltasM = zeros(numScan,TRT);
        for j = 1:size(scans,1)
            deltasM(scans(j), gaps(j)+1) = 1;
        end
        deconvMs = zeros(numScan, maxlag*TRT);
        for j = 1:maxlag
            deconvMs(j:end, (j-1)*TRT + 1: (j-1)*TRT + TRT) =...
                deltasM(1:numScan-j+1,:);
        end
        deconvMM = [deconvMM deconvMs(:,1:lagHRF)];
    end
    deconvM = deconvMM;
end
return