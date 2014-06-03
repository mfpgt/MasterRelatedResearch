function createMatlabConditionsFile(directory,unformatterFileName ,formattedFileName)
onsets=alternativereadtablenumbers([ unformatterFileName '_onsets.csv']);
durations=alternativereadtablenumbers([ unformatterFileName '_durations.csv']);
names=alternativereadtabletext([ unformatterFileName '_infotable.csv']);
save([directory formattedFileName '.mat'],'onsets','durations','names');