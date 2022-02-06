function groupFolders = FindUnitTestsFolders()

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
    kk = kk+1;
end
groupFolders(kk:end) = [];

