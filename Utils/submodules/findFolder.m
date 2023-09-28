function dirpath = findFolder(repo, dirname)
dirpath = '';
if ~exist('repo','var')
    repo = filesepStandard_startup(pwd);
end
dirpaths = findDotMFolders(repo, {'.git', '.idea'});

for ii = 1:length(dirpaths)
    [~, f, e] = fileparts(dirpaths{ii}(1:end-1));
    if strcmp(dirname, [f,e])
        dirpath = dirpaths{ii};
        break;
    end
    if ispathvalid_startup([dirname, dirpaths{ii}])
        dirpath = dirpaths{ii};
        break;
    end
end

