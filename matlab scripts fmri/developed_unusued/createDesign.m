function createDesign(expFolder)

global experimentFolder;
experimentFolder=expFolder;

% Create the design batch
disp('Creating batch...');
matlabbatch{1}.spm.stats = createSpecificationBatch();
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
    %IMPORTANT SHOULD PASS FILE NAME TO THE FUNCTION //// HARDCODED NOW
    %create conditions.mat file
    refDir=cd;
    createMatlabConditionsFile([refDir '/'], 'Maruyama_design_1_session_1', ['Maruyama_design_1_session_1' '_conditions']);
    batch.fmri_spec.sess(r).multi{1} = ['Maruyama_design_1_session_1' '_conditions.mat'];
    
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

end


function NM_RunSPMBatch(mat_file)

% Initialize the jobman
disp(['Running batch: ' mat_file '...']);
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% And run the preprocessing job
spm_jobman('run', mat_file);
disp('Done.');

end

end

