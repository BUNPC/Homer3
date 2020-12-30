function UnitTestsAll()
global logger

t_local = tic;

CleanUp(true);

cleanupObj = onCleanup(@()userInterrupt_Callback(true));

c = ConfigFileClass();
c.SetValue('Regression Test Active','true');
c.SetValue('Include Archived User Functions','Yes');
c.SetValue('Default Processing Stream Style','NIRS');

logger = Logger('UnitTestsAll');

UnitTestsAll_Nirs(false);

c.SetValue('Default Processing Stream Style','SNIRF');
c.Save();

UnitTestsAll_Snirf(false);

c.SetValue('Regression Test Active','false');
c.SetValue('Include Archived User Functions','No');

toc(t_local);

CleanUp()



% ---------------------------------------------------
function userInterrupt_Callback(standalone)
fprintf('UnitTestsAll cleaning\n')
userInterrupt(standalone)


