%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_SanityCheckETData.m
%
% Notes:
%   * Checks to make sure that the eye tracking data is reasonable. 
%       - Plots the average position of the eyes during left and right eye
%           movement trials.
%           - Also, the RT of the first saccade in each trial.
%       - Prints the onset time of the blinks and what proportion of blink
%           trials contained blinks.
%   * Saves the results to NIP_ET_Sanity_Check.jpg
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_SanityCheckETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_SanityCheckETData()

% See if there's something to do
NM_LoadSubjectData();
global GLA_subject_data;
if ~GLA_subject_data.settings.eye_tracker
    return;
end

% Make sure we're processed 
global GLA_subject;
disp(['Sanity checking eye tracking data for ' GLA_subject '...']);
NM_LoadSubjectData({...
    {'et_right_eye_movements_data_preprocessed',1},...
    {'et_left_eye_movements_data_preprocessed',1},...
    {'et_blinks_data_preprocessed',1},...
    });

% Tally the blinks
b_rts = getBlinkRTs();

% Get the eye movement saccades
[e_pos e_rts] = getEyeMovementMeasures();

% Plot and save the results
figure;
scatter(e_pos.left(:,1), -e_pos.left(:,2),5,'r');
hold on;
scatter(e_pos.right(:,1), -e_pos.right(:,2),5,'b');
title(['Eye tracker Sanity Check (' GLA_subject ')']);
xlabel('x pos'); ylabel('y pos'); 
a = axis(); axis([0 a(2)+a(1) a(3)+a(4) 0]); a = axis();
legend('left','right');
num_move = GLA_subject_data.settings.num_eye_movements;
text(mean(e_pos.left(:,1))-90, -(mean(e_pos.left(:,2))+50), ...
    [num2str(mean(e_rts.left)) 'ms (' num2str(100*length(e_pos.left)/num_move) '%)']);
text(mean(e_pos.right(:,1))-90, -(mean(e_pos.right(:,2))-50), ...
    [num2str(mean(e_rts.right)) 'ms (' num2str(100*length(e_pos.right)/num_move) '%)']);
text(.5*a(2)-100, .75*a(3), ['Blinks: ' num2str(mean(b_rts)) 'ms (' ...
    num2str(100*length(b_rts)/GLA_subject_data.settings.num_blinks) '%)']);
saveas(gcf,[NM_GetRootDirectory() '/analysis/' GLA_subject '/' GLA_subject '_ET_Sanity_Check.jpg'],'jpg');




function [pos rt] = getEyeMovementMeasures()

% Both the left and right
global GLA_et_data;
global GLA_epoch_type;
directions = {'left','right'};
for d = 1:length(directions)

    % Get the data
    GLA_epoch_type = [directions{d} '_eye_movements'];
    NM_LoadETData();

    pos.(directions{d}) = []; rt.(directions{d}) = []; 
    for t = 1:length(GLA_et_data.data.saccade_starts)
        if ~isempty(GLA_et_data.data.saccade_starts{t})

            % NOTE: Only taking the first one. Might not be rightest...
            rt.(directions{d})(end+1) = GLA_et_data.data.saccade_starts{t}(1).time;
        end

        % And just get the average position
        pos.(directions{d})(end+1,:) = [nanmean(GLA_et_data.data.x_pos{t}) nanmean(GLA_et_data.data.y_pos{t})];
    end
end


function b_rts = getBlinkRTs()

% Get the data
global GLA_epoch_type;
curr_tt = GLA_epoch_type;
GLA_epoch_type = 'blinks'; %#ok<NASGU>
NM_LoadETData();
GLA_epoch_type = curr_tt;

global GLA_et_data;
b_rts = [];
for t = 1:length(GLA_et_data.data.blink_starts)
    if ~isempty(GLA_et_data.data.blink_starts{t})
        b_rts(end+1) = GLA_et_data.data.blink_starts{t}.time; %#ok<AGROW>
    end
end


