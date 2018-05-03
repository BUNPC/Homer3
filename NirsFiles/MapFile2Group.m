function file = MapFile2Group(file,iSubj,iRun)


file.map2group.iSubj = iSubj;
if ~file.isdir
    file.map2group.iRun  = iRun;
else
    file.map2group.iRun  = 0;
end


