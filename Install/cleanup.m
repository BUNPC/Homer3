function cleanup(dirnameInstall, dirnameApp)

platform = setplatformparams();

if ~exist('dirnameApp','var') | isempty(dirnameApp)
    dirnameApp = ffpath('setpaths.m');
end
if dirnameApp(end)~='/' & dirnameApp(end)~='\'
    dirnameApp(end+1)='/';
end

if ~exist('dirnameInstall','var') | isempty(dirnameInstall)
    if exist('./Install','dir')
        dirnameInstall = [pwd, '/Install'];        
    else
        dirnameInstall = pwd;
    end
end
if dirnameInstall(end)~='/' & dirnameInstall(end)~='\'
    dirnameInstall(end+1)='/';
end

if exist([dirnameInstall, 'homer3_install'],'dir')
    rmdir_safe([dirnameInstall, 'homer3_install']);
end
for ii=1:length(platform.exename(1))
    if exist([dirnameInstall, platform.exename{ii}],'file')==2
        delete([dirnameInstall, platform.exename{ii}]);
    elseif exist([dirnameInstall, platform.exename{ii}],'dir')==7
        rmdir_safe([dirnameInstall, platform.exename{ii}]);
    end
end

for ii=1:length(platform.setup_exe)
    if exist([dirnameInstall, platform.setup_exe{ii}],'file')==2
        delete([dirnameInstall, platform.setup_exe{ii}]);
    elseif exist([dirnameInstall, platform.setup_exe{ii}],'dir')==7
        rmdir_safe([dirnameInstall, platform.setup_exe{ii}]);
    end
end
if exist([dirnameInstall, 'Buildme.log'],'file')
    delete([dirnameInstall, 'Buildme.log']);
end
if exist([dirnameApp, 'Buildme.log'],'file')
    delete([dirnameApp, 'Buildme.log']);
end
if exist([dirnameInstall, 'mccExcludedFiles.log'],'file')
    delete([dirnameInstall, 'mccExcludedFiles.log']);
end
if exist([dirnameApp, 'mccExcludedFiles.log'],'file')
    delete([dirnameApp, 'mccExcludedFiles.log']);
end

