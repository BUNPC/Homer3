function cleanup(dirnameInstall, dirnameApp, options)
global platform

installfilename = sprintf('%s_install', lower(getAppname()));

if ~exist('dirnameInstall','var') || isempty(dirnameInstall)
    if exist('./Install','dir')
        dirnameInstall = filesepStandard([pwd, '/Install']);
    else
        dirnameInstall = filesepStandard(pwd);
    end
end
if ~exist('dirnameApp','var') || isempty(dirnameApp)
    dirnameApp = getAppDir();
end
if ~exist('options','var')
    options = 'end';
end


if exist([dirnameInstall, installfilename],'dir')
    rmdir_safe([dirnameInstall, installfilename]);
end
for ii = 1:length(platform.exename)
    if exist([dirnameInstall, platform.exename{ii}],'file')==2
        delete([dirnameInstall, platform.exename{ii}]);
    elseif exist([dirnameInstall, platform.exename{ii}],'dir')==7
        rmdir_safe([dirnameInstall, platform.exename{ii}]);
    end
end
if ispathvalid([dirnameApp, 'requiredMCRProducts.txt'])
    delete([dirnameApp, 'requiredMCRProducts.txt']);
end
if ispathvalid([dirnameInstall, 'requiredMCRProducts.txt'])
    delete([dirnameInstall, 'requiredMCRProducts.txt']);
end
if ispathvalid([dirnameInstall, 'desktopPath.txt'])
    delete([dirnameInstall, 'desktopPath.txt']);
end

for ii=1:length(platform.setup_exe)
    if exist([dirnameInstall, platform.setup_exe{ii}],'file')==2
        delete([dirnameInstall, platform.setup_exe{ii}]);
    elseif exist([dirnameInstall, platform.setup_exe{ii}],'dir')==7
        rmdir_safe([dirnameInstall, platform.setup_exe{ii}]);
    end
end
if optionExists(options,'start')
    if exist([dirnameInstall, 'Buildme.log'],'file')
        delete([dirnameInstall, 'Buildme.log']);
    end
    if exist([dirnameApp, 'Buildme_Setup.log'],'file')
        delete([dirnameApp, 'Buildme_Setup.log']);
    end
end
if exist([dirnameInstall, 'mccExcludedFiles.log'],'file')
    delete([dirnameInstall, 'mccExcludedFiles.log']);
end
if exist([dirnameApp, 'mccExcludedFiles.log'],'file')
    delete([dirnameApp, 'mccExcludedFiles.log']);
end

