% [parcel_cl_avgs, NMDS, class_clusters] = parcel_cl_nmds(parcel_cl_avgs)
%
% Documentation not complete. please update me.
% Tor Wager, Oct 2008
%
% Example:
% -----------------------------------------
% load Parcellation_info/parcellation.mat
% [parcel_cl_avgs, NMDS, class_clusters] = parcel_cl_nmds(parcel_cl_avgs)
%
% parcel_cl_nmds_plots(parcel_cl_avgs, NMDS, 'save')
% parcel_cl_nmds_plots(parcel_cl_avgs, NMDS, 'save', 'savedir', 'Parcellation_info')

function [parcel_cl_avgs, NMDS, class_clusters] = parcel_cl_nmds(parcel_cl_avgs)

    % Get networks of these parcels
    % ---------------------------
    disp('Getting networks of parcels')

    clear data
    N = length(parcel_cl_avgs(1).timeseries);
    for i = 1:length(parcel_cl_avgs), for j = 1:N, data{j}(:,i) = parcel_cl_avgs(i).timeseries{j}; end, end

    % Correlate like this:
    % ---------------------------------------
    % NMDS = xcorr_multisubject(data);
    % NMDS.stats.D = (1 - NMDS.stats.mean) ./ 2;

    % OR like this, if we want to be closer to data and don't need inferences across ss on correlations:
    % ---------------------------------------
    data = [];
    for i = 1:length(parcel_cl_avgs)

        % zscore within, or at least center to avoid individual diffs in
        % baseline driving correlations
        for s = 1:N
            parcel_cl_avgs(i).timeseries{s} = scale(parcel_cl_avgs(i).timeseries{s});
        end

        data(:, i) = cat(1, parcel_cl_avgs(i).timeseries{:});
    end

    desired_alpha = .01;
    fprintf(['Saving FDR-corrected connections at q < %3.3f corrected\n' desired_alpha]);
    
    NMDS.parcel_data = data;
    [NMDS.stats.c, NMDS.stats.pvals] = corrcoef(data);
    [NMDS.stats.fdrthr, NMDS.stats.fdrsig] = fdr_correct_pvals(NMDS.stats.pvals, NMDS.stats.c, desired_alpha);

    NMDS.stats.D = (1 - NMDS.stats.c) ./ 2;

    % Pick number of dimensions
    maxclasses = round(length(parcel_cl_avgs) ./ 10);
    maxclasses = min(maxclasses, 20);
    maxclasses = max(maxclasses, 5);

    disp('Choosing number of dimensions')
    [NMDS.stats_mds.GroupSpace,NMDS.stats_mds.obs,NMDS.stats_mds.implied_dissim] = shepardplot(NMDS.stats.D, maxclasses);

    % Clustering with permutation test to get number of clusters

    disp(['Clustering regions in k-D space: 2 to ' num2str(maxclasses) ' classes.'])

    NMDS.stats_mds = nmdsfig_tools('cluster_solution',NMDS.stats_mds, NMDS.stats_mds.GroupSpace, 2:maxclasses, 1000, []);


    % Set Colors
    basecolors = {[1 0 0] [0 1 0] [0 0 1] [1 1 0] [0 1 1] [1 0 1] ...
        [1 .5 0] [.5 1 0] [.5 0 1] [1 0 .5] [0 1 .5] [0 .5 1]};

    NMDS.basecolors = basecolors;
       
%     % Make figure
%     disp('Visualizing results')
%     create_figure('nmdsfig')

%     nmdsfig(NMDS.stats_mds.GroupSpace,'classes',NMDS.stats_mds.ClusterSolution.classes, ...
%         'names', [],'sig',NMDS.stats.fdrsig, 'fill', 'colors', basecolors);

    % disp('Saving NMDS structure with networks in parcellation.mat')
    % save(fullfile(mysavedir, 'parcellation.mat'), '-append', 'class_clusters', 'parcel*')

    % re-define class clusters
    clear class_clusters
    for i = 1:max(NMDS.stats_mds.ClusterSolution.classes)
        wh = find(NMDS.stats_mds.ClusterSolution.classes == i);
        class_clusters{i} = parcel_cl_avgs(wh);

        % refine class (network) membership
        [parcel_cl_avgs(wh).from_class] = deal(i);
    end

    % disp('Saving NMDS structure and final class clusters in parcellation.mat')
    % save(fullfile(mysavedir, 'parcellation.mat'), '-append', 'NMDS', 'class_clusters')


end


function [pthr,sig] = fdr_correct_pvals(p, r, desired_alpha)

    psq = p; psq(find(eye(size(p,1)))) = 0;
    psq = squareform(psq);
    pthr = FDR(p, desired_alpha);
    if isempty(pthr), pthr = 0; end

    sig = sign(r) .* (p < pthr);

    sig(isnan(sig)) = 0;
end




