function UnitTestsAll()

tic;

CleanUp();
c = ConfigFileClass();

c.SetValue('Regression Test Active','true');
c.SetValue('Include Archived User Functions','Yes');
c.WriteFile();


rootpath = fileparts(which('UnitTestsAll.m'));
logger = LogClass([rootpath, '/'], 'UnitTestsAll');
UnitTestsAll_Nirs(false, logger);
UnitTestsAll_Snirf(false, logger);

logger.Close();

c.SetValue('Regression Test Active','false');
c.SetValue('Include Archived User Functions','No');
c.WriteFile();

CleanUp();

toc
