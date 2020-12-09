function resetGroupFolder(dirname, options)

global maingui;
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
    maingui.dataTree = DataTreeClass(dirname,'','','files');
    for iG = 1:length(maingui.dataTree.groups)
        maingui.dataTree.SetCurrElem(iG,0,0)
        maingui.dataTree.ResetCurrElem();
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

