function CleanUp()
global DEBUG1
global procStreamStyle
global testidx;

% Clear global variables
DEBUG1=[];
testidx=[];
procStreamStyle=[];

groupFolders = FindUnitTestsFolders();
rootpath = fileparts(which('Homer3.m'));

% Clean up after ourselves; delete all non versioned files and 
% try to SVN revert all changes if project is under version control
fprintf('\n');
for ii=1:length(groupFolders)
    fprintf('Deleting %s\n', [rootpath, '/', groupFolders{ii}, '/groupResults.mat']);
    if exist([rootpath, '/', groupFolders{ii}, '/groupResults.mat'], 'file')
        delete([rootpath, '/', groupFolders{ii}, '/groupResults.mat']);
    end

    fprintf('Deleting %s\n', [rootpath, '/', groupFolders{ii}, '/*.snirf']);
    delete([rootpath, '/', groupFolders{ii}, '/*.snirf']);

    dirs = mydir([rootpath, '/', groupFolders{ii}, '/*']);
    for jj=1:length(dirs)
        if ~dirs(jj).isdir
            continue;
        end
        files = mydir([rootpath, '/', groupFolders{ii}, '/', dirs(jj).name, '/*.snirf']);
        if isempty(files)
            continue
        end
        fprintf('Deleting %s\n', [rootpath, '/', groupFolders{ii}, '/', dirs(jj).name, '/*.snirf']);
        delete([rootpath, '/', groupFolders{ii}, '/', dirs(jj).name, '/*.snirf']);
    end
end
