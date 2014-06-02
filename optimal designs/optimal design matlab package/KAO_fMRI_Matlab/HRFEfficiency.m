%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Calculation HRF Estimation efficiency
%    D-efficiency and A-efficiency
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function HRFEff = HRFEfficiency(deconvM, whiteM, Ctrst, dflag)
%
% calcuation of D- or A-efficiency for HRF estimation
% Inputs:
%   deconvM: deconvoluted matrix
%   WhitenM: whitening matrix
%   Ctrst: contrast
%   dflag: which efficiency to use = 1 --> D-opt; o.w. A-opt

% Output:
%   HRFEff: estimation efficiency

X = deconvM'*whiteM*deconvM;

p = size(Ctrst,1);
if (rcond(X) >= 1E-15)
    invM = inv(X);
    if dflag %D-opt
        HRFEff = det(Ctrst*invM*Ctrst')^(-1/p);
    else %A-opt
        HRFEff = p/trace(Ctrst*invM*Ctrst');
    end
else
    HRFEff = 0;
end

return