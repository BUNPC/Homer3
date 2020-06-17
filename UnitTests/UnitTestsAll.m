function UnitTestsAll()
global logger

t_local = tic;

CleanUp();

c = ConfigFileClass();
c.SetValue('Regression Test Active','true');
c.SetValue('Include Archived User Functions','Yes');
c.SetValue('Default Processing Stream Style','NIRS');

logger = Logger('UnitTestsAll');

UnitTestsAll_Nirs(false);

c.SetValue('Default Processing Stream Style','SNIRF');
c.Save();

UnitTestsAll_Snirf(false);

logger.Close();

c.SetValue('Regression Test Active','false');
c.SetValue('Include Archived User Functions','No');

CleanUp();

toc(t_local);
