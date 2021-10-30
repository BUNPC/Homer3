function UnitTestsAll_MainGUI(standalone)
global logger 
global testidx
global procStreamStyle

t_local = tic;
testidx=0;
procStreamStyle = 'snirf';

if ~exist('standalone','var')
    standalone = true;
end

% Clean up before we start
CleanUp(standalone);
logger = InitLogger(logger, 'UnitTests_MainGUI');
logger.WriteNoNewline('################################################################');
logger.CurrTime('Starting UnitTests_MainGUI ...');

if standalone
    % System test runs for a long time. We want to be able to interrupt it with
    % Ctrl-C and have it automatically do the cleanup that the test would normally
    % do if it ran to completion
    cleanupObj = onCleanup(@()userInterrupt_Callback(standalone));
    configureAppSettings()
end

groupFolders = FindUnitTestsFolders();
nGroups = length(groupFolders);
nTestTypes = 1;
status = zeros(nTestTypes*nGroups, 1);
for ii = 1:nGroups
    [st, ut] = unitTest_MainGUI_GenerateHRF('.snirf', groupFolders{ii});
    status(testidx) = st;
end

reportResults(status);
toc(t_local);
logger.Close('UnitTests_MainGUI');
close(ut.handles.MainGUI);



% ---------------------------------------------------
function userInterrupt_Callback(standalone)
fprintf('UnitTestsAll cleaning\n')
userInterrupt(standalone)



% ---------------------------------------------------
function configureAppSettings()
global cfg
cfg.SetValue('Regression Test Active','true');
cfg.SetValue('Default Processing Stream Style','SNIRF');
cfg.Save();

