function Buildme_Homer3(dirnameApp)

platform = setplatformparams();

if ~exist('dirnameApp','var') | isempty(dirnameApp)
    dirnameApp = ffpath('setpaths.m');
    if exist('./Install','dir')
        cd('./Install');
    end
end
if dirnameApp(end)~='/' & dirnameApp(end)~='\'
    dirnameApp(end+1)='/';
end

dirnameInstall = pwd;
cd(dirnameApp);

Buildme('Homer3', {}, {'.git'});
for ii=1:length(platform.exename)
    if exist(['./',  platform.exename{ii}],'file')
        movefile(['./',  platform.exename{ii}], dirnameInstall);
    end
end

cd(dirnameInstall);
