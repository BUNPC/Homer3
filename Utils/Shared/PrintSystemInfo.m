function PrintSystemInfo(logger, appname)
if ~exist('logger','var')
    logger = [];
end
if ~exist('appname','var') || isempty(appname)
    appname = 'Untitled';
    vstr = '';
else
    vstr = version2string();
end

logger = InitLogger(logger, 'SystemInfo');
platform = ['R', version('-release')];

if isempty(vstr)
    logger.Write(sprintf('Running %s %s\n\n', appname, platform));
else
    logger.Write(sprintf('Running %s v%s, %s\n\n', appname, vstr, platform));
end

logger.Write(sprintf('============\n'))
logger.Write(sprintf('SYSTEM INFO:\n'));
logger.Write(sprintf('============\n'))
try
    systemview = [];
    if ispc()
        [~,systemview] = memory();
    end
    [hdSpaceAvail, hdSpaceTotal] = getFreeDiskSpace();

	logger.Write(sprintf('Platform Arch  : %s\n', computer));
    if ~isempty(systemview)
        logger.Write(sprintf('RAM Total      : %0.1f GB\n', systemview.PhysicalMemory.Total/1e9))
        logger.Write(sprintf('RAM Free       : %0.1f GB\n', systemview.PhysicalMemory.Available/1e9))
    else
        logger.Write(sprintf('RAM Total      : Not available on this platform\n'))
        logger.Write(sprintf('RAM Free       : Not available on this platform\n'))
    end
	logger.Write(sprintf('HD Space Total : %0.1f GB\n', hdSpaceTotal/1e9));
	logger.Write(sprintf('HD Space Free  : %0.1f GB\n', hdSpaceAvail/1e9));
	logger.Write(sprintf('\n')) %#ok<*SPRINTFN>
catch ME
	logger.Write(sprintf('%s\n', ME.message));
end

