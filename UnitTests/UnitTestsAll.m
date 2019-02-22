function status = UnitTestsAll()
global DEBUG1
DEBUG1=0;

delete ./*.snirf

groupFolders = {'UnitTests/Example9_SessRuns', };
nGroups = length(groupFolders);
status = zeros(4, nGroups);
for ii=1:nGroups
    status(1,ii) = unitTest_DefaultProcStream('.nirs', groupFolders{ii});
    status(2,ii) = unitTest_DefaultProcStream('.snirf',groupFolders{ii});
    status(3,ii) = unitTest_ModifiedLPF('.nirs', groupFolders{ii}, 0.70);
    status(4,ii) = unitTest_ModifiedLPF('.snirf', groupFolders{ii}, 3.00);
end

for jj=1:size(status,1)
    for ii=1:size(status,2)
        if status(jj,ii)~=0
            fprintf('Unit test %d,%d did NOT pass.\n', jj,ii);
        else
            fprintf('Unit test %d,%d passed.\n', jj,ii);
        end
    end
end

