%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SUB-FUNCTION:
%    genetic algorithm
%
% References:
%  (1) Wager and Nichols (2003): NeuroImage
%  (2) Liu and Frank (2004): NeuroImage
%  (3) Liu (2004): NeuroImage
%  (4) Kao et al (2008): Submitted to NeuroImage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function GA = GALoop(MESE)

%###### Reassign the variable names (for convenience purpose)
MESEfields = fieldnames(MESE);
for i = 1:length(MESEfields)
    eval([MESEfields{i} ' = MESE.' MESEfields{i} ';'])
end

GA.bestOVF=-99999;

%############## start of GA ############

for g = 1:numITR
    if (g == 1)
        %%%calcuate the efficiencies for parents
        [povf pfitness]= getOVF(MESE, parentMatrix);
    end
    stimMatrix = Crossover(parentMatrix, 2, povf); %Crossover to get 2*sizeGen chromosomes

    stimMatrix(:,1:sizeGen) = Mutation(stimMatrix(:,1:sizeGen),qMutate); %mutation

    %%%calcuate the efficiencies for offsprings
    [oovf ofitness]= getOVF(MESE, stimMatrix(:,1:sizeGen));
    %##########################################################

    if nImmigrant > 0
        stimMatrix(:,2*sizeGen+1:2*sizeGen+nImmigrant) = Immigrant(nEvents, nSTYPE, nImmigrant); %immigrant
        [iovf ifitness]= getOVF(MESE, stimMatrix(:,2*sizeGen+1:end));
    end
    ovf = [oovf,povf,iovf];
    fitness=[ofitness, pfitness, ifitness];

    %###### Find the best fit in the current generation
    mostfit = find(ovf == max(ovf));
    mostfit = mostfit(1); %the first location of the best fit

    %############### Keep tracking of the best one ###############
    if (ovf(mostfit) > GA.bestOVF) %## improvement
        GA.bestidvF = fitness(:,mostfit);
        GA.bestOVF = ovf(mostfit);
        GA.bestList = stimMatrix(:,mostfit);
    end

    GA.idvF(:,g) = GA.bestidvF; %design efficiencies
    GA.OVF(g) = GA.bestOVF; %overall efficiency
    GA.bestLists(:,g) = GA.bestList; %overall efficiency

    % Display the best fit for each generation on the screen
    str = (['Generation ' num2str(g)]);
    str = [str ' best: F* = ' num2str(GA.OVF(g))];
    str = [str ' /Fc = ' num2str(GA.idvF(1,g))];
    str = [str ' /Fd = ' num2str(GA.idvF(2,g))];
    str = [str ' /Fe = ' num2str(GA.idvF(3,g))];
    str = [str ' /ff = ' num2str(GA.idvF(4,g))];
    disp(str)


    %############ select parents for next generation #############
    [parentMatrix, povf, pfitness] = ...
        naturalSelection(stimMatrix, ovf, fitness, sizeGen);

end  % generations loop

return


