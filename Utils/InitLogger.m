function logger = InitLogger(logger, appname, options)
if ~exist('appname','var')
    appname = '';
end
if ~exist('options','var')
    options = [];
end
if ~exist('logger','var') || isempty(logger)
    logger = Logger(appname, options);
end
