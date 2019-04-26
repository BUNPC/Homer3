function resetGroupFolder(dirname, mode)

if ~exist('dirname','var') || isempty(dirname)
    dirname = [pwd,'/'];
end
if ~exist('mode','var') || isempty(mode)
    mode = 'registry_reset';
end
if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end

cfg = ConfigFileClass();
procStreamCfgFile = cfg.GetValue('Processing Stream Config File');
if exist([dirname, procStreamCfgFile],'file')
    delete([dirname, procStreamCfgFile]);
end

if strcmp(mode, 'registry_reset')
    reg = RegistriesClass('empty');
    reg.DeleteSaved();
end

