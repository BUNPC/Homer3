function status = UnitTestsAll_Nirs()
global DEBUG1
global procStreamStyle
global testidx;
DEBUG1=0;
testidx = 0;

procStreamStyle = 'nirs';

tic;
delete ./*.snirf
delete */*.snirf
groupFolders = {'UnitTests/Example9_SessRuns', 'UnitTests/Example6_GrpTap'};
nGroups = length(groupFolders);
status = zeros(4, nGroups);
for ii=1:nGroups
    status(1,ii) = unitTest_DefaultProcStream('.nirs', groupFolders{ii}); 
    status(2,ii) = unitTest_DefaultProcStream('.snirf',groupFolders{ii}); 
    status(3,ii) = unitTest_ModifiedLPF('.nirs', groupFolders{ii}, 0.30); 
    status(4,ii) = unitTest_ModifiedLPF('.snirf', groupFolders{ii}, 0.30);
    status(5,ii) = unitTest_ModifiedLPF('.nirs', groupFolders{ii}, 0.70); 
    status(6,ii) = unitTest_ModifiedLPF('.snirf', groupFolders{ii}, 0.70);
    status(7,ii) = unitTest_ModifiedLPF('.nirs', groupFolders{ii}, 1.00);
    status(8,ii) = unitTest_ModifiedLPF('.snirf', groupFolders{ii}, 1.00);
end

testidx = 0;
for ii=1:size(status,2)
    for jj=1:size(status,1)
        testidx=testidx+1;
        if status(jj,ii)~=0
            fprintf('#%d - Unit test %d,%d did NOT pass.\n', testidx, jj, ii);
        else
            fprintf('#%d - Unit test %d,%d passed.\n', testidx, jj, ii);
        end
    end
end

testidx=[];
procStreamStyle=[];

toc

