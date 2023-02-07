function logger = PrintSystemInfo(logger, appname, varargin)
if ~exist('logger','var')
    logger = [];
end
if ~exist('appname','var') || isempty(appname)
    appname = {'Untitled'};
end

logger = InitLogger(logger, 'SystemInfo');
platform = ['R', version('-release')];

if ~iscell(appname)
    appnames = [appname; getLibnames(appname)];
else
    appnames = appname;
end

logger.Write('\n');
for ii = 1:length(appnames)
    if strcmp(appnames{ii}, 'Untitled')
        logger.Write('Running %s, %s\n', appnames{ii}, platform);
    else
        vstr = getVernum(appnames{ii});
        if ~isempty(find(vstr==':' | vstr=='-'))
            vs = sprintf('(Last Rev:  %s), ', vstr);
        elseif ~isempty(vstr)
            vs = sprintf('(v%s), ', vstr);
        else
            vs = '';
        end
        logger.Write('Running %s, %s %s\n', appnames{ii}, vs, platform);
    end
end
printArgs(varargin);

logger.Write('\n');
logger.Write('============\n');
logger.Write('SYSTEM INFO:\n');
logger.Write('============\n');
try
    systemview = [];
    if ispc()
        [~,systemview] = memory();
    end
    [hdSpaceAvail, hdSpaceTotal] = getFreeDiskSpace();

	logger.Write('Platform Arch  : %s\n', computer);
    if ~isempty(systemview)
        logger.Write('RAM Total      : %0.1f GB\n', systemview.PhysicalMemory.Total/1e9)
        logger.Write('RAM Free       : %0.1f GB\n', systemview.PhysicalMemory.Available/1e9)
    else
        logger.Write('RAM Total      : Not available on this platform\n')
        logger.Write('RAM Free       : Not available on this platform\n')
    end
	logger.Write('HD Space Total : %0.1f GB\n', hdSpaceTotal/1e9);
	logger.Write('HD Space Free  : %0.1f GB\n', hdSpaceAvail/1e9);
	logger.Write('\n') %#ok<*SPRINTFN>
catch ME
	logger.Write('%s\n', ME.message);
end



% --------------------------------------------------------------------
function libs = getLibnames(appname)
libs = {};
p = which(appname);
submodules = parseGitSubmodulesFile(fileparts(p));
for ii = 1:size(submodules,1)
    url             = submodules{ii,1};
    [~, libs{ii,1}] = fileparts(url);
end



% --------------------------------------------------------------------
function printArgs(args)
global logger

for ii = 1:length(args)
    if strcmp(args{ii}, 'userargs')
        break;
    end
    if ischar(args{ii})
        logger.Write('   arg %d:  ''%s''\n', ii, args{ii});
    elseif isnumeric(args{ii})
        logger.Write('   arg %d:  %s\n', ii, num2str(args{ii}));
    elseif iscell(args{ii})
        printArgs(args{ii});
    end
end





