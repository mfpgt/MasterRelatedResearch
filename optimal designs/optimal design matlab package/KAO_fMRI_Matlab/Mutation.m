%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SUB-FUNCTION of Inner loop:
%   Mutation 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stimMatrix = Mutation(stimMatrix,pMutat)
%
% Randomly choose pMutat portion of stimulus to mutate
%  input:
%   stimMatrix: matrix of stimulus sequences
%   pMutate: proportion of stimulus to mutate
%  
%  output;
%   stimMatrix: stimulus sequences of a generation

dimstim = size(stimMatrix);
totalstim = dimstim(1)*dimstim(2);
draw = floor(rand(floor(totalstim*pMutat),1)*totalstim);
draw(find(draw==0)) = 1;
M = max(max(stimMatrix)) + 1;
stimMatrix(draw)=floor(M*rand(size(draw)));
stimMatrix(find(stimMatrix==M)) = M - 1;
return