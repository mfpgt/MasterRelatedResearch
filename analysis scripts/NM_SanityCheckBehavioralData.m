%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SanityCheckBehavioralData.m
%
% Notes:
%   * Quick sanity check of the behavioral data.
%       - Plots a histogram of the rts.
%       - Prints a summary of the errors / timouts on the graph
%       - Saves the graph to NIP_Behavioral_Sanity_Check.jpg
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SanityCheckBehavioralData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SanityCheckBehavioralData()

global GLA_subject;
disp(['Sanity checking behavioral data for ' GLA_subject '...']);

% Make sure we're processed 
disp('Loading data...');
NM_LoadSubjectData({{'experiment_behavioral_data_preprocessed',1}});
disp('Done.');

% Load the experiment data
global GLA_fmri_type;
GLA_fmri_type = 'experiment';
NM_LoadBehavioralData();

% Check the number of outliers and timeouts
global GLA_behavioral_data;
good_rts = []; good_accs = [];
for t = 1:length(GLA_behavioral_data.data.cond)
    if isempty(find(GLA_behavioral_data.data.outliers == t,1)) && ...
            isempty(find(GLA_behavioral_data.data.timeouts == t,1))
        good_rts(end+1) = GLA_behavioral_data.data.rt{t}; %#ok<AGROW>
        good_accs(end+1) = GLA_behavioral_data.data.acc{t}; %#ok<AGROW>
    end
end

% Plot the results
figure;
global GLA_subject_data;
hist(good_rts,round(length(good_rts)/10));
title(['Behavioral Sanity Check (' GLA_subject ')']);
ylabel('Num trials'); xlabel('msec');

% Add the info and save
pos = round(.75*axis);
text(pos(2),pos(4),['Accuracy: ' num2str(100*mean(good_accs)) '%']);
text(pos(2),pos(4)-3,['Outliers: ' num2str(100*length(GLA_behavioral_data.data.outliers) / ...
    (length(GLA_behavioral_data.data.cond) - length(GLA_behavioral_data.data.timeouts))) '%']);
text(pos(2),pos(4)-6,['Timeouts: ' num2str(100*length(GLA_behavioral_data.data.timeouts) / ...
    GLA_subject_data.settings.num_trials) '%']);

% And check the localizer, if we have it
global GLA_rec_type;
if strcmp(GLA_rec_type,'fmri')
    r_times = checkLocalizerResponses();
    disp(['Average localizer response time: ' num2str(1000*mean(r_times)) ' ms.']);
    text(pos(2),pos(4)-9,['Localizer: ' num2str(1000*mean(r_times)) ' ms.']);
end

% And save
saveas(gcf,[NM_GetRootDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_Behavioral_Sanity_Check.jpg'],'jpg');


function r_times = checkLocalizerResponses()

global GLA_fmri_type;
curr_ft = GLA_fmri_type;
GLA_fmri_type = 'localizer'; %#ok<NASGU>
NM_LoadBehavioralData();
GLA_fmri_type = curr_ft;

% Else, make sure we're right
r_times = [];
warn_time = 1.5;
global GLA_subject_data;
global GLA_behavioral_data;
r_ctr = 1;
for b = 1:GLA_subject_data.settings.num_localizer_blocks
    if ~isempty(GLA_subject_data.data.localizer.blocks(b).params.catch_trial)
        rt = GLA_behavioral_data.data.rt{r_ctr}; 
        if isempty(rt)
            error('No localizer response found.');
        elseif rt > warn_time
            disp(['WARNING: Localizer response ' num2str(r_ctr) ' is pretty slow: ' ...
                num2str(1000*rt) ' ms']);
        end
        r_times(end+1) = rt; r_ctr = r_ctr+1; %#ok<AGROW>
    end
end


