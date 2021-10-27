function removeFolderContents(folder)
warning('off','MATLAB:RMDIR:RemovedFromPath')
if isemptyFolder(folder)
    return
end
o = dir(folder);
for ii = 1:length(o)
    if strcmp(o(ii).name,'.')
        continue
    end
    if strcmp(o(ii).name,'..')
        continue
    end
    try
        if o(ii).isdir
            rmdir([folder, '/', o(ii).name],'s')
        else
            delete([folder, '/', o(ii).name])
        end
    catch
    end
end
warning('on','MATLAB:RMDIR:RemovedFromPath')
