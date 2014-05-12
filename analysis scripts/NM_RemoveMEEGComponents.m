%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_RemoveMEEGComponents.m
%
% Notes:
%   * Allows the removal of artifacts through pca / ica decomposition.
%   * First, decomposes using ft_componentanalysis and the 
%       GLA_subject_data.settings.meeg_decomp_* variables:
%       - decomp_type: How the meg data should be decomposed, either
%           'combined' or 'separate'
%           - The separate method decomposes three types, one for each
%               sensory type.
%           - The combined methods first normalizes the activity of all
%               three sensor types separately, decomposes, removes the
%               components, reconstructs, and then unnormalizes
%           * NOTE: There seems to be no differene between these, and so
%               you should probably use the combined method for simplicity.
%           - This does not apply to EEG data, as there is only one sensor type.
%       - decomp_method: The method given to ft_componentanalysis (pca, fastica, etc.)
%       - decomp_comp_num: The number of components to decompose into
%       - decomp_baseline_correct: 1 to baseline correct before decomposition.
%   * Then, provides an interface, using ft_databrowser, to view the components
%       - If possible, information about blinks is displayed, if the eye
%           tracking data has been processed.
%           - Shows the correlation of each component with the blinks
%           - Shows when in the trials there are blinks.
%   * The user can then select which components to reject.
%       - These will then be saved in GLA_meeg_data.settings
%   * These components are then removed from the data, which is
%       reconstructed without them using ft_rejectcomponent
%   * If the m/eeg blink data has been processed, the user can also select
%       to use the same decomposition as for the blinks on the current data.
%
% Inputs:
%   * should_save (optional): 0 not to save altered GLA_meeg_data
%       - Defaults to save data with component(s) removed
%
% Outputs:
% Usage: 
%   * NM_RemoveMEEGComponents()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_RemoveMEEGComponents(should_save)

% Make sure we've preprocessed the blinks, if we're not doing them now...
global GLA_meeg_type;
global GLA_epoch_type;
if ~strcmp(GLA_epoch_type,'blinks')
    NM_LoadSubjectData({...
        {[GLA_meeg_type '_blinks_data_preprocessed'],1},...
        });
else
    NM_LoadSubjectData({});
end

% Make sure the eye tracker data is preprocessed, if possible
global GLA_subject_data;
if GLA_subject_data.settings.eye_tracker
    if ~isfield(GLA_subject_data.settings,['et_' GLA_epoch_type '_data_preprocessed']) ||...
            ~GLA_subject_data.settings.(['et_' GLA_epoch_type '_data_preprocessed'])
        error(['Need to preprocess ' GLA_epoch_type ' eye tracker data.']);
    end
end


% Get the clean data
global GLA_meeg_data;
NM_CreateCleanMEEGData();

% Set the options
GLA_meeg_data.settings.decomp_method = GLA_subject_data.settings.meeg_decomp_method;
GLA_meeg_data.settings.decomp_type = GLA_subject_data.settings.meeg_decomp_type;  
GLA_meeg_data.settings.decomp_comp_num = GLA_subject_data.settings.meeg_decomp_comp_num;  
GLA_meeg_data.settings.decomp_baseline_correct = GLA_subject_data.settings.meeg_decomp_baseline_correct;  

% EEG is easier...
if strcmp(GLA_meeg_type,'eeg')
    GLA_meeg_data.settings.decomp_type = 'combined';  
    GLA_meeg_data.data = computeRejections(...
        'eeg', 'EEG');
    
% Otherwise, see which method we need
elseif strcmp(GLA_meeg_data.settings.decomp_type,'combined') 
    removeComponents_Combined();
elseif strcmp(GLA_meeg_data.settings.decomp_type,'separate') 
    removeComponents_Separate();
else
    error('Unknown type');
end

% Default to save
if ~exist('should_save','var') || should_save
    NM_SaveMEEGData();
end

% And clear the clean data
clear global GLA_clean_meeg_data;


function removeComponents_Combined()

% Need to normalize both data sets

full_norms = getNorms('full');
clean_norms = getNorms('clean');
normalizeData(full_norms, 'full');
normalizeData(clean_norms, 'clean');

global GLA_meeg_data;
GLA_meeg_data.data = computeRejections('meg', 'MEG');

% And unnormalize the full data
full_norms = 1./full_norms;
normalizeData(full_norms, 'full');


function data = computeRejections(type, channels)

