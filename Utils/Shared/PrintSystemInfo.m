function PrintSystemInfo(logger, appnames)
if ~exist('logger','var')
    logger = [];
end
if ~exist('appnames','var') || isempty(appnames)
    appnames = {'Untitled'};
end

logger = InitLogger(logger, 'SystemInfo');
platform = ['R', version('-release')];

for ii = 1:length(appnames)
    if strcmp(appnames{ii}, 'Untitled')
        logger.Write('Running %s, %s\n', appnames{ii}, platform);
    else
        logger.Write('Running %s, (v%s), %s\n', appnames{ii}, getVernum(appnames{ii}), platform);
    end
end
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

