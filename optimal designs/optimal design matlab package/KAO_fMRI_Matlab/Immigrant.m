%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SUB-FUNCTION of Inner loop:
%   Immigrant
%   Reference: Liu and Frank (2004) NumeroImage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ImMatrix = Immigrant(lenStim, numSTYPE, nImmig)

% Generate immigrants
%  input:
%   lenStim: length of stimulus sequence
%   nImmig: Number of immigrants
%   numSTYPE: Number of stimulus types
%
%  output;
%   ImMatrix: Immigrants

% Use mix design: random + block

for z = 1:nImmig
    Lrand = floor(rand(1)*lenStim); % length of random design
    Lblk = lenStim - Lrand; % length of block design
    % to assure both designs have certain length
    if (Lrand <= 10 ), Lrand = 0;,Lblk = lenStim;,end
    if (Lblk <= 10 ), Lrand = lenStim;,Lblk = 0;,end

    % block design
    blockdesign1 = [];
    blockdesign2 = [];
    randdesign =[];
    if (Lblk > 0)
        numblk = 1 + floor(rand(1)*10); % 1 block to 10 blocks
        [blockdesign1, blockdesign2] = GenBlock(numSTYPE, Lblk, numblk);

    end
    if (Lrand > 0)
        randdesign = mod(floor(rand(Lrand,1)*(numSTYPE+1)),(numSTYPE+1));
    end
    if (rand(1) < 0.25)
        mixseq = [blockdesign1;randdesign];
    elseif (rand(1) < 0.5 & rand(1) >= 0.25)
        mixseq = [randdesign;blockdesign1];
    elseif (rand(1) < 0.75 & rand(1) >=0.5)
        mixseq = [blockdesign2;randdesign];
    else
        mixseq = [randdesign;blockdesign2];
    end
    ImMatrix(:,z) = mixseq(1:lenStim);
end
return