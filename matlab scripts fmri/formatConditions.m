function formatConditions(directory,unformmatedFileName,formattedFileName)
stim=open([directory unformmatedFileName '.mat']);
%disp([directory unformmatedFileName '_catNames.csv'])
T=alternativereadtable([directory unformmatedFileName '_catNames.csv']);%readtable([directory unformmatedFileName '_catNames.csv']);
for i=1:size(stim.ons,1),
    onsets{i}=stim.ons(i,1:stim.siz(i));
    durations{i}=stim.dur(i);
    names{i}=T.name{i};%T.nam{i};
end
save([directory formattedFileName '.mat'],'onsets','durations','names');
