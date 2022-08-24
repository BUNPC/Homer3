function UnitTests_Init(standalone, start, appname)
global DEBUG1
global QUICK_TEST
global procStreamStyle
global testidx;
global logger
global cfg
global maingui
global SCRAMBLE
global ERROR_ODDS_CONST

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
    close all force
    fclose all;

    logger = Logger(appname);   
    logger.Write('**** SYSTEM TEST START:  %s ****\n\n', char(datetime(datetime, 'Format','MMMM d, yyyy, HH:mm:ss')));    
    cfg    = ConfigFileClass();
end
clear DEBUG1 testidx procStreamStyle

DEBUG1 = [];
testidx = [];
procStreamStyle = [];
QUICK_TEST = [0,0];

groupFolders = FindUnitTestsFolders();
if start
    reg = RegistriesClass();
    reg.DeleteSaved();
    
    SCRAMBLE         = true;
    ERROR_ODDS_CONST = generateErrorOddsConstant(0);    
end

% Clean up after ourselves; delete non-versioned acquisition files and
% try to SVN revert all changes if project is under version control
if ~start
    rootpath = filesepStandard(fileparts(which('Homer3.m')));
    logger.Write('\n');
    for ii = 1:length(groupFolders)
        pname = filesepStandard([rootpath, groupFolders{ii}]);
        logger.Write('Deleting *.snirf files in %s: \n', pname);
        DeleteDataFiles(pname, '.snirf');
    end
    logger.Write('\n\n');
end

% Create or restore config file
if cfg.BackupExists()
    cfg.Restore()
else
    cfg.Save('backup');
end

if ~start
    logger.Write('**** SYSTEM TEST END:  %s ****\n\n', char(datetime(datetime, 'Format','MMMM d, yyyy, HH:mm:ss')));
    logger.Close();
end


