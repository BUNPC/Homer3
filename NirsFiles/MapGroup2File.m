function iFile = MapGroup2File(files, iSubj, iRun)

iFile = 0;
for ii=1:length(files)
    if files(ii).map2group.iSubj==iSubj & files(ii).map2group.iRun==iRun
        iFile = ii;
        break;
    end
end

