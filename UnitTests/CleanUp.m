function CleanUp(standalone, start, appname)
global DEBUG1
global QUICK_TEST
global procStreamStyle
global testidx;
global logger
global cfg
global maingui

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
    maingui = [];
    delete(logger)
    delete(cfg)
    logger = [];
    cfg = [];
    close all force
    fclose all;
    reg = RegistriesClass();
    reg.DeleteSaved();
    logger = Logger(appname);
    cfg    = ConfigFileClass();
end
clear DEBUG1 testidx procStreamStyle

DEBUG1 = [];
testidx = [];
procStreamStyle = [];
QUICK_TEST = [0,0];

groupFolders = FindUnitTestsFolders();
rootpath = filesepStandard(fileparts(which('Homer3.m')));

% Clean up after ourselves; delete non-versioned acquisition files and
% try to SVN revert all changes if project is under version control
if ~start
    fprintf('\n');
    for ii = 1:length(groupFolders)
        pname = filesepStandard([rootpath, groupFolders{ii}]);
        fprintf('Deleting *.snirf files in %s: \n', pname);
        DeleteDataFiles(pname, '.snirf');
    end
    fprintf('\n\n');
end

fclose all;

% Create or restore config file
if cfg.BackupExists()
    cfg.Restore()
else
    cfg.Save('backup');
end

if ~start
    logger.Close();
end


