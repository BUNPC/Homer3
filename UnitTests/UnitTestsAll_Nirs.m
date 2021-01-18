function status = UnitTestsAll_Nirs(standalone)
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
procStreamStyle = 'nirs';

CleanUp(standalone);
logger = InitLogger(logger, 'UnitTestsAll_Nirs');

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
status = zeros(4, nGroups);
for ii=1:nGroups
    irow = 1;
    status(irow,ii) = unitTest_DefaultProcStream('.nirs',  groupFolders{ii});  irow=irow+1;
    
    if ~QUICK_TEST(2)
        for jj=1:length(lpf)
            status(irow,ii) = unitTest_BandpassFilt_LPF('.nirs',  groupFolders{ii}, lpf(jj));  irow=irow+1;
        end
        for kk=1:length(std)
            status(irow,ii) = unitTest_MotionArtifact_STDEV('.nirs',  groupFolders{ii}, std(kk));  irow=irow+1;
        end
    end
    
end
logger.Write('\n');

testidx = 0;
for ii=1:size(status,2)
    for jj=1:size(status,1)
        testidx=testidx+1;
        if status(jj,ii)~=0
            logger.Write(sprintf('#%d - Unit test %d,%d did NOT pass.\n', testidx, jj, ii));
        else
            logger.Write(sprintf('#%d - Unit test %d,%d passed.\n', testidx, jj, ii));
        end
    end
end
logger.Write('\n');

toc(t_local)

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
