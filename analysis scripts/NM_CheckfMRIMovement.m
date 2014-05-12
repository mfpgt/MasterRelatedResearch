%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckfMRIMovement.m
%
% Notes:
%   * Plots the movement throughout the experiment
%       - Either localizer or experiment
%       - For the experiment, all runs are concatenated together
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_CheckfMRIMovement()
%
% Author: Douglas K. Bemis
%   - Adapted from Christophe Pallier
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckfMRIMovement()

% Make sure we're processed 
global GLA_fmri_type;
disp(['Checking movement for for ' GLA_fmri_type ' fmri data...']);
NM_LoadSubjectData({{['fmri_' GLA_fmri_type '_data_preprocessed'],1}});

% Load movement data
switch GLA_fmri_type 
    case 'localizer'
        C = loadLocalizerData();

    case 'experiment'
        C = loadExperimentData();

    otherwise
        error('Unknown type');
end
    
% And plot
global GLA_subject;
figure
subplot(2,1,1); hold on;
title([GLA_subject ' ' GLA_fmri_type ' movement check']);
plot(C{1},'r'); plot(C{2},'g'); plot(C{3},'b'); 
legend({'x','y','z'})
xlabel('scans'); ylabel('mm');

subplot(2,1,2); hold on;
plot(180/pi*C{4},'r'); plot(180/pi*C{5},'g'); plot(180/pi*C{6},'b'); 
legend({'pitch','roll','yaw'})
xlabel('scans'); ylabel('degrees');

% And save
saveas(gcf,[NM_GetRootDirectory() '/analysis/' GLA_subject '/' ...
    GLA_subject '_' GLA_fmri_type '_movement_plot.jpg'],'jpg');


function C = loadExperimentData()

all_C = {};
global GLA_subject_data;
%for r = 1:GLA_subject_data.parameters.num_runs
for r = 1:GLA_subject_data.settings.num_runs
    
    fid = fopen(NM_GetMovementRegressorFileName(r));
    all_C{r} = textscan(fid,'%f%f%f%f%f%f'); %#ok<AGROW>
    fclose(fid);
end

% And put them together
C = {};
for c = 1:length(all_C{1}) 
    C{c} = []; %#ok<AGROW>
    %for r = 1:GLA_subject_data.parameters.num_runs
    for r = 1:GLA_subject_data.settings.num_runs
        C{c} = [C{c}; all_C{r}{c}]; %#ok<AGROW>
    end
end


function C = loadLocalizerData()

fid = fopen(NM_GetMovementRegressorFileName());
C = textscan(fid,'%f%f%f%f%f%f');
fclose(fid);
