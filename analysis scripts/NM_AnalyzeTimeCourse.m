%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzeTimeCourse.m
%
% Notes:
%   * Performs an analysis of time course data
%       - Will load and calculate the course if possible
%       - Or can be given as an argument
%   * Analyzes the phrase and list time courses separately
%       - Plots phrase lengths 1-4
%       - Tests each time point for linear effects and pairwise comparisons
%           between successive conditions (e.g. 2 v. 3 words)
%           - If p < 0.05 then the point will be marked
%           - Lowest line: Linear effects 
%               - Black: linear effect 4 > 3 > 2 > 1
%               - Yellow: linear effect 1 > 2 > 3 > 4
%           - Lines 2-5: Pairwise effects
%               - n v. n-1: Color represents condition with greater value
%   * Can analyze individual time windows within the time course if
%       requested, using NM_AnalyzeSingleValues
%   * Saves the analysis results summary in the subject analysis folder.
%
% Inputs:
%   * cfg: The settings for the analysis, with the following fields:
%       - data_type: The type of data to analyze
%           - E.g. 'behavioral','et','meg','eeg'
%       - epoch_type: The trial to analyze
%       - measure: The values to analyze. Specific to the data_type:
%           - for 'et':
%               - x_pos: The horizontal position of the eye
%               - y_pos: The vertical position of the eye
%               - pupil: The size of the pupil
%               - x_vel: The derivative of the horizontal position of the eye
%               - y_vel: The derivative of the vertical position of the eye
%           - for 'meg' and 'eeg':
%               - rms: The root-mean-square of the sensor data 
%       - tc_name: A name for the time course
%           - Will be used to save the analysis summary.
%       - p_threshold (optional): Controls the (uncorrected) level of the plotting
%       - TC_data (optional): A timecourse to analyze
%           - Should be arranged with the following fields:
%               - trial_data: The time course to analyze for each trial
%               - trial_cond: An array of condition values for each trial
%                   - 1:5 - The phrase conditions (1-5)
%                   - 6:10 - The list conditions (6-10)
%               - trial_time: One array indicating the time (relative to 0)
%                   of each point in the time course
%       - time_windows (optional): A cell array of [beg end] pairs indicating time
%           windows to analyze using NM_AnalyzeSingleValues
%       - time_window_measure (optional): The measure to use to reduce the data in the
%           time window to a single value:
%           - mean: Take the mean of the data
%           - rms: Take the rms of the data
%           - max: Take the max of the data
%           - min: Take the min of the data
%       - rejections, etc. (optional): All options used by NM_CreateClean*Data functions.
%
% Outputs:
% Usage: 
%   * cfg = [];
%   * cfg.data_type = 'meg';
%   * cfg.epoch_type = 'word_5';
%   * cfg.measure = 'rms';
%   * cfg.tc_name = 'meg_word_5_rms';
%   * cfg.time_windows = {[200 300] [300 500]};
%   * cfg.time_window_measure = 'rms';
%   * NM_AnalyzeTimeCourse(cfg)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AnalyzeTimeCourse(cfg)

% Check the cfg structure
if ~isfield(cfg,'measure') || ...
        ~isfield(cfg,'data_type') ||...
        ~isfield(cfg,'epoch_type') ||...
        ~isfield(cfg,'tc_name')
    error('Badly formed cfg. See help.'); 
end

global GLA_subject;
disp(['Analyzing ' cfg.measure ' ' cfg.epoch_type ' ' ...
    cfg.data_type ' data for ' GLA_subject '...']);

% Make sure we're loaded
NM_LoadSubjectData();

% Get the timecourse
setTimeCourseData(cfg);

% Pre-group as well, so we can average / test easier
grougData();

% Plot it by condition
plotTimeCourseData(cfg);

% Do a point-by-point comparison
analyzeTimeCourseData(cfg);

