function Homer3(groupDirs, inputFileFormat)

%  Syntax:
%       Homer3(groupDirs, inputFileFormat)
%   
%  Examples:
%
%       Homer3({'.'}, '.snirf')
%       Homer3({'.'}, '.nirs')
%

global logger
logger = Logger('Homer3');

logger.CurrTime();

if ~exist('groupDirs','var') || isempty(groupDirs)
    groupDirs = filesepStandard(pwd);
end
if ~exist('inputFileFormat','var') || isempty(inputFileFormat)
    inputFileFormat = '.snirf';
end
cfg = ConfigFileClass();

if strcmp(cfg.GetValue('Logging'), 'off')
    logger.SetDebugLevel(logger.Null());
end

PrintSystemInfo(logger, 'Homer3');
checkForHomerUpdates();

logger.Write(sprintf('Opened application config file %s\n', cfg.filename))
gdir = cfg.GetValue('Last Group Folder');
if isempty(gdir)
    if isdeployed()
        groupDirs = {[getAppDir(), 'SubjDataSample']};
    end
end

try
    MainGUI(groupDirs, inputFileFormat, logger, 'userargs');
catch ME
    % Clean up in case of error make sure all open file handles are closed 
    % so we don't leave the application in a bad state
    logger.Close()
    rethrow(ME)
end

