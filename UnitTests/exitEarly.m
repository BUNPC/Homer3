function status = exitEarly(msg, logger)

status = 3;
logger.Write(msg);
logger.Write('\n');
if strcmp(logger.GetFilename(), 'History')
    logger.Close();
end
