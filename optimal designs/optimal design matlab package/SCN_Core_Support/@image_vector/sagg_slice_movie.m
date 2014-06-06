function sagg_slice_movie(dat, varargin)
% sagg_slice_movie(dat, [full_path_of_movie_output_file])
%
% Movie of successive differences (sagittal slice)
% Enter an image_vector or fmri_data object (usually with time series)
%

% ------------------------------------------------------
writetofile = 0;
if length(varargin) > 0
    movieoutfile = varargin{1};
    writetofile = 1;
end

sdlim = 3.5;

mm = mean(dat);
sdiffs = diff(dat.dat')';
sdiffs = [mean(sdiffs, 2) sdiffs]; % keep in image order
mysd = std(sdiffs(:));
mylim = [mean(sdiffs(:)) - sdlim*mysd mean(sdiffs(:)) + sdlim*mysd];

%mymean = mean(dat.dat); % global mean
spatsd = std(sdiffs);  % variation in successive diffs - like rmssd but without abs mean diff. artifacts in some parts of image...
rmssd = ( mean(sdiffs .^ 2) ) .^ .5; % rmssd - root mean square successive diffs

% avoid first time point being very different and influencing distribution and plots.
spatsd(1) = mean(spatsd);
rmssd(1) = mean(rmssd); 

corrcoef(spatsd, rmssd)

slow1 = [abs(rmssd) > mean(rmssd) + sdlim*std(rmssd)];
slow2 = [abs(spatsd) > mean(spatsd) + sdlim*std(spatsd)];
slow = slow1 | slow2;

fh = create_figure('succ_diffs', 2, 1);
ax1 = subplot(2, 1, 1);
title('Root mean square successive diffs');

ax2 = subplot(2, 1, 2);
set(ax1, 'Position', [.13 .75 .77 .2]);

ax3 = axes('Position', [.13 .48 .77 .2]);
set(ax3, 'FontSize', 16);

axes(ax3);
title('STD of successive diffs');
hold on;
axes(ax2);

vdat = reconstruct_image(mm);
wh = round(size(vdat, 1)./2);

plot(ax1, rmssd, 'k'); axis tight
axes(ax1), hold on; 
hh = plot_horizontal_line(mean(rmssd) + sdlim*std(rmssd));
set(hh, 'LineStyle', '--');

plot(ax3, spatsd, 'k'); axis tight
axes(ax3), hold on; 
hh = plot_horizontal_line(mean(spatsd) + sdlim*std(spatsd));
set(hh, 'LineStyle', '--');

axes(ax2);
imagesc(squeeze(vdat(wh, :, :))', mylim);
drawnow
hold off
colormap gray
for i = 1:size(sdiffs, 2)
    
    vh = plot(ax1, i, rmssd(i), 'ro', 'MarkerFaceColor', 'r');
    vh2 = plot(ax3, i, spatsd(i), 'ro', 'MarkerFaceColor', 'r');
    
    mm.dat = sdiffs(:, i);
    vdat = reconstruct_image(mm);
    imagesc(squeeze(vdat(wh, :, :))', mylim);
    axis image;
    set(ax2, 'YDir', 'Normal')
    xlabel('Successive differences (sagittal slice)');

    drawnow
    
    if writetofile
        F = getframe(fh);
        if i == 1
            imwrite(F.cdata, movieoutfile,'tiff', 'Description', dat.fullpath, 'Resolution', 30);
        else
            imwrite(F.cdata, movieoutfile,'tiff', 'WriteMode', 'append', 'Resolution', 30);
        end
        
    elseif slow(i)
        pause(1); 
    end
    
    delete(vh);
    delete(vh2);
end

end

