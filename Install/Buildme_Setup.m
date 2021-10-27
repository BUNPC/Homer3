function Buildme_Setup(dirnameInstall)
currdir = pwd;
if ~exist('dirnameInstall','var') | isempty(dirnameInstall)
    dirnameInstall = ffpath('Buildme.m');
end
if exist(dirnameInstall,'dir')
    cd(dirnameInstall);
end

p = filesepStandard(fileparts(which(getNamespace())));
inclList = {
    [p, 'Utils/Shared/Logger.m'];
    [p, 'Utils/Shared/str2cell.m'];
    [p, 'Utils/Shared/printStack.m'];
    [p, 'Utils/Shared/pathscompare.m'];
    [p, 'Utils/Shared/parseOptions.m'];
    [p, 'Utils/Shared/optionExists.m'];
    [p, 'Utils/Shared/fullpath.m'];
    [p, 'Utils/Shared/filesepStandard.m'];
    };

Buildexe('setup', {}, inclList);
if ispathvalid([dirnameInstall, 'Buildme.log'])
    movefile([dirnameInstall, 'Buildme.log'], [dirnameInstall, 'Buildme_Setup.log'])
end
cd(currdir);
