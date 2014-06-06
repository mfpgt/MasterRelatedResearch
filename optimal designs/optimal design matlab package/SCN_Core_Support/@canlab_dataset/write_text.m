function [headername, dataname, fid] = write_text(D)
% 
% "Flatten" dataset and write text files with header and data
% For all Event-level data
%
% % Copyright Tor Wager, 2013


% Checks
% ----------------------------------------------------------------------
for i = 1:length(D.Subj_Level.names)
    
    if length(D.Subj_Level.descrip) < i
        D.Subj_Level.descrip{i} = 'No description provided';
    end
    
end

for i = 1:length(D.Event_Level.names)
    
    if length(D.Event_Level.descrip) < i
        D.Event_Level.descrip{i} = 'No description provided';
    end
    
end


% Open Files
% ----------------------------------------------------------------------
headername = [D.Description.Experiment_Name '_info_' scn_get_datetime];
dataname = [D.Description.Experiment_Name '_data_' scn_get_datetime];
fid = fopen(headername, 'w');


% Write Header
% ----------------------------------------------------------------------

u = '______________________________________________________________';

fprintf(fid, 'Experiment: %s\n', D.Description.Experiment_Name)

fprintf(fid, '\n%d subjects\n', length(D.Subj_Level.id))
fprintf(fid, 'Missing values coded with: %f\n', D.Description.Missing_Values)
fprintf(fid, '%s\n', u)

fprintf(fid, 'Subject Level\n\n')
fprintf(fid, 'Description:\n')

for i = 1:length(D.Description.Subj_Level)
    fprintf(fid, '\t%s\n', D.Description.Subj_Level{i});
end

fprintf(fid, 'Names:\n')
for i = 1:length(D.Subj_Level.names)
    fprintf(fid, '\t%s\t%s\n', D.Subj_Level.names{i}, D.Subj_Level.descrip{i});
end

fprintf(fid, '%s\n', u)

fprintf(fid, 'Event Level\n\n')
fprintf(fid, 'Description:\n')

for i = 1:length(D.Description.Event_Level)
    fprintf(fid, '\t%s\n', D.Description.Event_Level{i});
end

fprintf(fid, 'Names:\n')
for i = 1:length(D.Event_Level.names)
    fprintf(fid, '\t%s\t%s\n', D.Event_Level.names{i}, D.Event_Level.descrip{i});
end

fprintf(fid, '%s\n', u)

fclose(fid)

%% Write event-level data, tab-delimited
% -----------------------------------------------------------------------
fid = fopen(dataname, 'w');

names = {'ID' D.Subj_Level.names{:} 'Event_number' D.Event_Level.names{:}};

n = length(D.Subj_Level.id);

%slevels = length(D.Subj_Level.names);

printcell = @(x) fprintf(fid, '%s\t', x);
cellfun(printcell, names)
fprintf(fid, '\n');

for i = 1:n  % for each subject
    
    e = size(D.Event_Level.data{i}, 1);
    
    for j = 1:e  % for events within subject
        
        fprintf(fid, '%s\t', D.Subj_Level.id{i});  % ID
        
        datarow = [D.Subj_Level.data(i, :) j D.Event_Level.data{i}(j, :)];
        
        % Could switch by datatype in a better way here!!  need datatype codes in dataset.
        for k = 1:length(datarow)
            
            if datarow(k) == round(datarow(k))
                fprintf(fid, '%d\t', datarow(k));
                
            else
            
                fprintf(fid, '%3.3f\t', datarow(k));  
            
            end
            
        end % row
        
        fprintf(fid, '\n');
        
    end  % events
    
end  % subjects

fclose(fid)


end % function
