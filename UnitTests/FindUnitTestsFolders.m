function groupFolders = FindUnitTestsFolders()
global logger
global SCRAMBLE

logger = InitLogger(logger);

% Find all the group data folders with processOpt_default_homer2.cfg
% Those are the folders that can be unit tested

rootpath = filesepStandard(fileparts(which('Homer3.m')));
dirs = mydir([rootpath, 'UnitTests/'], rootpath);
groupFolders = cell(length(dirs),1);
kk = 1;
for ii = 1:length(dirs)
    if ~dirs(ii).isdir
        continue;
    end
    pathfull = [rootpath, dirs(ii).name];
    if ~exist([pathfull, '/groupResults_homer2_lpf_0_30.mat'], 'file')
        continue;
    end    
    groupFolders{kk} = dirs(ii).name;
    logger.Write('Found unit test folder %s\n', pathfull);
    
    if SCRAMBLE
        ScrambleChannelsForGroup(pathfull);
    end
    kk = kk+1;
end
groupFolders(kk:end) = [];

logger.Write('\n');

