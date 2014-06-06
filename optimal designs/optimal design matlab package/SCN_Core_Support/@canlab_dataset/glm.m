function [b, dev, stat] = glm(D, Yvarname, Xvarnames, wh_keep)
%
% predict Y from X using GLM
%
% Usage:
% ----------------------------------------------------------------------------------
% [b, dev, stat] = glm(D, 'DeltaDon_avg', prednames, wh_keep)
%
% Inputs:
% ----------------------------------------------------------------------------------
% D             a canlab_dataset object
% Yvarname      the name of a variable to predict. must be subject level
% Xvarnames     the name(s) of predictor variables. if multiple, put in
%               cell array. must be subject_level
% wh_keep       a vector of 1/0 values to use as wh_keep
%
% Outputs:
% ----------------------------------------------------------------------------------
% same as for glmfit()
%
% % Copyright Tor Wager, 2013

[y, ~, levelY] = get_var(D, Yvarname, wh_keep);
[X, ~, levelX] = get_var(D, Xvarnames, wh_keep);      

if levelY ~= 1 || levelX ~= 1, error('Vars must be subject level'); end

[b, dev, stat] = glmfit(X, y);
glm_table(stat, Xvarnames)