% And save
saveas(gcf,[NM_GetRootDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_' cfg.tc_name '_analysis.jpg']);

% And any time windows    
if isfield(cfg,'time_windows')
    for w = 1:length(cfg.time_windows)
        analyzeTimeWindow(cfg.time_windows{w}, cfg);
    end
end


function analyzeTimeCourseData(cfg)

% Plot both types
for t = 1:2
    plotStats(t,(t-1)*5+1:t*5-1, cfg);
end


function analyzeTimeWindow(window, cfg)

global GL_TC_data;
w_start = find(GL_TC_data.trial_time == window(1),1);
w_end = find(GL_TC_data.trial_time == window(2),1);
cfg.SV_data.trial_cond = GL_TC_data.trial_cond;
for t = 1:length(GL_TC_data.trial_data)
    switch cfg.time_window_measure
        case 'mean'
           cfg.SV_data.trial_data(t) = mean(GL_TC_data.trial_data{t}(w_start:w_end));

        case 'rms'
           cfg.SV_data.trial_data(t) = sqrt(mean(GL_TC_data.trial_data{t}(w_start:w_end) .^2));
        
        case 'max'
           cfg.SV_data.trial_data(t) = max(GL_TC_data.trial_data{t}(w_start:w_end));
        
        case 'min'
           cfg.SV_data.trial_data(t) = min(GL_TC_data.trial_data{t}(w_start:w_end));
           
        otherwise
            error('Unknown measure');
    end
end

% Set the name and analyze
cfg.sv_name = [cfg.tc_name '_' cfg.time_window_measure ...
    ' (' num2str(window(1)) '-' num2str(window(2)) ')'];       % For naming
NM_AnalyzeSingleValues(cfg);



function plotStats(t_num, conditions, cfg)

% Set the plotting parameters
subplot(2,1,t_num);
a = axis(); 
line_spacing = (a(4)-a(3))/20;
axis([a(1) a(2) a(3) a(4) + line_spacing*6]);
hold on;
colors = {'b','g','r','c'};

% Calculate point-by-point linear correlation
global GL_TC_data;
corr_data_x = [];
corr_data_y = [];
for c = conditions
    corr_data_x = vertcat(corr_data_x,GL_TC_data.condition_data{c}); %#ok<AGROW>
    corr_data_y = vertcat(corr_data_y,c*ones(size(GL_TC_data.condition_data{c},1),1)); %#ok<AGROW>
end
[r p] = corr(corr_data_x, corr_data_y);
plotStat(a, line_spacing, 1, p, r, {'k','y'}, cfg);

% And the pairwise comparisons
for c = 1:length(conditions)-1
    
    [h p ci s] = ttest2(GL_TC_data.condition_data{conditions(c)},...
        GL_TC_data.condition_data{conditions(c+1)}); %#ok<ASGLU>
    plotStat(a, line_spacing, c+1, p, s.tstat, {colors{c},colors{c+1}}, cfg);
end


function plotStat(a, line_spacing, line_num, p, dir, colors, cfg)

% Fix the points
x = a(1):a(2)-1; y = (a(4)+line_num*line_spacing)*ones(1,a(2)-a(1));

% And plot both sides
if ~isfield(cfg,'p_threshold')
    cfg.p_threshold = 0.05;
end
scatter(x(p<cfg.p_threshold & dir > 0), y(p<cfg.p_threshold & dir > 0),1,'.',colors{1});
scatter(x(p<cfg.p_threshold & dir < 0), y(p<cfg.p_threshold & dir < 0),1,'.',colors{2});


function plotTimeCourseData(cfg)

% Phrases first...
figure; hold on; subplot(2,1,1);
plotSet('phrases', cfg);

% Then lists...
subplot(2,1,2);
plotSet('lists', cfg);


function plotSet(type, cfg)

global GL_TC_data;

switch type
    case 'phrases'
        conditions = 1:4;
        
    case 'lists'
        conditions = 6:9;
        
    otherwise
        error('Unknown type');
end

% Average the conditions of interest
% I.e. not the extraneous one-word condition for now
avg_data = zeros(length(conditions),length(GL_TC_data.trial_time));
for c = 1:length(conditions)
    avg_data(c,:) = mean(GL_TC_data.condition_data{conditions(c)});
end
plot(GL_TC_data.trial_time,avg_data');

% Labels
global GLA_subject;
title([type ': ' GLA_subject ' ' cfg.tc_name]);
legend('1','2','3','4','Location','NorthEastOutside');


function setTimeCourseData(cfg)

% Send to right function
clear global GL_TC_data;
global GL_TC_data;
global GLA_meeg_type;
if isfield(cfg,'TC_data')
    GL_TC_data = cfg.TC_data;
    
% Otherwise need to load
else
    switch cfg.data_type
        case 'meg'
            GLA_meeg_type = 'meg';
            setMEEGData(cfg);

        case 'eeg'
            GLA_meeg_type = 'eeg';
            setMEEGData(cfg);

        case 'et'
            setETData(cfg);

        otherwise
            error('Unknown type');
    end
end


function grougData()

global GL_TC_data;
for c = unique(GL_TC_data.trial_cond)
    t_ctr = 1;
    GL_TC_data.condition_data{c} = [];
    for t = find(GL_TC_data.trial_cond == c)
        GL_TC_data.condition_data{c}(t_ctr,:) = ...
            GL_TC_data.trial_data{t};
        t_ctr = t_ctr+1;
    end
end


function setETData(cfg)
        
% Load the cleaned data for the requested trial type
global GLA_epoch_type;
GLA_epoch_type = cfg.epoch_type;
NM_CreateCleanETData(cfg);

% Get each trial
global GL_TC_data;
global GLA_clean_et_data;
for t = 1:length(GLA_clean_et_data.data.cond)
    switch cfg.measure
        case 'x_pos'
            GL_TC_data.trial_data{t} = GLA_clean_et_data.data.x_pos{t};
    
        case 'y_pos'
            GL_TC_data.trial_data{t} = GLA_clean_et_data.data.y_pos{t};
            
        case 'pupil'
            GL_TC_data.trial_data{t} = GLA_clean_et_data.data.pupil{t};

        case 'x_vel'
            GL_TC_data.trial_data{t} = [0 diff(GLA_clean_et_data.data.x_pos{t})];

        case 'y_vel'
            GL_TC_data.trial_data{t} = [0 diff(GLA_clean_et_data.data.y_pos{t})];

        otherwise
            error('Unknown measure');
    end            
end

% Set these faster...
GL_TC_data.trial_cond = GLA_clean_et_data.data.cond; 
GL_TC_data.trial_time = GLA_clean_et_data.data.epoch(1):GLA_clean_et_data.data.epoch(2)-1;

% And clear the data
clear global GLA_clean_et_data;


function setMEEGData(cfg)
        
% Load the cleaned data
global GLA_epoch_type;
GLA_epoch_type = cfg.epoch_type;
NM_CreateCleanMEEGData(cfg);

% Get each trial
global GL_TC_data;
global GLA_clean_meeg_data;
for t = 1:length(GLA_clean_meeg_data.data.trial)
    switch cfg.measure
        case 'rms'
            % TODO: Might want to multiply the mag sensors...
            GL_TC_data.trial_data{t} = sqrt(mean(GLA_clean_meeg_data.data.trial{t}.^2,1));

        otherwise
            error('Unknown measure');
    end            
end

% Set these faster...
GL_TC_data.trial_cond = GLA_clean_meeg_data.data.trialinfo'; 
GL_TC_data.trial_time = GLA_clean_meeg_data.data.time{1}*1000;        % In ms...

% And clear the data
clear global GLA_clean_meeg_data;


