function stringlist=alternativereadtabletext(filename)
fid = fopen(filename);
stringcell = textscan(fid, ...            
                '%s', ...
                'Delimiter', '\n', ...
                'CollectOutput', true);
for i=2:size(stringcell{1},1),
    row=textscan(stringcell{1}{i}, ...
                '%s', ...
                'Delimiter', ',', ...
                'CollectOutput', true);
    stringlist{i-1}=row{1}{1};
end
fclose(fid);