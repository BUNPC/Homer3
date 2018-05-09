function resetGroupFolder(dirname)

if ~exist('dirname','var')
    dirname = [pwd,'/'];
end

if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end

files = dir([dirname, '*.nirs']);
for ii=1:length(files)
    ResetRun(files(ii));
end

