%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_PreprocessfMRIData.m
%
% Notes:
%   * Preprocesses the fmri data.
%       - Needs to be run for both the localizer and experiment.
%   * Creates the design files first
%   * Then, creates the spm batch structure (adapted from Pallier scripts)
%   * Saves and script in the subject fmri_data folder
%   * Uses spm_jobman to run the batch then
%   * For now, no slice timing is used because of the acquisition protocol
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_PreprocessfMRIData()
%
% Author: Douglas K. Bemis
%   - Adapted from Christophe Pallier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_PreprocessfMRIData()

global GLA_rec_type;
if ~strcmp(GLA_rec_type,'fmri')
    return;
end
global GLA_fmri_type;
if isempty(GLA_fmri_type)
    error('GLA_fmri_type not set.');
end

% Check the processing 
disp('Loading data...');
NM_LoadSubjectData({...
    {'fmri_data_imported',1},...
    {'log_checked',1}...
    });
disp('Done.');

% Create the design files
NM_CreateDesignFiles();

% Set the stages to do
global GLA_subject_data;
if GLA_subject_data.settings.fmri_do_slicetiming
    slicetiming_stage = 1; 
else
    slicetiming_stage = 0;
end
realign_stage = slicetiming_stage+1;
coregister_stage = realign_stage+1;
segmentation_stage = coregister_stage+1;
anat_normalization_stage = segmentation_stage+1;
normalization_stage = anat_normalization_stage+1;
smoothing_stage = normalization_stage+1;

disp('Creating the batch...');
if slicetiming_stage > 0
    matlabbatch{slicetiming_stage}.spm = createSliceTimingBatch();  %#ok<*NASGU>
end
matlabbatch{realign_stage}.spm = createRealignmentBatch(slicetiming_stage);
matlabbatch{coregister_stage}.spm = createCoregistrationBatch(realign_stage);
matlabbatch{segmentation_stage}.spm = createSegmentationBatch();
matlabbatch{anat_normalization_stage}.spm = createAnatNormalizationBatch(segmentation_stage);
matlabbatch{normalization_stage}.spm = createNormalizationBatch(segmentation_stage, realign_stage);
matlabbatch{smoothing_stage}.spm = createSmoothingBatch(normalization_stage);

% Then save the batch
global GLA_subject;
mat_file = [NM_GetRootDirectory() '/fmri_data/' GLA_subject ...
    '/' GLA_fmri_type '/' GLA_subject '_preprocess_batch.mat'];
save(mat_file,'matlabbatch');
disp('Done.');

% Now load and run it
NM_RunSPMBatch(mat_file);

% And record that we've done it
NM_SaveSubjectData({{['fmri_' GLA_fmri_type '_data_preprocessed'],1}});


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Slice timing 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch = createSliceTimingBatch()

% Set the scans
global GLA_subject_data;
batch.temporal.st.scans = getScanFiles();
batch.temporal.st.nslices = GLA_subject_data.settings.fmri_num_slices;
batch.temporal.st.tr = GLA_subject_data.settings.fmri_tr;
batch.temporal.st.ta = GLA_subject_data.settings.fmri_ta;
batch.temporal.st.so = GLA_subject_data.settings.fmri_slice_order;
batch.temporal.st.refslice = GLA_subject_data.settings.fmri_ref_slice;
batch.temporal.st.prefix = 'a';


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Realignment 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


function batch = createRealignmentBatch(slicetiming_stage)

% If we're first, then use all the scan files
if slicetiming_stage == 0
    batch.spatial.realign.estimate.data = getScanFiles();

else

    % Set the per run parameters
    for r = 1:getNumRuns()
        batch.spatial.realign.estimate.data{r}(1) = cfg_dep;
        batch.spatial.realign.estimate.data{r}(1).tname = 'Session';
        batch.spatial.realign.estimate.data{r}(1).tgt_spec{1}(1).name = 'filter';
        batch.spatial.realign.estimate.data{r}(1).tgt_spec{1}(1).value = 'image';
        batch.spatial.realign.estimate.data{r}(1).tgt_spec{1}(2).name = 'strtype';
        batch.spatial.realign.estimate.data{r}(1).tgt_spec{1}(2).value = 'e';
        batch.spatial.realign.estimate.data{r}(1).sname = sprintf('Slice Timing: Slice Timing Corr. Images (Sess %d)', r);
        batch.spatial.realign.estimate.data{r}(1).src_exbranch = ...
            substruct('.','val', '{}',{slicetiming_stage}, '.','val', '{}',{1}, '.','val', '{}',{1});
        batch.spatial.realign.estimate.data{r}(1).src_output = ...
            substruct('()',{r}, '.','files');
    end
end

% Set the parameters
batch.spatial.realign.estimate.eoptions.quality = 0.9;
batch.spatial.realign.estimate.eoptions.sep = 4;
batch.spatial.realign.estimate.eoptions.fwhm = 5;
batch.spatial.realign.estimate.eoptions.rtm = 1;    
batch.spatial.realign.estimate.eoptions.interp = 2;
batch.spatial.realign.estimate.eoptions.wrap = [0 0 0];
batch.spatial.realign.estimate.eoptions.weight = '';




