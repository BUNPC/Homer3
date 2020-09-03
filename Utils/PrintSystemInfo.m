function PrintSystemInfo(logger)
if ~exist('logger','var')
    logger = [];
end
logger = InitLogger(logger, 'SystemInfo');

logger.Write(sprintf('Running Homer3 v%s\n\n', version2string()));

try
    % Sep 4, 2020: Removed because it's slowing down Homer3 startup 
% 	logger.Write(sprintf('=========\n'))
% 	logger.Write(sprintf('CPU Info:\n'))
% 	logger.Write(sprintf('=========\n'))
% 	pretty_print_struct(cpuinfo, [], [], logger);
% 	logger.Write(sprintf('\n'))
	
	[~,systemview] = memory();
	logger.Write(sprintf('====\n'))
	logger.Write(sprintf('RAM:\n'));
	logger.Write(sprintf('====\n'))
	logger.Write(sprintf('Total     : %0.1f GB\n', systemview.PhysicalMemory.Total/1e9))
	logger.Write(sprintf('Available : %0.1f GB\n', systemview.PhysicalMemory.Available/1e9))
	logger.Write(sprintf('\n'))
	
	%logger.Write(sprintf('Disk Space: '));
catch ME
	
end
