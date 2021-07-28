function  Buildme(targetname)
if nargin==0
    targetname = 'Homer3';
end

platform = setplatformparams();
currdir = pwd;
dirnameApp = ffpath('Homer3.m');
if exist(dirnameApp,'dir')
    cd(dirnameApp);
end

exclLst = { ...
    '.git'; ...
    'Docs'; ...
    'UnitTests'; ...
    'Install'; ...
    'setpaths.m'; ...
    'getpaths.m'; ...
    };

Buildexe(targetname, exclLst)
for ii=1:length(platform.exename)
    if exist(['./',  platform.exename{ii}],'file')
        movefile(['./',  platform.exename{ii}], currdir);
    end
end
if ispathvalid('./Buildme.log','file')
    movefile('./Buildme.log',currdir);
end
cd(currdir);

