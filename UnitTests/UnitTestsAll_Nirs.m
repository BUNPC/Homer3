function status = UnitTestsAll_Nirs(standalone)
global DEBUG1
global procStreamStyle
global testidx;
global logger

t_local = tic;
DEBUG1=0;
testidx=0;
procStreamStyle = 'nirs';

if ~exist('standalone','var') || isempty(standalone)
    standalone = true;
    CleanUp();
    SetConfig();
end

logger = InitLogger(logger, 'UnitTestsAll_Nirs');

lpf = [00.30, 00.70, 01.00];
std = [05.00, 10.00, 15.00, 20.00];

groupFolders = FindUnitTestsFolders();
nGroups = length(groupFolders);
status = zeros(4, nGroups);
for ii=1:nGroups
    irow = 1;
    status(irow,ii) = unitTest_DefaultProcStream('.nirs',  groupFolders{ii});  irow=irow+1;
    status(irow,ii) = unitTest_DefaultProcStream('.snirf', groupFolders{ii});  irow=irow+1;
    for jj=1:length(lpf)
        status(irow,ii) = unitTest_BandpassFilt_LPF('.nirs',  groupFolders{ii}, lpf(jj));  irow=irow+1;
        status(irow,ii) = unitTest_BandpassFilt_LPF('.snirf', groupFolders{ii}, lpf(jj));  irow=irow+1;
    end
    for kk=1:length(std)
        status(irow,ii) = unitTest_MotionArtifact_STDEV('.nirs',  groupFolders{ii}, std(kk));  irow=irow+1;
        status(irow,ii)   = unitTest_MotionArtifact_STDEV('.snirf', groupFolders{ii}, std(kk));  irow=irow+1;
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

testidx=[];
procStreamStyle=[];

logger.Close();

% If we are NOT standalone then we'll rely on the parent caller to cleanup 
if standalone
    CleanUp();
    ResetConfig();
end

toc(t_local)

