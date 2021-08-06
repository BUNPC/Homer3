function  Buildme()
platform = setplatformparams();

[~, appname] = fileparts(platform.exename{1});
currdir = filesepStandard(pwd);
dirnameInstall = filesepStandard(ffpath('Buildme.m'));
cd(dirnameInstall);

exclLst = {
    '.git';
    'Docs';
    'UnitTests'; ...
    'Install';
    'Data';
    'setpaths.m';
    'getpaths.m';
    };

Buildexe(appname, exclLst)
rootdir = filesepStandard(fileparts(which(platform.exename{1})));
for ii = 1:length(platform.exename)
    if exist([rootdir,  platform.exename{ii}],'file')
        movefile([rootdir,  platform.exename{ii}], dirnameInstall);
    end
end
if ispathvalid('./Buildme.log','file')
    if ~pathscompare('./', dirnameInstall)
        movefile('./Buildme.log', dirnameInstall);
    end
end
cd(currdir);

