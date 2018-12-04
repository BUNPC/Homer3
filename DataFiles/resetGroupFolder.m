function resetGroupFolder(dirname)

if ~exist('dirname','var')
    dirname = [pwd,'/'];
end

if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end

files = NirsFilesClass().files;
dataTree = DataTreeClass(files);
dataTree.group.Reset();
dataTree.group.Save();

