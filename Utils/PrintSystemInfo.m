function PrintSystemInfo(logger, appname)
if ~exist('logger','var')
    logger = [];
end

logger = InitLogger(logger, 'SystemInfo');

logger.Write(sprintf('Running %s v%s\n\n', appname, version2string()));

logger.Write(sprintf('============\n'))
logger.Write(sprintf('SYSTEM INFO:\n'));
logger.Write(sprintf('============\n'))
try
	[~,systemview] = memory();
    [hdSpaceAvail, hdSpaceTotal] = getFreeDiskSpace();

	logger.Write(sprintf('Platform Arch  : %s\n', computer));
	logger.Write(sprintf('RAM Total      : %0.1f GB\n', systemview.PhysicalMemory.Total/1e9))
	logger.Write(sprintf('RAM Free       : %0.1f GB\n', systemview.PhysicalMemory.Available/1e9))
	logger.Write(sprintf('HD Space Total : %0.1f GB\n', hdSpaceAvail/1e9));
	logger.Write(sprintf('HD Space Free  : %0.1f GB\n', hdSpaceTotal/1e9));
	logger.Write(sprintf('\n'))
catch ME
	logger.Write(sprintf('%s\n', ME.message));
end
