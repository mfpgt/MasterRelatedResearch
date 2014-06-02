function [P,p,Em,En,EN] = spm_P(c,k,Z,df,STAT,R,n,S)
% Returns the [un]corrected P value using unifed EC theory
% FORMAT [P p Em En EN] = spm_P(c,k,Z,df,STAT,R,n,S)
%
% c     - cluster number 
% k     - extent {RESELS}
% Z     - height {minimum over n values}
% df    - [df{interest} df{error}]
% STAT  - Statisical feild
%		'Z' - Gaussian feild
%		'T' - T - feild
%		'X' - Chi squared feild
%		'F' - F - feild
%		'P' - Posterior probability
% R     - RESEL Count {defining search volume}
% n     - number of component SPMs in conjunction
% S     - Voxel count
%
% P     - corrected   P value  - P(n > kmax}
% p     - uncorrected P value  - P(n > k}
% Em    - expected total number of maxima {m}
% En    - expected total number of resels per cluster {n}
% EN    - expected total number of voxels {N}
%
%___________________________________________________________________________
%
% spm_P determines corrected and uncorrected p values, using the minimum
% of different valid methods. 
%
% See the individual methods for details
%
%     spm_P_RF
%     spm_P_Bonf
%
%___________________________________________________________________________
% @(#)spm_P.m	2.3 Thomas Nichols 02/03/08

% set global var NOBONF to 1 to turn off Bonferroni
%---------------------------------------------------------------------------
global NOBONF; if ~isempty(NOBONF) & NOBONF, S = []; end

if (nargin < 8), S = []; end

[P,p,Em,En,EN] = spm_P_RF(c,k,Z,df,STAT,R,n);

% Use lower Bonferroni P value (if possible)
%===========================================================================
if ~isempty(S) & (c == 1 & k == 0) & ~(length(R) == 1 & R == 1)
    P = min(P,spm_P_Bonf(Z,df,STAT,S,n));
end