%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Coregistration 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch = createCoregistrationBatch(realign_stage)

% Coregistration anat -> mean EPI (Note AM: anat --> EPI et pas l'inverse !!)
batch.spatial.coreg.estimate.ref(1) = cfg_dep;
batch.spatial.coreg.estimate.ref(1).tname = 'Reference Image';
batch.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).name = 'filter';
batch.spatial.coreg.estimate.ref(1).tgt_spec{1}(1).value = 'image';
batch.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).name = 'strtype';
batch.spatial.coreg.estimate.ref(1).tgt_spec{1}(2).value = 'e';
batch.spatial.coreg.estimate.ref(1).sname = 'Realign: Estimate: Realigned Images (Sess 1)';
batch.spatial.coreg.estimate.ref(1).src_exbranch = ...
    substruct('.','val', '{}',{realign_stage}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
batch.spatial.coreg.estimate.ref(1).src_output = substruct('.','sess', '()',{1}, '.','cfiles');
batch.spatial.coreg.estimate.source = {getAnatFilename()};
batch.spatial.coreg.estimate.other = {''};
batch.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
batch.spatial.coreg.estimate.eoptions.sep = [4 2];
batch.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
batch.spatial.coreg.estimate.eoptions.fwhm = [7 7];


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Segmentation 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch = createSegmentationBatch()

batch.spatial.preproc.data = { getAnatFilename() };
batch.spatial.preproc.output.GM = [1 0 1];
batch.spatial.preproc.output.WM = [1 0 1];
batch.spatial.preproc.output.CSF = [0 0 0];
batch.spatial.preproc.output.biascor = 1;
batch.spatial.preproc.output.cleanup = 0;
greytpm = spm_select('CPath','tpm/grey.nii', getSPMPath());
whitetpm =  spm_select('CPath','tpm/white.nii',getSPMPath());
csftpm =  spm_select('CPath','tpm/csf.nii',getSPMPath());
batch.spatial.preproc.opts.tpm = { greytpm, whitetpm, csftpm } ;
batch.spatial.preproc.opts.ngaus = [2
    2
    2 
    4];
batch.spatial.preproc.opts.regtype = 'mni';
batch.spatial.preproc.opts.warpreg = 1;
batch.spatial.preproc.opts.warpco = 25;
batch.spatial.preproc.opts.biasreg = 0.0001;
batch.spatial.preproc.opts.biasfwhm = 60;
batch.spatial.preproc.opts.samp = 3;
batch.spatial.preproc.opts.msk = {''};


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Anatomic normalization 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch = createAnatNormalizationBatch(segmentation_stage)


batch.spatial.normalise.write.subj.matname(1) = cfg_dep;
batch.spatial.normalise.write.subj.matname(1).tname = 'Parameter File';
batch.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).name = 'filter';
batch.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).value = 'mat';
batch.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).name = 'strtype';
batch.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).value = 'e';
batch.spatial.normalise.write.subj.matname(1).sname = 'Segment: Norm Params Subj->MNI';
batch.spatial.normalise.write.subj.matname(1).src_exbranch = ...
    substruct('.','val', '{}',{segmentation_stage}, '.','val', '{}',{1}, '.','val', '{}',{1});
batch.spatial.normalise.write.subj.matname(1).src_output = substruct('()',{1}, '.','snfile', '()',{':'});

batch.spatial.normalise.write.subj.resample(1) = cfg_dep;
batch.spatial.normalise.write.subj.resample(1).tname = 'Images to Write';
batch.spatial.normalise.write.subj.resample(1).tgt_spec{1}(1).name = 'filter';
batch.spatial.normalise.write.subj.resample(1).tgt_spec{1}(1).value = 'image';
batch.spatial.normalise.write.subj.resample(1).tgt_spec{1}(2).name = 'strtype';
batch.spatial.normalise.write.subj.resample(1).tgt_spec{1}(2).value = 'e';
batch.spatial.normalise.write.subj.resample(1).sname = 'Segment: Bias Corr Images';
batch.spatial.normalise.write.subj.resample(1).src_exbranch = ...
    substruct('.','val', '{}',{segmentation_stage}, '.','val', '{}',{1}, '.','val', '{}',{1});

batch.spatial.normalise.write.subj.resample(1).src_output = substruct('()',{1}, '.','biascorr', '()',{':'});
batch.spatial.normalise.write.roptions.preserve = 0;
batch.spatial.normalise.write.roptions.bb = [-78 -112 -50
                                                          78 76 85];
batch.spatial.normalise.write.roptions.vox = [1 1 1];
batch.spatial.normalise.write.roptions.interp = 1;
batch.spatial.normalise.write.roptions.wrap = [0 0 0];
batch.spatial.normalise.write.roptions.prefix = 'w';



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Normalization 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch = createNormalizationBatch(segmentation_stage, realign_stage)

