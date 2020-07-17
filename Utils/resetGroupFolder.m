function resetGroupFolder(dirname, options)

if ~exist('dirname','var') || isempty(dirname)
    dirname = [pwd,'/'];
end
if ~exist('options','var') || isempty(options)
    options = 'registry_reset';
end

if exist([dirname, 'groupResults.mat'],'file')
    delete([dirname, 'groupResults.mat']);
end

if isempty(findstr(options, 'nodatatree')) %#ok<*FSTR>
    dataTree = DataTreeClass(dirname,'','','file');
    for iG = 1:length(dataTree.groups)
        dataTree.SetCurrElem(iG,0,0)
        dataTree.ResetCurrElem();
    end
end

cfg = ConfigFileClass();
procStreamCfgFile = cfg.GetValue('Processing Stream Config File');
if exist([dirname, procStreamCfgFile],'file')
    delete([dirname, procStreamCfgFile]);
end

if ~isempty(findstr(options, 'registry_reset'))
    reg = RegistriesClass('empty');
    reg.DeleteSaved();
end

