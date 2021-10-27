function b = isIncompleteSubmodule(pname)
b = true;
if ~exist('pname','var')
    pname = pwd;
end
if ~ispathvalid_startup([pname, '.numberfiles'])
    return
end
nfiles = load([pname, '.numberfiles']);
files = findAllFiles(pname);
if nfiles ~= length(files)
    return;
end
b = false;