% See if we already computed on blinks
global GLA_epoch_type;
if ~strcmp(GLA_epoch_type,'blinks')
    
    % See if we want to use the blinks
    while 1
        ch = input('Use saved blinks decomposition? (y/n) ','s');
        if strcmp(ch,'y')
            use_blinks = 1;
            break;
        end
        if strcmp(ch,'n')
            use_blinks = 0;
            break;
        end
    end    
else
    use_blinks = 0;
end

% Either use the blinks or not
if use_blinks
    setComponentsFromBlinks(type);
else
    decomposeData(type, channels); 
end


% And reconstruct
global GLA_meeg_data;
cfg = [];
cfg.demean = 'no';
cfg.component = GLA_meeg_data.settings.([type '_comp_rej']);
data = ft_rejectcomponent(cfg,GLA_meeg_data.settings.([type '_comp']),GLA_meeg_data.data);


function setComponentsFromBlinks(type)

% Just set exactly 
global GLA_meeg_data;
global GLA_subject;
global GLA_meeg_type;
b_data = load([NM_GetRootDirectory() '/analysis/' GLA_subject '/'...
    GLA_subject '_' GLA_meeg_type '_blinks_data.mat']);
GLA_meeg_data.settings.([type '_comp']) = b_data.settings.([type '_comp']);
GLA_meeg_data.settings.([type '_comp_rej']) = b_data.settings.([type '_comp_rej']);
GLA_meeg_data.settings.decomp_type = 'blinks';


function decomposeData(type, channels)

% Used the cleaned data
global GLA_meeg_data;
global GLA_clean_meeg_data;
cfg = [];
cfg.method = GLA_meeg_data.settings.decomp_method;
cfg.numcomponent = GLA_meeg_data.settings.decomp_comp_num;
cfg.channel = channels;
cfg.demean       = GLA_meeg_data.settings.decomp_baseline_correct;
GLA_meeg_data.settings.([type '_comp']) = ft_componentanalysis(cfg,GLA_clean_meeg_data.data);
GLA_meeg_data.settings.([type '_comp']).typechan = cfg.channel;

% Browse...
cfg = [];
cfg.layout = NM_GetMEEGLayout();
ft_databrowser(cfg, GLA_meeg_data.settings.([type '_comp']));

% Display some helpful blink info
displayBlinkInfo(type);

% Get the components to reject
GLA_meeg_data.settings.([type '_comp_rej']) = [];
while 1
    rej = input('Comp to reject (enter to end): ','s');
    if isempty(rej)
        break;
    end
    if ~isnan(str2double(rej))
        GLA_meeg_data.settings.([type '_comp_rej'])(end+1) = str2double(rej);
    end
end


function displayBlinkInfo(type)

% Make sure we actually have it.
% TODO: Implement a backup if the eye tracker goes down.
%   E.g. from the EOG data
global GLA_subject_data;
if ~GLA_subject_data.settings.eye_tracker
    disp('No eye tracker data.');
    return;
end

% Match the data
global GLA_clean_meeg_data;
cfg = [];
cfg.rejections = GLA_clean_meeg_data.rejections;
NM_CreateCleanETData(cfg);

% Print out where the blinks were
has_blinks = displayBlinkOccurrenceInfo();
if ~has_blinks
    return;
end

% Compute and print the correlation
displayBlinkCorrelationInfo(type);

% And clear the data
clear global GLA_clean_et_data;


function displayBlinkCorrelationInfo(type)

