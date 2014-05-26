%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SUB-FUNCTION:
%   Creating the matrix for drift
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function S = Polydrift(T, deg);
%
% creating legendre polynomial
%  input:
%   T: rows of S = no. of observations
%   deg: degree of the polynomial; 0=vector of ones
%
%  output;
%   S: the matrix for drift

tmpt = (2.*([0:(T-1)]./(T-1)) - 1)';
S(:,1) = ones(T,1);
if deg > 0
    S(:,2) = tmpt;
    if deg > 1
        for k = 2:deg
            S(:,(k+1)) = ((2*k-1)/k).*tmpt.*S(:,k) - ((k-1)./k).*S(:,(k-1));
        end
    end
end
return
