function CleanUp(standalone, start)
global DEBUG1
global QUICK_TEST
global procStreamStyle
global testidx;
global logger

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
    logger = [];
    close all force
    fclose all;
    reg = RegistriesClass();
    reg.DeleteSaved();
end
clear DEBUG1 testidx procStreamStyle

DEBUG1 = [];
testidx = [];
procStreamStyle = [];
QUICK_TEST = [0,1];

groupFolders = FindUnitTestsFolders();
rootpath = filesepStandard(fileparts(which('Homer3.m')));

% Clean up after ourselves; delete non-versioned acquisition files and
% try to SVN revert all changes if project is under version control
if ~start
    fprintf('\n');
    for ii = 1:length(groupFolders)
        pname = filesepStandard([rootpath, groupFolders{ii}]);
        fprintf('   Deleting %s*.snirf files ...\n', pname);
        DeleteDataFiles(pname, '.snirf');
    end
    fprintf('\n');
end

fclose all;

% Create or restore config file
c = ConfigFileClass();
if c.BackupExists()
    c.Restore()
else
    c.Save('backup');
end

if ~start
    logger.Close();
end


