function status = UnitTestsAll_Nirs(standalone)
global DEBUG1
global QUICK_TEST
global procStreamStyle
global testidx;
global logger

t1 = tic;

reg = RegistriesClass('reset');

if ~exist('standalone','var')
    standalone = true;
end

DEBUG1=0;
testidx=0;
procStreamStyle = 'nirs';

UnitTests_Init(standalone);
logger = InitLogger(logger, 'UnitTestsAll_Nirs');
logger.WriteNoNewline('################################################################');
logger.CurrTime('Starting UnitTestsAll_Nirs ...');

if standalone
    % System test runs for a long time. We want to be able to interrupt it with
    % Ctrl-C and have it automatically do the cleanup that the test would normally
    % do if it ran to completion
    cleanupObj = onCleanup(@()userInterrupt_Callback(standalone));
    configureAppSettings();
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
    status(testidx) = unitTest_DefaultProcStream('.nirs',  groupFolders{ii});
    if ~QUICK_TEST(2)
        for jj = 1:length(lpf)
            status(testidx) = unitTest_BandpassFilt_LPF('.nirs',  groupFolders{ii}, lpf(jj));
        end
        for kk = 1:length(std)
            status(testidx) = unitTest_MotionArtifact_STDEV('.nirs',  groupFolders{ii}, std(kk));
        end
    end    
end

reportResults(status);
toc(t1)
logger.Close('UnitTestsAll_Nirs');



% ---------------------------------------------------
function userInterrupt_Callback(standalone)
fprintf('UnitTestsAll_Nirs cleaning\n')
userInterrupt(standalone)



% ---------------------------------------------------
function configureAppSettings()
c.SetValue('Regression Test Active','true');
c.SetValue('Include Archived User Functions','Yes');
c.SetValue('Default Processing Stream Style','NIRS');
c.Save();
