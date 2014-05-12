%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzefMRIData.m
%
% Notes:
%   * Runs an analysis of the fmri data.
%       - First creates and runs the design batch (estimation)
%       - Then, creates and runs the contrast batch
%   * To add contrasts, change the create*Contrasts() functions
%   * Could use more options (through the cfg input) 
%       - e.g. different response functions, design files, etc.
%
% Inputs:
%   * cfg (optional): The configurations for the analysis. Fields:
%       - smooth: Set to 0 to not smooth.
%           - Default is to smooth and is saved in the 'normal' analysis folder.
%
% Outputs:
% Usage: 
%   * cfg = [];
%   * NM_AnalyzefMRIData(cfg)
%
% Author: Douglas K. Bemis
%   - Adpated from Christophe Pallier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AnalyzefMRIData(cfg)

% Might not be doing this
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'fmri')
    return;
end

% Default
if ~exist('cfg','var')
    cfg = [];
end

global GLA_fmri_type;
global GLA_subject;
disp(['Analyzing ' GLA_fmri_type ' fMRI data for ' GLA_subject '...']);
NM_LoadSubjectData({{['fmri_' GLA_fmri_type '_data_preprocessed'],1}});

% Setup
setOptions(cfg);

% Run the design batch 
runDesignBatch(cfg);

% Create the contasts
runContrastsBatch();

% And signal
disp(['Analyzing ' GLA_fmri_type ' fMRI data for ' GLA_subject '... Done.']);


function runContrastsBatch()


% Set the SPM file we just made
global GLA_fmri_type;
global GLA_subject;
global GL_analysis_dir;
matlabbatch{1}.spm.stats.con.spmmat{1} = [GL_analysis_dir '/SPM.mat'];

% Set the contrasts
switch GLA_fmri_type
    case 'localizer'
        matlabbatch{1}.spm.stats.con.consess = createLocalizerContrasts();  
        
    case 'experiment'
        matlabbatch{1}.spm.stats.con.consess = createExperimentContrasts();  
        
    otherwise
        error('Unknown type.');
end

% Save
matlabbatch{1}.spm.stats.con.delete = 1;
mat_file = [GL_analysis_dir '/' GLA_subject '_' GLA_fmri_type '_contrasts_batch.mat'];
save(mat_file,'matlabbatch');
disp('Done.');

% And run it.
NM_RunSPMBatch(mat_file);


function contrasts = createExperimentContrasts()


% Go with the derivative for now
global GLA_subject_data;

% Set up the condition matrix
num_conditions = 10;
conditions =  zeros(num_conditions,2*num_conditions);
conditions(:,1:2:2*num_conditions) = eye(num_conditions);

% Add the movement regressors
conditions = repmat([conditions zeros(num_conditions, 6)], ...
    GLA_subject_data.settings.num_runs);

% Set the conditions
for c = 1:num_conditions
    if c > 5
        reg.(['list_' num2str(c-5)]) =  conditions(c,:);
    else
        reg.(['phrase_' num2str(c)]) =  conditions(c,:);        
    end
end


% Make the contrasts
contrasts{1} = makeContrast('Finterest', {[eye(num_conditions*2)  zeros(2*num_conditions,6)]}, 'f'); % 6 - movement params
contrasts{2} = makeContrast('structure', (reg.phrase_2+reg.phrase_3+reg.phrase_4)-(reg.list_2+reg.list_3+reg.list_4), 't');
contrasts{3} = makeContrast('linear_phrase', -3*reg.phrase_1-reg.phrase_2+reg.phrase_3+3*reg.phrase_4, 't');
contrasts{4} = makeContrast('linear_list', -3*reg.list_1-reg.list_2+reg.list_3+3*reg.list_4, 't');
contrasts{5} = makeContrast('interaction_phrase', (-3*reg.phrase_1-reg.phrase_2+reg.phrase_3+3*reg.phrase_4)-...
    (-3*reg.list_1-reg.list_2+reg.list_3+3*reg.list_4), 't');
contrasts{6} = makeContrast('interaction_list', (-3*reg.list_1-reg.list_2+reg.list_3+3*reg.list_4)-...
    (-3*reg.phrase_1-reg.phrase_2+reg.phrase_3+3*reg.phrase_4), 't');
contrasts{7} = makeContrast('big_phrase', reg.phrase_4, 't');
contrasts{8} = makeContrast('all_phrases', reg.phrase_1+reg.phrase_2+reg.phrase_3+reg.phrase_4, 't');
contrasts{8} = makeContrast('all_lists', reg.list_1+reg.list_2+reg.list_3+reg.list_4, 't');
contrasts{8} = makeContrast('all', reg.phrase_1+reg.phrase_2+reg.phrase_3+reg.phrase_4+reg.phrase_5+...
    reg.list_1+reg.list_2+reg.list_3+reg.list_4+reg.list_5, 't');



function contrasts = createLocalizerContrasts()

