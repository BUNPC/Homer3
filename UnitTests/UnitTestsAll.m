function UnitTestsAll()
global logger

t_local = tic;

CleanUp(true);

cleanupObj = onCleanup(@()userInterrupt_Callback(true));

logger = Logger('UnitTestsAll');

c = ConfigFileClass();
c.SetValue('Regression Test Active','true');

c.SetValue('Include Archived User Functions','Yes');
c.SetValue('Default Processing Stream Style','NIRS');
c.Save();
% UnitTestsAll_Nirs(false);

c.SetValue('Default Processing Stream Style','SNIRF');
c.Save();
UnitTestsAll_Snirf(false);
UnitTestsAll_MainGUI(false)

toc(t_local);



% ---------------------------------------------------
function userInterrupt_Callback(standalone)
fprintf('UnitTestsAll cleaning\n')
userInterrupt(standalone)


