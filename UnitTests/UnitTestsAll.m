function UnitTestsAll()

tic;

CleanUp();

rootpath = fileparts(which('UnitTestsAll.m'));
logger = LogClass([rootpath, '/'], 'UnitTestsAll');
UnitTestsAll_Nirs(false, logger);
UnitTestsAll_Snirf(false, logger);

logger.Close();
CleanUp();

toc
