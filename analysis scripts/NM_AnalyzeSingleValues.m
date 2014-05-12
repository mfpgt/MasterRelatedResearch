%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_AnalyzeSingleValues.m
%
% Notes:
%   * Performs an analysis of single measures from each condition (i.e. one
%       value per each of the ten conditions, compared to a full time course).
%       - Will load and calculate these measures if possible
%       - Or can be given as an argument
%   * Analyzes the main effect between list and phrases, by pooling over
%       all 2-4 word conditions in each.
%       - A bar graph of this comparison is printed on the left side of the
%           analysis results.
%   * Analyzes the linear effects for both phrases and lists.
%       - A  graph of this analysis is printed on the right side of the
%           analysis results.
%       - r^2 values for both linear correlations are displayed
%       - Condition-by-condition uncorrected comparisons are displayed as
%           well, along with a summary of an ANOVA over the four base
%           conditions.
%   * Saves the analysis results summary in the subject analysis folder.
%
% Inputs:
%   * cfg: The settings for the analysis, with the following fields:
%       - data_type: The type of data to analyze
%           - E.g. 'behavioral','et'
%       - epoch_type: The trial type to analyze, if applicable
%       - measure: The values to analyze. Specific to the data_type:
%           - for 'et':
%               - num_saccades: The number of saccades during each trial
%               - saccade_length: The length of saccades during each trial
%           - for 'behavioral':
%               - rt: The reaction time for each trial
%               - acc: The accuracy for each trial
%       - sv_name: A name for the measured values.
%           - Will be used to save the analysis summary.
%       - SV_data (optional): A set of values to analyze
%           - Should be arranged with the following fields:
%               - trial_data: The value to analyze for each trial
%               - trial_cond: An array of condition values for each trial
%                   - 1:5 - The phrase conditions (1-5)
%                   - 6:10 - The list conditions (6-10)
%       - rejections, etc. (optional): All options used by 
%           NM_CreateClean*Data functions.
%
% Outputs:
% Usage: 
%   * cfg = [];
%   * cfg.data_type = 'et';
%   * cfg.epoch_type = 'word_5';
%   * cfg.measure = 'num_saccades';
%   * cfg.sv_name = 'num_sacc';
%   * NM_AnalyzeSingleValues(cfg)
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_AnalyzeSingleValues(cfg)

% Check the cfg
if ~isfield(cfg,'measure') || ...
        ~isfield(cfg,'data_type') ||...
        ~isfield(cfg,'sv_name')
    error('Badly formed cfg. See help.'); 
end

global GLA_subject;
disp(['Analyzing ' cfg.data_type ' ' ...
    cfg.measure ' data for ' GLA_subject '...']);

% Make sure we're loaded
NM_LoadSubjectData();

% Set the measure
setValues(cfg);

% Arrange them in the way way expect
arrangeData()

% Take a look at the main effect
analyzeMainEffect(cfg);

% And the trands
analyzeLinearEffect(cfg);

