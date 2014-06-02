%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MAIN Subroutine 
%
% References:
%  (1) Wager and Nichols (2003): NeuroImage
%  (2) Liu and Frank (2004): NeuroImage
%  (3) Liu (2004): NeuroImage
%  (4) Kao et al (2008): Submitted to NeuroImage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Out = fMRIMOD(Inp);

CntTime = cputime;

% check! frequntly occured error
if (Inp.nSTYPE == 1 & Inp.MOweight(1,4) ~= [0 0])
    disp('!!! WARNING: First two weights should be set to zero (automatically fixed...) !!!')
    Inp.MOweight(1) = 0;
    Inp.MOweight(4) = 0;
    total = (Inp.MOweight(2) + Inp.MOweight(3));
    Inp.MOweight(2) = Inp.MOweight(2) / total;
    Inp.MOweight(3) = Inp.MOweight(3) / total;
end

MESE=Inp;

MixPro = 1/3; % Porportion of mixed designs in the inISIal generation
% Proportion should be small for small sequence

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculating necessary parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% stimulus types (excluding rest)
MESE.stimTYPE = [1:MESE.nSTYPE];

% number of Scans
MESE.numScan = floor(MESE.nEvents*MESE.ISI/MESE.TR); % number of scans / length of data

MESE.whiteM = MESE.V2 - MESE.V2*MESE.Smat*inv(MESE.Smat'*MESE.V2*MESE.Smat)*MESE.Smat'*MESE.V2; %V(I-P)V

%########## m-sequence and its HRF estimation efficiency ################
disp(' ---> Generating m-sequence & its efficiency....');
m.base =MESE.nSTYPE+1;
switch (m.base)
    case{2,3,4,5,7,8,9,11,13}
        m.power = round(log(MESE.nEvents)/log(m.base));
        m.shift =0;
        mseq = gen_mseq(m);
        mseq(end+1,:) = 0;
        while (size(mseq,1) < MESE.nEvents)
            mseq = [mseq;mseq];
        end
        mseq = mseq(1:MESE.nEvents,:);
    otherwise
        disp(' WARNGING: m-sequence not exist, use random sequence instead....');
        for z = 1:500
            mseq(:,z)=  mod(floor(rand(MESE.nEvents,1)*(MESE.nSTYPE+1)),...
                (MESE.nSTYPE+1));
        end
end

for z=1:size(mseq,2)
    stimList = mseq(:,z);
    deconvM = DconvMTX(stimList, MESE.numScan, MESE.nSTYPE, MESE.durHRF, ...
        MESE.ISI, MESE.TR, MESE.dT);
    EHRF(z) = HRFEfficiency(deconvM, MESE.whiteM, MESE.CX, MESE.Opt);
end

gmseq = mseq(:,find(EHRF==max(EHRF)));
gmseq = gmseq(:,1); %*** the best m-sequence to be included in the inISIal designs

clear mseq EHRF deconvM stimList m

%########## Block design and its detection power ################
disp(' ---> Generating block desing & its power ....');
MaxNevent = floor(MESE.nEvents / (MESE.nSTYPE + 1)); %% max number of events in a block
numBlocks = [1 2 3 4 5 10 15 20 25 30 40];
BlkAmp = [];
designBlk=[];
for i = 1:size(numBlocks,2);
    [blk1 blk2] = GenBlock(MESE.nSTYPE, MESE.nEvents, numBlocks(i));
    stimList = blk1;
    deconvM = DconvMTX(stimList, MESE.numScan, MESE.nSTYPE, MESE.durHRF,...
        MESE.ISI, MESE.TR, MESE.dT);
    BlkAmp(end+1) = AmpEfficiency(deconvM, MESE.basisHRF, MESE.nSTYPE, ...
        MESE.whiteM, MESE.CZ, MESE.Opt);
    designBlk(:,end+1) = blk1;

    if (MESE.nSTYPE ~= 1)
        stimList = blk2;
        deconvM = DconvMTX(stimList, MESE.numScan, MESE.nSTYPE, Inp.durHRF,...
            MESE.ISI, MESE.TR, MESE.dT);
        BlkAmp(end+1) = AmpEfficiency(deconvM, MESE.basisHRF, MESE.nSTYPE, ...
            MESE.whiteM, MESE.CZ, MESE.Opt);
        designBlk(:,end+1) = blk2;
    end
end

blkseq =designBlk(:,find(BlkAmp == max(BlkAmp)));
blkseq = blkseq(:,1);

clear BlkAmp designBlk numBlocks blk1 blk2 deconvM

%########## Counterbalancing and desired frequency ################
if (MESE.nSTYPE > 1)
    disp(' ---> finding maximum for counterbalancing & desired frequency ....');
    LstWant = find(MESE.stimFREQ == min(MESE.stimFREQ));
    LstWant = LstWant(1);
    stimList = LstWant.*ones(MESE.nEvents,1);
    MESE.CBalWorst= getcBal(stimList, MESE.cbalR, MESE.nSTYPE, MESE.stimFREQ);  %counterbalancing
    MESE.DFreqWorst= getDFreq(stimList, MESE.nSTYPE, MESE.stimFREQ); %desired frequency
    clear stimList
end

%################ Generating mixed designs = mseq + block design ##################
if (MixPro ~= 0)
    disp(' ---> Generating mixed desings ....');
    Nmix = round(MixPro*MESE.sizeGen); %% number of mix designs to be generated
    bstart = [floor(20+(MESE.nEvents-40)/Nmix):floor((MESE.nEvents-40)/Nmix):MESE.nEvents-20];
    Nmix = size(bstart,2);
    m.base =MESE.nSTYPE+1;
    m.shift =0;
    for i = 1:Nmix;
        m.power = round(log(bstart(i))/log(m.base));
        mseq = gen_mseq(m);  % m-sequence
        mseq = [mseq(:,1);0];
        while (size(mseq,1) < bstart(i))
            mseq = [mseq;mseq];
        end
        mseq = mseq(1:bstart(i));
        blen = MESE.nEvents - size(mseq,1); % length of block design
        SampleEvery = floor(size(blkseq,1)/blen);
        if SampleEvery == 0, SampleEvery=1;,end
        blkseqm = blkseq(1:SampleEvery:end);
        if size(blkseqm,1) < blen
            blkseqm(end+1:blen) = 0;
        else
            blkseqm = blkseqm(1:blen);
        end
        if (rand(1) <0.5)
            mix(:,i) = [mseq;blkseqm];
        else
            mix(:,i) = [blkseqm;mseq];
        end;
    end;
    clear m bstart mseq blkseqm
end;

% InISIal parent stimulus sequences
disp(' ---> Generating initial sequences ....');
MESE.parentMatrix(:,1) = mod(floor(rand(MESE.nEvents,1)*(MESE.nSTYPE+1)),(MESE.nSTYPE+1));
if (exist('gmseq','var') ~= 0), MESE.parentMatrix(:,end+1) =  gmseq;, end
if (exist('blkseq','var') ~= 0), MESE.parentMatrix(:,end+1) =  blkseq;, end
if (exist('mix','var') ~= 0)
    MESE.parentMatrix(:,end+1:end+size(mix,2))=mix; % mixed design;
end
start = size(MESE.parentMatrix,2)+1;
if start < MESE.sizeGen
    for z = start:MESE.sizeGen
        MESE.parentMatrix(:,z) = mod(floor(rand(MESE.nEvents,1)*(MESE.nSTYPE+1)),...
            (MESE.nSTYPE+1)); %##### inISIal parents matrix
    end
else
    %% use random search
    for z = 1:MESE.sizeGen
        MESE.parentMatrix(:,z) = mod(floor(rand(MESE.nEvents,1)*(MESE.nSTYPE+1)),...
            (MESE.nSTYPE+1)); %##### inISIal parents matrix
    end
end

clear gmseq blkseq mix;
%########## InISIal run #################
disp(' ---> Start Searching ....');
Out = GALoop(MESE);

Out.timespend = cputime - CntTime;
disp(['     Time spend: ' num2str(Out.timespend/60) ' minutes']);

save(Inp.filename,'Inp', 'Out');
end
