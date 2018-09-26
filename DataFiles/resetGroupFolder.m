function resetGroupFolder(dirname)

if ~exist('dirname','var')
    dirname = [pwd,'/'];
end

if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end

files = findNIRSDataSet();
for ii=1:length(files)
    if files(ii).isdir
        continue;
    end
    ResetRun(files(ii));
end

