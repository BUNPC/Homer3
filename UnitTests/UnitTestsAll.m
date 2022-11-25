function UnitTestsAll()
global cfg

t1 = tic;

setNamespace('Homer3')

UnitTests_Init(true, true, 'UnitTestsAll');

cleanupObj = onCleanup(@()userInterrupt_Callback(true));

cfg.SetValue('Regression Test Active','true');
cfg.SetValue('Include Archived User Functions','Yes');
cfg.SetValue('Default Processing Stream Style','NIRS');
cfg.SetValue('Export Stim To TSV File','No');
cfg.SetValue('Quiet Mode','On');
cfg.Save();
% UnitTestsAll_Nirs(false);

cfg.SetValue('Default Processing Stream Style','SNIRF');
cfg.Save();
UnitTestsAll_Snirf(false);
UnitTestsAll_MainGUI(false)

toc(t1);



% ---------------------------------------------------
function userInterrupt_Callback(standalone)
fprintf('UnitTestsAll cleaning\n')
userInterrupt(standalone)


