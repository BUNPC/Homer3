function resetGroupFolder(dirname, options)
global maingui
global cfg

if isempty(getNamespace())
    setNamespace('Homer3')
end

cfg = InitConfig(cfg);

if ~exist('dirname','var') || isempty(dirname)
    dirname = [pwd,'/'];
end
if ~exist('options','var') || isempty(options)
    options = 'registry_reset';
end

outputDir           = cfg.GetValue('Output Folder Name');
procStreamCfgFile   = cfg.GetValue('Processing Stream Config File');

if ispathvalid(outputDir,'dir')
    rmdir(outputDir, 's');
elseif isempty(findstr(options, 'nodatatree')) %#ok<*FSTR>
    maingui.dataTree = DataTreeClass(dirname, '', '', 'files');
    for iG = 1:length(maingui.dataTree.groups)
        maingui.dataTree.SetCurrElem(iG,0,0)
        maingui.dataTree.ResetCurrElem();
    end
end

if ispathvalid([dirname, procStreamCfgFile],'file')
    delete([dirname, procStreamCfgFile]);
end

if ~isempty(findstr(options, 'registry_reset'))
    reg = RegistriesClass('empty');
    reg.DeleteSaved();
end

