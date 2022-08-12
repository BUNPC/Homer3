function status = UnitTestsAll_Snirf(standalone)
global DEBUG1
global QUICK_TEST
global procStreamStyle
global testidx;
global logger

t_local = tic;

if ~exist('standalone','var')
    standalone = true;
end

DEBUG1=0;
testidx=0;
procStreamStyle = 'snirf';

% Clean up before we start
UnitTests_Init(standalone, true, 'UnitTestsAll_Snirf');
logger.WriteNoNewline('################################################################');
logger.CurrTime('Starting UnitTestsAll_Snirf ...');

if standalone
    % System test runs for a long time. We want to be able to interrupt it with
    % Ctrl-C and have it automatically do the cleanup that the test would normally
    % do if it ran to completion
    cleanupObj = onCleanup(@()userInterrupt_Callback(standalone));
    configureAppSettings()
end

[lpf, std] = getUserOptionsVals();

groupFolders = FindUnitTestsFolders();
nGroups = length(groupFolders);
if ~QUICK_TEST(2)
    nTestTypes = 3;
else
    nTestTypes = 1;
end
status = zeros(nTestTypes*nGroups, 1);
for ii = 1:nGroups
    status(testidx) = unitTest_DefaultProcStream('.snirf', groupFolders{ii});
    if ~QUICK_TEST(2)
        for jj = 1:length(lpf)
            status(testidx) = unitTest_BandpassFilt_LPF('.snirf', groupFolders{ii}, lpf(jj));
        end
        for kk = 1:length(std)
            status(testidx) = unitTest_MotionArtifact_STDEV('.snirf', groupFolders{ii}, std(kk));
        end
    end
end

reportResults(status);
toc(t_local);
logger.Close('UnitTestsAll_Snirf');



% ---------------------------------------------------
function userInterrupt_Callback(standalone)
fprintf('UnitTestsAll_Snirf cleaning\n')
userInterrupt(standalone)



% ---------------------------------------------------
function configureAppSettings()
global cfg
cfg.SetValue('Regression Test Active','true');
cfg.SetValue('Default Processing Stream Style','SNIRF');
cfg.Save();
