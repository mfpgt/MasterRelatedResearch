%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Example code:
%   Searching for multi-objective optimal designs for ER-fMRI
%
% References:
%  (1) Wager and Nichols (2003): NeuroImage
%  (2) Liu and Frank (2004): NeuroImage
%  (3) Liu (2004): NeuroImage
%  (4) Kao et al (2008): NeuroImage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;

%***** Assign values to the paramters Inp.xxxxx

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%****  Name of output file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
date = clock;
date = [num2str(date(2))  num2str(date(3))  num2str(date(1)) '-' num2str(date(4))  num2str(date(5)) ];

Inp.filename = (['MO_design_' date '.mat']); % <-- filename for output

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**** Experimental conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Inp.nSTYPE = 2; % <--  number of stimulus types (excluding the control)
Inp.ISI = 2.0; % <--time interval between event onsets
Inp.TR = 2.0; % <--time interval between scans
Inp.dT = 2.0; % <--the greatest value dividing both the ISI and TR
Inp.nEvents = 242; % <--number of events in the design
% the experimental duration will be nEvents*ISI

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**** Model Assumptions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. nuisance terms
PolyOrder = 2; % degree of the polynomial drift;
numScan = floor(Inp.nEvents*Inp.ISI/Inp.TR); % number of scans / length of data

Inp.Smat = Polydrift(numScan, PolyOrder); % <-- nuisance term

% 2. whitening matrix
rho = 0.3; % correlation coefficient of AR(1) process
base = [1+rho^2, -1*rho, zeros(1, numScan-2)]; 
V = toeplitz(base);
V(1,1) = 1;
V(end,end) = 1;

Inp.V2 = V; % <-- square of whitening matrix

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**** criteria of interest
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 1. Optimality criterion
Inp.Opt = 0; % <-- 0=A-optimality; 1=D-optimality

% 2. weights for MO-criterion
Inp.MOweight = [0 0 1 0]; % <-- w_i in the order of [w_c, w_d, w_e, w_f];
% % % note. w_c and w_f should be zero if there is only one stimulus type; i.e.
% % %   Inp.nSTYPE = 1

% 3. basis for the HRF

% Assumed HRF (canonical HRF from SPM2)
% Parameters:                                             default
%	p(1) - delay of response (relative to onset)	    6
%	p(2) - delay of undershoot (relative to onset)      16
%	p(3) - dispersion of response			    1
%	p(4) - dispersion of undershoot			    1
%	p(5) - ratio of response to undershoot		    6
%	p(6) - onset (seconds)				    0
%	p(7) - length of kernel (seconds)		    32

p = [6 16 1 1 6 0 32]; % default parameter values for HRF 
defHRF = spm_hrf(0.1, p);	% SPM HRF sampled at .1 s
defHRF = defHRF / max(defHRF);  % scale to have a max of 1

Inp.basisHRF = defHRF(1:Inp.dT*10:end); % <-- assinging the basis for the HRF

% 4. linear combinations of parameters
Inp.durHRF = 32.0; % <-- duration of the HRF

lagHRF = Inp.nSTYPE*(1+floor(Inp.durHRF/Inp.dT)); % length of the HRF paramters

Inp.CX = eye(lagHRF); % <-- linear combinations for h
Inp.CZ = eye(Inp.nSTYPE); % <-- linear combinations for theta

% 5. max(Fe) and Max(Fd)

Inp.MaxFe = 39.2715; %<-- numerical approximation of Max(Fe)
Inp.MaxFd = 132.0670; %<-- numerical approximation of Max(Fe)
% % % to get numerical approximation for Max(Fe):
% % %   set Inp.MaxFe = 1; and Inp.MOweight = [0 0 1 0];
% % %   after the search the approximate is in Out.bestOVF
% % % to get numerical approximation for Max(Fd):
% % %   set Inp.MaxFd = 1; and Inp.MOweight = [0 1 0 0];
% % %   after the search the approximate is in Out.bestOVF

% 6. psychological confounds
Inp.cbalR = 3; % <-- order of counterbalancing

% 7. desired stimulus frequency
Inp.stimFREQ = ones(1,Inp.nSTYPE)./Inp.nSTYPE; %<-- desired stimulus frequency
% % % use equal frequency if no preference

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**** Algorithmic parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Inp.numITR = 100; %<-- total number of generations
Inp.sizeGen = 20; %<-- size of each generation
Inp.qMutate = 0.01; %<-- rate of mutation
Inp.nImmigrant = 4; %<-- number of immigrant

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**** Performing the search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Out = fMRIMOD(Inp); %% calling the main subroutine
save(Inp.filename, 'Inp', 'Out'); %% save the outcome; 
