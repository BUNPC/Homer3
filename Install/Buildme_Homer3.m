function Buildme_Homer3(dirnameApp)
platform = setplatformparams();
currdir = pwd;
if ~exist('dirnameApp','var') | isempty(dirnameApp)
    dirnameApp = ffpath('Homer3.m');
end
if exist(dirnameApp,'dir')
    cd(dirnameApp);
end
Buildme('Homer3', {}, {'.git','setpaths.m','getpaths.m'});
for ii=1:length(platform.exename)
    if exist(['./',  platform.exename{ii}],'file')
        movefile(['./',  platform.exename{ii}], currdir);
    end
end
if ispathvalid('./Buildme.log','file')
    movefile('./Buildme.log',currdir);
end
cd(currdir);