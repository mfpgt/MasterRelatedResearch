%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculation ampliture Estimation efficiency
%    D-efficiency and A-efficiency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function AmpEff = AmpEfficiency(deconvM, defHRF, numSTYPE, whiteM, Ctrst, dflag)
%
% calcuation of D- or A-efficiency for amplitude estimation
% Inputs:
%   deconvM: deconvoluted Matrix
%   defHRF: assumed shape of HRF
%   numSTYPE: number of active stimulus types
%   WhitenM: whitening matrix
%   Ctrst: contrast
%   dflag: which efficiency to use: 1=D-optimality; 0=A-optimality

% Output:
%   AmpEff: estimation efficiency

lenHRF = size(defHRF,1);
for i = 1:numSTYPE
    designM(:,i) = deconvM(:,(i-1)*lenHRF+1:i*lenHRF)*defHRF; %convoluting with the HRF 
end

X = designM'*whiteM*designM; %whitening

p = size(Ctrst,1);
if (rcond(X) >= 1E-15) 
    invM = inv(X);
    if dflag %D-opt
        AmpEff = det(Ctrst*invM*Ctrst')^(-1/p);
    else     %A-opt
        AmpEff = p/trace(Ctrst*invM*Ctrst');
    end
else
    AmpEff = 0; % when X is (near-)singular
end

return
