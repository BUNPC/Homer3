function UnitTestsAll()

tic;

CleanUp();

rootpath = fileparts(which('Homer3.m'));
logger = LogClass([rootpath, '/UnitTests/'], 'UnitTestsAll');
UnitTestsAll_Nirs(false, logger);
UnitTestsAll_Snirf(false, logger);

logger.Close();
CleanUp();

toc
