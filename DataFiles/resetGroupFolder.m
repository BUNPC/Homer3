function resetGroupFolder(dirname)

if ~exist('dirname','var')
    dirname = [pwd,'/'];
end

if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end

files = NirsFilesClass().files;
group = LoadNIRS2Group(files);
group.Reset();
group.Save();

