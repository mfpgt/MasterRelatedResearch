%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Generate a block design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [DBlk1 DBlk2] = GenBlock(numSTYPE, lenStim, numBlock );

% Generate a block design
% Inputs:
%   numSTYPE: number of active stimulus types (excluing rests)
%   lenStim: length of stimulus sequence
%   numBlock: number of blocks

% Output:
%   DBlk1: Block design of the form NANBNCN
%   DBlk2: Block design of the form NABCNABCN

sizeBlk = round(lenStim/(numBlock*(numSTYPE+1))); % number of events within a block
if (sizeBlk == 0), sizeBlk = 1;,end
nrest = lenStim - sizeBlk*numBlock*numSTYPE; % number of rests
nrest1 = floor(nrest/(1+numSTYPE*numBlock)); % number of rests in a type 1 block
nrest2 = floor(nrest/(1+numBlock));% number of rests in a type 2 block

buildblk1 = [ones(1, sizeBlk), zeros(1,nrest1)];
DBlk1 = [zeros(1,nrest1), kron(kron(ones(1,numBlock),[1:numSTYPE]), buildblk1)]';


if size(DBlk1,1) < lenStim
    DBlk1(end+1:lenStim) = 0;
elseif size(DBlk1,1) > lenStim
    DBlk1 = DBlk1(1:lenStim);
end

if (numSTYPE ~= 1)
    DBlk2 = [zeros(1,nrest2), ...
        kron(ones(1,numBlock), [kron([1:numSTYPE],ones(1,sizeBlk)), zeros(1,nrest2)])]';

    if size(DBlk2,1) < lenStim
        DBlk2(end+1:lenStim) = 0;
    elseif size(DBlk2,1) > lenStim
        DBlk2 = DBlk2(1:lenStim);
    end
else
    DBlk2 = DBlk1;
end

return
