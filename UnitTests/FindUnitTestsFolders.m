function groupFolders = FindUnitTestsFolders()

% Find all the group data folders with processOpt_default_homer2.cfg
% Those are the folders that can be unit tested

rootpath = fileparts(which('Homer3.m'));
dirs = mydir([rootpath, '/UnitTests/*']);
groupFolders = cell(length(dirs),1);
kk=1;
for ii=1:length(dirs)
    if ~dirs(ii).isdir
        continue;
    end
    pathfull = [rootpath, '/UnitTests/', dirs(ii).name];
    if ~exist([pathfull, '/groupResults_homer2_lpf_0_30.mat'], 'file')
        continue;
    end    
    [~, pathrel] = fileparts(pathfull);
    groupFolders{kk} = ['UnitTests/', pathrel];
    kk=kk+1;
end
groupFolders(kk:end) = [];

