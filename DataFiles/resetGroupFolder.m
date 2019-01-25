function resetGroupFolder(dirname)

fclose all;
if ~exist('dirname','var')
    dirname = [pwd,'/'];
end
if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end
if exist([dirname, 'processOpt_default.cfg'],'file')
    delete([dirname, 'processOpt_default.cfg']);
end
