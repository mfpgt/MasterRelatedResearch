%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Operator of genetic algorithm
%   Crossover
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stimMatrix = Crossover(parentMatrix, PSCHEME, varargin)

% Randomly pair the parents to crossover
%  input:
%   parentMatrix: matrix of parent stimulus sequences
%   PSCHEME: parent selection method:
%              1 = random selection
%              2 = proportional to fitness
%   povf (optional): overall fitness for parents
%
%
%  output;
%   stimMatrix: stimulus sequences of a generation
%                (including parents and children)
%disp(parentMatrix);
%disp(PSCHEME);
if nargin > 2
    %disp('hola');
    povf = varargin{1};
else
    PSCHEME = 1; %use random pair if no fitness score available
end

dimparent = size(parentMatrix);

%disp(PSCHEME);
switch PSCHEME
    case{1} %random pair
        pairMatrix = parentMatrix(:,randperm(dimparent(2)));
    case{2} %as per fitness score
        for z = 1:2:dimparent(2)-1
            pidx = [1, 1];
            while (pidx(1) == pidx(2));
                %disp('hola');
                if sum(povf) ~= 0
                    pidx = randsample(1:dimparent(2),2,true,povf); %pick two parents as per fitness
                else
                    pidx = randsample(1:dimparent(2),2,true,povf+0.5); %pick two parents as per fitness
                end
            end
            pairMatrix(:,z) = parentMatrix(:,pidx(1));
            pairMatrix(:,z+1) = parentMatrix(:,pidx(2));
        end
    otherwise
        disp(['WARNING: Pairing scheme ' num2str(PSCHEM) ' shoule be 1 or 2'])
end
% --------- crossover ---------
stimMatrix = [pairMatrix parentMatrix];
for z = 1:2:dimparent(2)-1
    crossPoint = floor(rand*dimparent(1)); %randomly pick a crossover point
    if crossPoint == 0,crossPoint = 1;,end;
    stimMatrix(1:crossPoint, z) = pairMatrix(1:crossPoint, z+1);
    stimMatrix(1:crossPoint, z+1) = pairMatrix(1:crossPoint,z);
end
return
