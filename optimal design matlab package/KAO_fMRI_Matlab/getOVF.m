%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SUB-FUNCTION
%   get overall fitness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ovf fitness]= getOVF(MESE, targetM)

% calcualte the overall fitness score
%  input:
%   MESE: the MESE structure contains what we need
%   targetM: the target matrix
%
%  output;
%   ovf: overall fitness
%   fitness: indiviudal fitness

%###### Reassign the variable names (for convenience purpose)
MESEfields = fieldnames(MESE);
for i = 1:length(MESEfields)
    eval([MESEfields{i} ' = MESE.' MESEfields{i} ';'])
end

numList = size(targetM,2); %number of the sequences to be calculated

%%%calcuate the efficiencies

for z = 1:numList

    DFreq = 0;, CBal = 0;, EAmp = 0;,EHRF = 0;
    stimList = targetM(:,z);

    if (MOweight(1) > 0)
        CBal = getcBal(stimList, cbalR, nSTYPE, stimFREQ);
        CBal = 1 - CBal/CBalWorst;
    end

    if (MOweight(2) > 0)
        deconvM = DconvMTX(stimList, numScan, nSTYPE, durHRF, ISI, TR, dT);
        EAmp = AmpEfficiency(deconvM, basisHRF, nSTYPE, whiteM, CZ, Opt);
        EAmp = EAmp /MaxFd;
    end

    if (MOweight(3) > 0)
        if (MOweight(2) == 0)
            deconvM = DconvMTX(stimList, numScan, nSTYPE, durHRF, ISI, TR, dT);
        end
        EHRF = HRFEfficiency(deconvM, whiteM, CX, Opt);
        EHRF = EHRF / MaxFe;
    end
    if (MOweight(4) > 0)
        DFreq = getDFreq(stimList,  nSTYPE, stimFREQ); %desired frequency
        DFreq = 1 - DFreq/DFreqWorst;
    end
    DEffMatrix(:,z) = [CBal;EAmp; EHRF;DFreq]; %design efficiency matrix
end
fitness = DEffMatrix;
ovf = MOweight*DEffMatrix;
return

