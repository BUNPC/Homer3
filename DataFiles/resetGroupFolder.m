function resetGroupFolder(dirname)

if ~exist('dirname','var')
    dirname = [pwd,'/'];
end
if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end
if exist([dirname, 'processOpt_default.cfg'],'file')
    delete([dirname, 'processOpt_default.cfg']);
end
files = NirsFilesClass().files;
dataTree = DataTreeClass(files);
dataTree.group.Reset();
dataTree.group.Save();