% And save and clear the data
saveas(gcf, [NM_GetRootDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_' cfg.sv_name '_analysis.jpg'],'jpg');
clear global GL_SV_data;


function setValues(cfg)

% Calculate the measures
clear global GL_SV_data;

% Might have been given it
global GL_SV_data;
if isfield(cfg,'SV_data')
    GL_SV_data = cfg.SV_data;
    
% Otherwise need to load
else
    switch cfg.data_type
        case 'behavioral'
            setBehavioralValues(cfg);

        case 'et'
            setETValues(cfg);

        otherwise
            error('Unknown type');
    end
end


function setETValues(cfg)

% Make the clean data with the right trial type
global GLA_epoch_type;
GLA_epoch_type = cfg.epoch_type; 
NM_CreateCleanETData(cfg);    

% Set and arrange the right measure
global GL_SV_data;
global GLA_clean_et_data;
switch cfg.measure
    case 'num_saccades'
        GL_SV_data.trial_data = zeros(size(GLA_clean_et_data.data.cond));
        for t = 1:length(GLA_clean_et_data.data.cond)
            if ~isempty(GLA_clean_et_data.data.saccade_starts{t}) ||...
                    ~isempty(GLA_clean_et_data.data.saccade_ends{t})
                GL_SV_data.trial_data(t) = 1;
            end
        end
        
    case 'saccade_length'
        GL_SV_data.trial_data = zeros(size(GLA_clean_et_data.data.cond));
        for t = 1:length(GLA_clean_et_data.data.cond)
            for s = 1:length(GLA_clean_et_data.data.saccade_ends{t})
                GL_SV_data.trial_data(t) = GL_SV_data.trial_data(t) + ...
                    GLA_clean_et_data.data.saccade_ends{t}(s).length;
            end
        end
        
    otherwise
        error('Unknown type');
end
GL_SV_data.trial_cond = GLA_clean_et_data.data.cond;


function setBehavioralValues(cfg)

% Make the clean data
NM_CreateCleanBehavioralData(cfg);    

% Set and arrange the right measure
global GL_SV_data;
global GLA_clean_behavioral_data;
switch cfg.measure
    case 'rt'
        GL_SV_data.trial_data = [GLA_clean_behavioral_data.data.rt{:}];

    case 'acc'
        GL_SV_data.trial_data = [GLA_clean_behavioral_data.data.acc{:}];
        
    otherwise
        error('Unknown type');
end
GL_SV_data.trial_cond = GLA_clean_behavioral_data.data.cond;


function arrangeData()

% Arrange the data how we want
global GL_SV_data;
GL_SV_data.conditions = sort(unique(GL_SV_data.trial_cond));
for c = 1:length(GL_SV_data.conditions)
    GL_SV_data.condition_data{c} = ...
        GL_SV_data.trial_data(GL_SV_data.trial_cond == GL_SV_data.conditions(c));
end


function analyzeLinearEffect(cfg)

% Summarize
global GL_SV_data;
types = {'phrases','lists'};
means = []; stderrs = []; p = [];
all_measures.phrases = []; all_measures.lists = [];
for c = 1:4
    for t = 1:length(types)
        
        % Get the right condition
        if strcmp(types{t},'lists')
            cond = c + 5;
        else
            cond = c; 
        end
        
        means(t,c) = mean(GL_SV_data.condition_data{cond}); %#ok<AGROW>
        stderrs(t,c) = std(GL_SV_data.condition_data{cond})/...
            sqrt(length(GL_SV_data.condition_data{cond})); %#ok<AGROW>
        all_measures.(types{t}) = [all_measures.(types{t}); ...
            [GL_SV_data.condition_data{cond}' ...
                repmat(c,length(GL_SV_data.condition_data{cond}),1)]];
    end
    [h p(end+1)] = ttest2(GL_SV_data.condition_data{c},GL_SV_data.condition_data{c+5}); %#ok<ASGLU,AGROW>
end

% And plot
global GLA_subject;
subplot(1,2,2); hold on; 
title([GLA_subject ' ' cfg.sv_name]);
colors = {'r','g'};
for t = 1:length(types)
    plot(means(t,:),colors{t},'LineWidth',2);
end
legend(types,'location','best'); xlabel('Condition')
for t = 1:length(types)
    errorbar(means(t,:),stderrs(t,:),'k');    
end
for t = 1:length(types)
    plot(means(t,:),colors{t},'LineWidth',2);
end

% Reset the axis
axis([.5,5.5, min(min(means-stderrs))-5*mean(mean(stderrs)),...
    max(max(means+stderrs))+3*mean(mean(stderrs))]);
ax = axis();

% Plot significance
for c = 1:length(p)
    plotSig(p(c),c,max(means(:,c)+stderrs(:,c))+1.5*mean(stderrs(:,c)));
end


% Look at the linear trends
for t = 1:length(types)
    [r p] = corr(all_measures.(types{t}));
    str = ['r^2 = ' num2str(round(r(1,2)*r(1,2)*100)/100)];
    if p(1,2) < 0.05
        str = [str ' *']; %#ok<AGROW>
    end
    text(4.2,means(t,end),str);
end

a = [all_measures.phrases(:,1); all_measures.lists(:,1)];
b = [ones(length(all_measures.phrases(:,1)),1); repmat(2,length(all_measures.lists(:,1)),1)];
c = [all_measures.phrases(:,2); all_measures.lists(:,2)];
p = anovan(a,{b,c},'display','off','model','interaction');

labels = {'structure','length','interaction'};
for i = 1:length(labels)
    text(1,ax(3)+(.05*i)*(ax(4)-ax(3)),[labels{i} ': p = ' num2str(p(i))]);
end


function analyzeMainEffect(cfg)

% Pool the different conditions
global GL_SV_data;
pooled.phrases = horzcat(GL_SV_data.condition_data{2},...
    GL_SV_data.condition_data{3},GL_SV_data.condition_data{4}); 
pooled.lists = horzcat(GL_SV_data.condition_data{7},...
    GL_SV_data.condition_data{8},GL_SV_data.condition_data{9}); 


% Test for an effect
[h p] = ttest2(pooled.phrases,pooled.lists); %#ok<ASGLU>

% And plot
global GLA_subject;
figure; subplot(1,2,1); hold on; 
title([GLA_subject ' ' cfg.sv_name]);

% Plot the means
types = {'phrases','lists'};
colors = {'r','g'};
means = []; stderrs = [];
for t = 1:length(types)
    means(t) = mean(pooled.(types{t})); %#ok<AGROW>
    bar(t, means(t),colors{t});
    stderrs(t) = std(pooled.(types{t}))/sqrt(length(pooled.(types{t}))); %#ok<AGROW>
    errorbar(t,means(t), stderrs(t),'k','LineWidth',2);
end

% Reset the axis
a = axis();
axis([a(1:2), min(means-stderrs)-5*mean(stderrs), max(means+stderrs)+3*mean(stderrs)]);
set(gca,'XTickLabel',{'','phrases','','lists',''})

% Plot significance
plotSig(p,mean(a(1:2)),max(means+stderrs)+1.5*mean(stderrs));


function plotSig(p,x,y)

if p < 0.001
    t = text(x,y,'***');
elseif p < 0.01
    t = text(x,y,'**');
elseif p < 0.05
    t = text(x,y,'*');
elseif p < 0.1
    t = text(x,y,'(*)');
else
    return;
end
set(t,'FontSize',30);


