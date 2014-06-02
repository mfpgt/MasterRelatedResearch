%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SUB-FUNCTION 
%   Select the parant chromosomes (natural selection)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [parentMatrix, povf, pfitness] = naturalSelection(stimMatrix, ovf, fitness, sizeGen, RSCHEM)

%Perform natural selection to survive chromosomes for next generation
% Input: 
%  stimMatrix: matrix of candidate chromosomes
%  randovf: random version of overall fitness
%  ovf: overall fitness
%  fitness: individual fitness score
%  sizeGen: size of generation
%
% Output:
%  parentMatrix: matrix contains parents for next generation
%  povf: overall fitness for chromosomes survived
%  pfitness: individual fitness for chromosomes survived


self = ovf; %selection function
    
[tmpF parentidx] = sortrows(self');
parentidx = parentidx(end - sizeGen + 1: end); % chromosomes survived
parentMatrix = stimMatrix(:,parentidx);
povf = ovf(parentidx);
pfitness=fitness(:,parentidx);

return
