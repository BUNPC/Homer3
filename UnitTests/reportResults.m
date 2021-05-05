function reportResults(status)
global logger
global testidx
global procStreamStyle

logger.Write('\n');

for iTest = 1:length(status)
    if status(iTest)~=0
        logger.Write(sprintf('Unit test #%d FAILED.\n', iTest));
    else
        logger.Write(sprintf('Unit test #%d PASSED.\n', iTest));
    end
end
logger.Write('\n');

testidx=[];
procStreamStyle=[];

