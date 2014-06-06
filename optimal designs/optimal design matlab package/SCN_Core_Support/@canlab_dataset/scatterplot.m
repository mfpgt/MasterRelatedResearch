function fig_han = scatterplot(D, v1, v2, varargin)
%
% fig_han = scatterplot(D, varname1, varname2, varargin)
%
% Scatterplot of two variables in dataset
% - can be either event-level or subject-level
% - event-level data is plotted as multi-line plot, one line per subject
% - both variables must be valid names (case-sensitive)
%
% Optional inputs:
%  - 'nofig': suppress creation of new figure
%
% Example:
%
% scatterplot(D, 'Anxiety', 'Frustration');
% fig_han = scatterplot(D, D.Subj_Level.names{1}, D.Subj_Level.names{2});
% scatterplot(D, D.Event_Level.names{1}, D.Event_Level.names{2});
%
% Copyright Tor Wager, 2013

fig_han = [];
dofig = 1;

if any(strcmp(varargin, 'nofig'))
    dofig = 0;
end

[dat1, dcell1, whlevel1] = get_var(D, v1, varargin{:});
[dat2, dcell2, whlevel2] = get_var(D, v2, varargin{:});

if whlevel1 ~= whlevel2
    disp('No plot: Variables are not at same level of analysis.');
    return
end

if isempty(dat1) || isempty(dat2)
    % skip
    disp('No plot: Missing variables');
    return
end

if dofig
    fig_han = create_figure([v1 '_vs_' v2]);
else
    fig_han = gcf;
end

switch whlevel1
    case 1
        plot_correlation_samefig(dat1, dat2);
        grid off
        
    case 2
        
        han = line_plot_multisubject(dcell1, dcell2, varargin{:});
        
    otherwise
        error('Illegal level variable returned by get_var(D)');
end

set(gca, 'FontSize', 24)

xlabel(strrep(v1, '_', ' '));
ylabel(strrep(v2, '_', ' '));

rtotal = corr(dat1(:), dat2(:));

switch whlevel1
    case 1
        str = sprintf('r = %3.2f\n', rtotal);
        disp(str)
        
    case 2
        for i = 1:length(dcell1)
            x1{i} = scale(dcell1{i}, 1); % mean-center
            x2{i} = scale(dcell2{i}, 1);
        end
        rwithin = corr(cat(1, x1{:}), cat(1, x2{:}));
        
        str = sprintf('r across all data: %3.2f\nr within subjects: %3.2f', rtotal, rwithin);
        disp(str)
        
    otherwise ('Illegal value!');
        
end


xloc = mean(dat1(:)) + std(dat1(:));
yloc = mean(dat2(:)) + std(dat2(:));

text(xloc, yloc, str, 'FontSize', 22);


end % function

