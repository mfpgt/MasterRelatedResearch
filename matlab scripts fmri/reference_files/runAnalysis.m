%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzefMRIData.m
%
% Notes:
%   * Runs an analysis of the fmri data.
%       - First creates and runs the design batch (estimation)
%       - Then, creates and runs the contrast batch
%   * To add contrasts, change the create*Contrasts() functions
%
% Outputs:
% Usage: 
%   * runAnalysis()
%
% Author: Martin Perez-Guevara
%		Adapted from Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%should pass a configuration file with all the necessary variables
%these variables would be manipulated by hand or generated by the global bash program
function runAnalysis(expFolder,subj,nS) 
%global Defaults;
%Defaults=spm_get_defaults;

global experimentFolder;
global subject;
global nSessions;
experimentFolder=expFolder;
subject=subj;
nSessions=nS;%str2num(nS);

% Create the design batch
disp('Creating batch...');
matlabbatch{1}.spm.stats = createSpecificationBatch();
matlabbatch{2}.spm.stats = createEstimationBatch();
disp('Done.');

% save the design batch
disp('Saving batch...');
mat_file = ['design_batch.mat'];
save(mat_file,'matlabbatch');
disp('Done.');

% run the design batch
disp('Running batch...');
NM_RunSPMBatch(mat_file);
disp('Done.')

clear matlabbatch;

disp('Updating batch with contrasts...');
% Set the SPM file we just made (to run the contrasts)
matlabbatch{1}.spm.stats.con.spmmat{1} = [experimentFolder '/analysis/' subject '/SPM.mat'];

% Load the contrasts
matlabbatch{1}.spm.stats.con.consess = createExperimentContrasts();  
disp('Done.')

% Save the contrasts batch
disp('Saving batch...');
matlabbatch{1}.spm.stats.con.delete = 1;
mat_file = ['contrasts_batch.mat'];
save(mat_file,'matlabbatch');
disp('Done.');

% And run the contrasts batch
disp('Running batch...');
NM_RunSPMBatch(mat_file);
disp('Done.')

function batch = createSpecificationBatch()
global experimentFolder;
global subject;
global nSessions;

batch.fmri_spec.dir{1} = [experimentFolder '/analysis/' subject '/'];
batch.fmri_spec.timing.units = 'secs';
batch.fmri_spec.timing.RT = 1.5;
batch.fmri_spec.timing.fmri_t = 16;
batch.fmri_spec.timing.fmri_t0 = 1;

num_runs = nSessions;

%AWFUL HAVE TO CHANGE SOON //// HARDCODED RP.TXT FILES FOR REGRESSORS 
regres{1}='/rp_vol0000.txt';
regres{2}='/rp_vol0000_c0000.txt';

for r = 1:num_runs
    
    %create conditions.mat file
%disp([experimentFolder '/stimuliandbehavior/' subject '/conditionFiles/'])
    formatConditions([experimentFolder '/stimuliandbehavior/' subject '/conditionFiles/'], ['session' num2str(r)], ['session_' num2str(r) '_conditions']);
    batch.fmri_spec.sess(r).multi{1} = [experimentFolder '/stimuliandbehavior/' subject '/conditionFiles/' 'session_' num2str(r) '_conditions.mat'];
    
    filter = ['^' 's' 'w' 'r'];
    batch.fmri_spec.sess(r).scans = cellstr(spm_select('ExtFPList',[experimentFolder '/preprocessing/' subject '/fMRI/session' num2str(r)],[filter], Inf));
    batch.fmri_spec.sess(r).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});

    batch.fmri_spec.sess(r).regress = struct('name', {}, 'val', {});
    
    batch.fmri_spec.sess(r).multi_reg{1} = [experimentFolder '/preprocessing/' subject '/fMRI/session' num2str(r) regres{r}]; %VERY IMPORTANT //// ASSUMING NAME OF REGRESSORS FILE BASED ON SINGLE VOL FILES AFTER FSL SLICE TIMING

    batch.fmri_spec.sess(r).hpf = 128;
end

% Extraneous options
batch.fmri_spec.volt = 1;
batch.fmri_spec.global = 'None';
batch.fmri_spec.mask = {''};
batch.fmri_spec.cvi = 'AR(1)';
% bases functions [TODO: improve this part] (apparently...)
batch.fmri_spec.fact = struct('name', {}, 'levels', {});
% Hrf 
batch.fmri_spec.bases.hrf.derivs = [1 1]; %VERY IMPORTANT //// ASSUMING TWO DERIVATIVES MODEL


% This seems to not change...
function batch = createEstimationBatch()

batch.fmri_est.spmmat(1) = cfg_dep;
batch.fmri_est.spmmat(1).tname = 'Select SPM.mat';
batch.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';

batch.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
batch.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
batch.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
batch.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
batch.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
batch.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
batch.fmri_est.method.Classical = 1;



function contrasts = createExperimentContrasts()
global experimentFolder;
global subject;
global nSessions;
% Make the contrasts
%contrasts{1} = makeContrast('Finterest', {[eye(num_conditions*2)  zeros(2*num_conditions,6)]}, 'f'); % 6 - movement params

contrastsInfo=alternativereadtable([experimentFolder '/stimuliandbehavior/' subject '/contrasts/contrastDefinitions_conNames.csv']);%readtable([experimentFolder '/stimuliandbehavior/' subject '/contrasts/contrastDefinitions_conNames.csv']);
contrastsValues=open([experimentFolder '/stimuliandbehavior/' subject '/contrasts/contrastDefinitions.mat']);
numContrasts=size(contrastsValues.con,1);
for c=1:numContrasts
    contrasts{c} = makeContrast(contrastsInfo.name{c},contrastsValues.con(c,:),'t');
end

function con = makeContrast(name, matrix, type)

con.([type 'con']).name = name;
con.([type 'con']).convec = matrix;
con.([type 'con']).sessrep = 'none';


function NM_RunSPMBatch(mat_file)

% Initialize the jobman
disp(['Running batch: ' mat_file '...']);
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% And run the preprocessing job
spm_jobman('run', mat_file);
disp('Done.');
