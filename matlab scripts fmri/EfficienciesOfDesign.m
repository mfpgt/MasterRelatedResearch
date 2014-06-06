%A AND D EFFICIENCIES OF A MODEL AGAINST RANDOM DESIGNS 
% to see a test of A vs D optimality, try:
% Vi = eye(mspec.numframes);
% for i = 1:1000, 
%    [X,paramvec] = construct_model(mspec,conditions,[]); 
%    a(i) = calcefficiency(ones(1,size(X,2) - 1),[],pinv(X),Vi,0);
%    d(i) = 1 ./ (inv(det(X'*X)) .^ (1./size(X,2)));
% end
% d = d - mean(d);
% figure; plot(a,d,'x'); xlabel('A-efficiency'),ylabel('D-efficiency')
% a1 = calcefficiency(ones(1,size(X,2) - 1),[],pinv(X),Vi,0);
% d1 = 1 ./ (inv(det(X'*X)) .^ (1./size(X,2)));
% hold on;plot(a1,d1,'rs','MarkerFaceColor','r')


%CALCULATE A OR D OPTIMALITY EFFICIENCY FOR A GIVEN MODEL WITH CONTRASTS
% -------------------------------------------------------------------------------------------------
        % Model parameters
        

        % * efficiency
		% -------------------------------------------------------------------------------------------------
	
			model = designvector2model(stimList,ISI,HRF,TR,numsamps,nonlinthreshold,S);
            
            % add Block effect for mixed block/ER
            % Kludgy insertion. tor: 5/6/08
            
            xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
            effDetection = calcEfficiency(contrastweights,contrasts,xtxitx,svi,dflag);
	
        % -------------------------------------------------------------------------------------------------
		% * HRF shape estimation efficiency
		% -------------------------------------------------------------------------------------------------
	
    	    delta = [];
            for i = 1:max(stimList(:,1))
                delta(:,i) = (stimList == i);
            end
            
            % how much HRF estimation we do (up to 30 s) matters
            % we want at least as long as the expected actual response
			[model] = tor_make_deconv_mtx2(delta,round(30 / TR),TR / ISI);  % hard-coded for 30 s of HRF estimation
                        
            if ~isempty(S), model = S * model; end
            
        	xtxitx = pinv(model);   % a-optimality   % inv(X'S'SX)*(SX)'; pseudoinv of (S*X)
            effEstimation = calcEfficiency([],[],xtxitx,svi,dflag);
       
   	clear model,clear maxNumStim,clear maxDev,clear maxFreqDev,clear cBal,clear dummy,clear stimList,clear go,clear xtxitx
   