global GLA_meeg_data;
num_comp = size(GLA_meeg_data.settings.([type '_comp']).trial{1},1);
all_corr = zeros(num_comp, length(GLA_meeg_data.settings.([type '_comp']).trial));
for t = 1:length(GLA_meeg_data.settings.([type '_comp']).trial)
    all_corr(:,t) = corr(GLA_meeg_data.settings.([type '_comp']).trial{t}',...
        createBlinkTrial(t)');
end
mean_corr = nanmean(all_corr,2);
[val s_ord] = sort(abs(mean_corr),'descend'); %#ok<ASGLU>
disp('Correlation with blinks:');
for c = s_ord'
    disp(['     ' num2str(c) ': ' num2str(mean_corr(c))]); 
end


function b_trial = createBlinkTrial(t)

% For now, just a binary 1 / 0 for blinking
global GLA_clean_et_data;
b_trial = isnan(GLA_clean_et_data.data.x_pos{t});



function has_blinks = displayBlinkOccurrenceInfo()

% Use the cleaned data
has_blinks = 0;
disp('Blinks:');
global GLA_clean_et_data;
for t = 1:length(GLA_clean_et_data.data.blink_starts)
    if ~isempty(GLA_clean_et_data.data.blink_starts{t}) ||...
            ~isempty(GLA_clean_et_data.data.blink_ends{t})
        has_blinks = 1;
        b_str = ['    ' num2str(t) ': '];
        if ~isempty(GLA_clean_et_data.data.blink_starts{t})
            b_str = [b_str 'Starts (']; %#ok<AGROW>
            for b = 1:length(GLA_clean_et_data.data.blink_starts{t})
                b_str = [b_str num2str(GLA_clean_et_data.data.blink_starts{t}(b).time) ',']; %#ok<AGROW>
            end
            b_str = [b_str ') ']; %#ok<AGROW>
        end
        if ~isempty(GLA_clean_et_data.data.blink_ends{t})
            b_str = [b_str 'Ends (']; %#ok<AGROW>
            for b = 1:length(GLA_clean_et_data.data.blink_ends{t})
                b_str = [b_str num2str(GLA_clean_et_data.data.blink_ends{t}(b).time) ',']; %#ok<AGROW>
            end
            b_str = [b_str ') ']; %#ok<AGROW>
        end
        disp(b_str);
    end
end

if ~has_blinks
    disp('     No blinks!');
end



function normalizeData(norms, type)
global GLA_meeg_data;
global GLA_clean_meeg_data;

% Set
switch type
    case 'full'
        data = GLA_meeg_data.data;
        
    case 'clean'
        data = GLA_clean_meeg_data.data;
        
    otherwise
        error('Bad type');
end

% Normalize
for ch = 1:length(data.label)
    ind = -1;
    types = NM_GetMEEGChannelTypes(data.label{ch});
    for t = 1:length(types)
        switch types{t}
            case 'grad_1'
                ind = 1;
            case 'grad_2'
                ind = 2;
            case 'mag'
                ind = 3;
            otherwise
        end
    end
    for t = 1:length(data.trial)
        data.trial{t}(ch,:) = ...
            data.trial{t}(ch,:)/norms(ind);
    end
end

% Set back
switch type
    case 'full'
        GLA_meeg_data.data = data;
        
    case 'clean'
        GLA_clean_meeg_data.data = data;
        
    otherwise
        error('Bad type');
end


function norms = getNorms(type)

global GLA_meeg_data;
global GLA_clean_meeg_data;
switch type
    case 'full'
        data = GLA_meeg_data.data;
        
    case 'clean'
        data = GLA_clean_meeg_data.data;
        
    otherwise
        error('Bad type');
end

% Grab all the limits
ch_limits = ones(length(data.label),2);
ch_limits(:,1) = ch_limits(:,1)*-1000; ch_limits(:,2) = ch_limits(:,2)*1000; 
for t = 1:length(data.trial)
    ch_limits(:,1) = max([ch_limits(:,1) max(data.trial{1},[],2)],[],2);
    ch_limits(:,2) = min([ch_limits(:,2) min(data.trial{1},[],2)],[],2);
end

% Distill the norms
limits = ones(3,2); 
limits(:,1) = limits(:,1)*-1000; limits(:,2) = limits(:,2)*1000; 
for ch = 1:length(data.label)
    ind = -1;
    types = NM_GetMEEGChannelTypes(data.label{ch});
    for t = 1:length(types)
        switch types{t}
            case 'grad_1'
                ind = 1;
            case 'grad_2'
                ind = 2;
            case 'mag'
                ind = 3;
            otherwise
                % Try the next
        end
    end
    limits(ind,1) = max(limits(ind,1),ch_limits(ch,1));
    limits(ind,2) = min(limits(ind,2),ch_limits(ch,2));
end
norms = max(abs(limits),[],2);


function removeComponents_Separate()

% Run the algorithm on each of the senors
s_types = {'grad_1','grad_2','mag'};
recon = {};
global GLA_meeg_data;
for s = 1:length(s_types)
    s_channels.(s_types{s}) = NM_GetMEEGChannels(s_types{s}, GLA_meeg_data.data);
    recon.(s_types{s}) = computeRejections(s_types{s}, s_channels.(s_types{s}));
end

% And reconstruct
for ch = 1:length(GLA_meeg_data.data.label)
    for s = 1:length(s_types)
        ind = find(strcmp(GLA_meeg_data.data.label{ch},s_channels.(s_types{s}))); 

        % When we do, replace the data
        if ~isempty(ind)
            for t = 1:length(GLA_meeg_data.data.trial)
                GLA_meeg_data.data.trial{t}(ch,:) = ...
                    recon.(s_types{s}).trial{t}(ind,:);
            end
        end
    end
end

