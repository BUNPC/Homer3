function logger = InitLogger(logger, appname, options)
if ~exist('logger','var') || isempty(logger)
    if ~exist('appname','var')
        appname = '';
    end
    if ~exist('options','var')
        options = [];
    end
    logger = Logger(appname, options);
end
