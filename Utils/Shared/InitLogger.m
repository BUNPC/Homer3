function logger = InitLogger(logger, appname, options)
if ~exist('appname','var')
    appname = 'History';
end
if ~exist('options','var')
    options = [];
end
if ~exist('logger','var') || isempty(logger)
    logger = Logger(appname, options);
elseif ~logger.IsOpen()
    logger.Open();
    if ~logger.IsOpen()
        logger = Logger(appname, options);
    end
end
