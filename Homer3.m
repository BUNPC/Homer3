function unitTest = Homer3(groupDirs, inputFileFormat, unitTest)

%  Syntax:
%       unitTest = Homer3(groupDirs, inputFileFormat)
%   
%  Examples:
%
%       Homer3({'.'}, '.snirf')
%       Homer3({'.'}, '.nirs')
%

global logger
global cfg

setNamespace('Homer3');

if ~exist('groupDirs','var') || isempty(groupDirs)
    groupDirs = pwd;
end
if ~exist('inputFileFormat','var') || isempty(inputFileFormat)
    inputFileFormat = '.snirf';
end
if ~exist('unitTest','var')
    unitTest = [];
end

if ~iscell(groupDirs)
    groupDirs = {groupDirs};
end
for ii = 1:length(groupDirs)
    groupDirs{ii} = filesepStandard(groupDirs{ii});
end

if isempty(unitTest)
    logger = Logger('Homer3');
elseif unitTest.IsEmpty()
    logger = InitLogger(logger, 'UnitTestsAll');
else
    return;
end

logger.CurrTime();
cfg = ConfigFileClass();
if strcmp(cfg.GetValue('Logging'), 'off')
    logger.SetDebugLevel(logger.Null());
end

PrintSystemInfo(logger, 'Homer3', getArgs(groupDirs, inputFileFormat, unitTest, nargin));
checkForHomerUpdates();
gdir = cfg.GetValue('Last Group Folder');
if isempty(gdir)
    if isdeployed()
        groupDirs = {[getAppDir(), 'SubjDataSample']};
    end
end

try
    unitTest = MainGUI(groupDirs, inputFileFormat, unitTest, 'userargs');    
catch ME
    % Clean up in case of error make sure all open file handles are closed 
    % so we don't leave the application in a bad state
    cfg.Close();
    printStack(ME);
    logger.Close();
    rethrow(ME);
end




% ------------------------------------------------------------------------
function args = getArgs(groupDirs, inputFileFormat, unitTest, nargin)
if nargin == 0
    args = {};
elseif nargin == 1
    args = {groupDirs};
elseif nargin == 2
    args = {groupDirs, inputFileFormat};
elseif nargin == 3
    args = {groupDirs, inputFileFormat, unitTest};
end
   

