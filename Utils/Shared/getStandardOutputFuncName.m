function printFuncName = getStandardOutputFuncName()
global logger

if isempty(logger)
    printFuncName = 'fprintf';
elseif isa(logger, 'Logger')
    if ~logger.IsOpen()
        logger.Open();
    end
    if ~logger.IsOpen()
        printFuncName = 'fprintf';
    else
        printFuncName = 'logger.Write';
    end
else
    printFuncName = 'logger.Write';
end