% Spatial normalisation of EPIs
batch.spatial.normalise.write.subj(1).matname(1) = cfg_dep;
batch.spatial.normalise.write.subj(1).matname(1).tname = 'Parameter File';
batch.spatial.normalise.write.subj(1).matname(1).tgt_spec{1}(1).name = 'filter';
batch.spatial.normalise.write.subj(1).matname(1).tgt_spec{1}(1).value = 'mat';
batch.spatial.normalise.write.subj(1).matname(1).tgt_spec{1}(2).name = 'strtype';
batch.spatial.normalise.write.subj(1).matname(1).tgt_spec{1}(2).value = 'e';
batch.spatial.normalise.write.subj(1).matname(1).sname = 'Segment: Norm Params Subj->MNI';
batch.spatial.normalise.write.subj(1).matname(1).src_exbranch = ...
    substruct('.','val', '{}',{segmentation_stage}, '.','val', '{}',{1}, '.','val', '{}',{1});
batch.spatial.normalise.write.subj(1).matname(1).src_output = substruct('()',{1}, '.','snfile', '()',{':'});
for r = 1:getNumRuns()
    batch.spatial.normalise.write.subj(1).resample(r) = cfg_dep;
    batch.spatial.normalise.write.subj(1).resample(r).tname = 'Images to Write';
    batch.spatial.normalise.write.subj(1).resample(r).tgt_spec{1}(1).name = 'filter';
    batch.spatial.normalise.write.subj(1).resample(r).tgt_spec{1}(1).value = 'image';
    batch.spatial.normalise.write.subj(1).resample(r).tgt_spec{1}(2).name = 'strtype';
    batch.spatial.normalise.write.subj(1).resample(r).tgt_spec{1}(2).value = 'e';
    batch.spatial.normalise.write.subj(1).resample(r).sname = ...
        sprintf('Realign: Estimate & Reslice: Realigned Images (Sess %d)',r);
    batch.spatial.normalise.write.subj(1).resample(r).src_exbranch = ...
        substruct('.','val', '{}',{realign_stage}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    batch.spatial.normalise.write.subj(1).resample(r).src_output = substruct('.','sess', '()',{r}, '.','cfiles');
end

global GLA_subject_data;
batch.spatial.normalise.write.roptions.preserve = 0;
batch.spatial.normalise.write.roptions.bb = [-78 -112 -50
                                                          78 76 85];
batch.spatial.normalise.write.roptions.vox = GLA_subject_data.settings.fmri_voxel_size; 
batch.spatial.normalise.write.roptions.interp = 1;
batch.spatial.normalise.write.roptions.wrap = [0 0 0];
batch.spatial.normalise.write.roptions.prefix = 'w';



%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Smoothing 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch = createSmoothingBatch(normalization_stage)

smoothing_kernel = [4 4 4];

% TODO: This needs to be fixed.
for r = 1:getNumRuns()
% for r = 1
    batch.spatial.smooth.data(r) = cfg_dep;
    batch.spatial.smooth.data(r).tname = 'Images to Smooth';
    batch.spatial.smooth.data(r).tgt_spec{1}(1).name = 'filter';
    batch.spatial.smooth.data(r).tgt_spec{1}(1).value = 'image';
    batch.spatial.smooth.data(r).tgt_spec{1}(2).name = 'strtype';
    batch.spatial.smooth.data(r).tgt_spec{1}(2).value = 'e';
    batch.spatial.smooth.data(r).sname = sprintf('Normalise: Write: Normalised Images (Subj %d)',r);
    batch.spatial.smooth.data(r).src_exbranch = ...
        substruct('.','val', '{}',{normalization_stage}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
    batch.spatial.smooth.data(r).src_output = substruct('()',{1}, '.','files');
end
batch.spatial.smooth.fwhm = smoothing_kernel;
batch.spatial.smooth.dtype = 0;
batch.spatial.smooth.im = 0;
batch.spatial.smooth.prefix = 's';



function path_name = getSPMPath()

path_name = which('spm');
if ~strcmp(path_name(end-5:end),'/spm.m')
    error('Bad path.');
end
path_name = path_name(1:end-6);


function filename = getAnatFilename()

global GLA_subject;
global GLA_fmri_type;
filename = [NM_GetRootDirectory() '/fmri_data/' GLA_subject ...
    '/' GLA_fmri_type '/' GLA_subject '_anat.nii'];

function files = getScanFiles()

global GLA_subject;
global GLA_subject_data;
global GLA_fmri_type;
files = {};
switch GLA_fmri_type
    case 'localizer'
        files{1} = NM_GetScanFiles(['^' GLA_subject '_loc']);
        
    case 'experiment'
        for r = 1:GLA_subject_data.settings.num_runs
            files{r} = NM_GetScanFiles(['^' GLA_subject '_run_' num2str(r)]); %#ok<AGROW>
        end

    otherwise
        error('Unknown fmri type');
end


function num_runs = getNumRuns()
global GLA_fmri_type;
global GLA_subject_data;
switch GLA_fmri_type
    case 'localizer'
        num_runs = 1;

    case 'experiment'
        num_runs = length(GLA_subject_data.data.runs);    

    otherwise
        error('Unknown type');

end

