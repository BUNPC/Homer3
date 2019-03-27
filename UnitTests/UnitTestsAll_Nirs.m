function status = UnitTestsAll_Nirs(standalone, logger)
global DEBUG1
global procStreamStyle
global testidx;

tic;
DEBUG1=0;
testidx=0;
procStreamStyle = 'nirs';

if ~exist('standalone','var') || isempty(standalone)
    SetConfig();
    standalone = true;
end
if ~exist('logger','var') || isempty(logger)
    rootpath = fileparts(which('UnitTestsAll_Nirs.m'));
    logger = LogClass([rootpath, '/'], 'UnitTestsAll_Nirs');
end

lpf = [00.30, 00.70, 01.00];
std = [05.00, 10.00, 15.00, 20.00];

groupFolders = FindUnitTestsFolders();
nGroups = length(groupFolders);
status = zeros(4, nGroups);
for ii=1:nGroups
    status(1,ii) = unitTest_DefaultProcStream('.nirs',  groupFolders{ii}, logger); 
    status(2,ii) = unitTest_DefaultProcStream('.snirf', groupFolders{ii}, logger); 
    for jj=1:length(lpf)
        status(jj,ii)   = unitTest_BandpassFilt_LPF('.nirs',  groupFolders{ii}, lpf(jj), logger);
        status(jj+1,ii) = unitTest_BandpassFilt_LPF('.snirf', groupFolders{ii}, lpf(jj), logger);
    end
    for kk=1:length(std)
        status(kk+jj,  ii) = unitTest_MotionCorrect_STDEV('.nirs',  groupFolders{ii}, std(kk), logger);
        status(kk+1+jj,ii) = unitTest_MotionCorrect_STDEV('.snirf', groupFolders{ii}, std(kk), logger);
    end
end

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

testidx=[];
procStreamStyle=[];

% If we are NOT standalone then we'll rely on the parent caller to cleanup 
if standalone
    ResetConfig();
    CleanUp();
end
if strcmp(logger.GetFilename(), 'UnitTestsAll_Nirs')
    logger.Close();
end

toc

