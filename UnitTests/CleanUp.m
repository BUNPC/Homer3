function CleanUp(standalone, start)
global DEBUG1
global procStreamStyle
global testidx;
global logger

% Close all guis
close all force

if ~exist('standalone','var') || isempty(standalone)
    standalone = true;
end
if ~exist('start','var') || isempty(start)
    start = true;
end

if ~standalone
    return
end

% Clear global variables
if start
    delete(logger)
    logger=[];
end
clear DEBUG1 testidx procStreamStyle

DEBUG1=[];
testidx=[];
procStreamStyle=[];

reg = RegistriesClass('empty');
reg.DeleteSaved();

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
fprintf('\n');

fclose all;

% Create or restore config file
c = ConfigFileClass();
if c.BackupExists()
    c.Restore()
else
    c.SetValue('Regression Test Active','true');
    c.SetValue('Include Archived User Functions','Yes');
    c.Save('backup');
end

if ~start
    logger.Close();
end