% Check for no responses
global GLA_subject_data;
if GLA_subject_data.settings.num_localizer_catch_trials == 0
    nconditions = 2;
else
    nconditions = 3;
end

% Go with the derivative for now
conditions =  zeros(nconditions,2*nconditions);
conditions(:,1:2:2*nconditions) = eye(nconditions);
sentence = conditions(1,:);
pseudo = conditions(2,:);

if GLA_subject_data.settings.num_localizer_catch_trials > 0
    response = conditions(3,:);
end


% Make the contrasts
contrasts{1} = makeContrast('Finterest', {[eye(nconditions*2)  zeros(2*nconditions,6)]}, 'f'); % 6 - movement params
contrasts{2} = makeContrast('sentence-pseudo', sentence-pseudo, 't');
contrasts{3} = makeContrast('sentence+pseudo>0', sentence+pseudo, 't');



function con = makeContrast(name, matrix, type)


con.([type 'con']).name = name;
con.([type 'con']).convec = matrix;
con.([type 'con']).sessrep = 'none';


function runDesignBatch(cfg)
    
% Create the batch
disp('Creating batch...');
matlabbatch{1}.spm.stats = createSpecificationBatch(cfg);  %#ok<*NASGU>
matlabbatch{2}.spm.stats = createEstimationBatch();
disp('Done.');

% And save it
global GL_analysis_dir;
global GLA_subject;
global GLA_fmri_type;
mat_file = [GL_analysis_dir '/' GLA_subject '_' GLA_fmri_type '_design_batch.mat'];
save(mat_file,'matlabbatch');
disp('Done.');

% And run it.
NM_RunSPMBatch(mat_file);



function batch = createSpecificationBatch(cfg)

global GLA_fmri_type;
global GL_analysis_dir;
global GLA_subject_data;
batch.fmri_spec.dir{1} = GL_analysis_dir;
batch.fmri_spec.timing.units = 'secs';
batch.fmri_spec.timing.RT = GLA_subject_data.settings.fmri_tr;

% Not sure...
batch.fmri_spec.timing.fmri_t = 16;
batch.fmri_spec.timing.fmri_t0 = 1;

% Only one localizer run...
if strcmp(GLA_fmri_type,'localizer')
    num_runs = 1;
else
    num_runs = GLA_subject_data.settings.num_runs;
end
global GLA_subject;
for r = 1:num_runs
    
    % Adjust for localizer name
    if strcmp(GLA_fmri_type,'localizer')
        filter = ['w' GLA_subject '_loc'];
        batch.fmri_spec.sess(r).multi{1} = [NM_GetRootDirectory() '/fmri_data/'...
            GLA_subject '/localizer/' GLA_subject '_localizer_design.mat'];
    else
        filter = ['w' GLA_subject '_run_' num2str(r)];
        batch.fmri_spec.sess(r).multi{1} = [NM_GetRootDirectory() '/fmri_data/'...
            GLA_subject '/experiment/' GLA_subject '_run_' num2str(r) '_design.mat'];
    end
    
    % Allow smoothed and unsmoothed version
    if ~isfield(cfg,'smooth') || cfg.smooth
        filter = ['s' filter]; %#ok<AGROW>
    end

    % Don't want subsets
    filter = ['^' filter]; %#ok<AGROW>
    
    batch.fmri_spec.sess(r).scans = NM_GetScanFiles(filter);
    batch.fmri_spec.sess(r).cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {});

    batch.fmri_spec.sess(r).regress = struct('name', {}, 'val', {});
    batch.fmri_spec.sess(r).multi_reg{1} = NM_GetMovementRegressorFileName(r);

    batch.fmri_spec.sess(r).hpf = 128;
end

% Extraneous options
batch.fmri_spec.volt = 1;
batch.fmri_spec.global = 'None';
batch.fmri_spec.mask = {''};
batch.fmri_spec.cvi = 'AR(1)';

% bases functions [TODO: improve this part] (apparently...)
batch.fmri_spec.fact = struct('name', {}, 'levels', {});

% Hrf simple
batch.fmri_spec.bases.hrf.derivs = [1 0];
% FIR:
%    matlabbatch{1}.spm.stats.fmri_spec.bases.fir.length = 14.4;
%    matlabbatch{1}.spm.stats.fmri_spec.bases.fir.order = 12;



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

function setOptions(cfg)

global GLA_subject;
global GLA_fmri_type;
global GL_analysis_dir;

% Set the directory by type
if isfield(cfg,'smooth') && cfg.smooth == 0
    GL_analysis_dir = [NM_GetRootDirectory() '/analysis/' ...
        GLA_subject '/' GLA_fmri_type '/unsmoothed'];    
else
    GL_analysis_dir = [NM_GetRootDirectory() '/analysis/' ...
        GLA_subject '/' GLA_fmri_type '/normal'];
end
[success message message_id] = mkdir(GL_analysis_dir); %#ok<ASGLU>

