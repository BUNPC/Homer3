function status = UnitTestsAll_Snirf(standalone, logger)
global DEBUG1
global procStreamStyle
global testidx;

tic;
DEBUG1=0;
testidx=0;
procStreamStyle = 'snirf';

if ~exist('standalone','var') || isempty(standalone)
    standalone = true;
end
if ~exist('logger','var') || isempty(logger)
    logger = LogClass();
end


groupFolders = FindUnitTestsFolders();
nGroups = length(groupFolders);
status = zeros(4, nGroups);
for ii=1:nGroups
    status(1,ii) = unitTest_DefaultProcStream('.snirf',groupFolders{ii}, logger); 
    status(2,ii) = unitTest_ModifiedLPF('.snirf', groupFolders{ii}, 0.30, logger);
    status(3,ii) = unitTest_ModifiedLPF('.snirf', groupFolders{ii}, 0.70, logger);
    status(4,ii) = unitTest_ModifiedLPF('.snirf', groupFolders{ii}, 1.00, logger);
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
    CleanUp();
end

toc
