function b = isemptyFolder(pname)
b = [];
if ~ispathvalid_startup(pname, 'dir')
    b = true;
    mkdir(pname)
    return;
end

dirs0 = dir([pname, '/*']);
n = 0;
for ii = 1:length(dirs0)
    if strcmp(dirs0(ii).name, '.')
        continue;
    end
    if strcmp(dirs0(ii).name, '..')
        continue;
    end
    n = n+1;
end
b = n==0;
