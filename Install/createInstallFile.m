function createInstallFile(options)
global installfilename

installfilename = sprintf('%s_install', lower(getAppname()));
[~, exename] = getAppname();

setNamespace(exename)

if ~exist('options','var') || isempty(options)
    options = 'all';
end

% Find installation path and add it to matlab search paths
dirnameApp = getAppDir;
if isempty(dirnameApp)
    MessageBox('Cannot create installation package. Could not find root application folder.');
    deleteNamespace(exename)
    return;
end
dirnameInstall = filesepStandard(fileparts(which('createInstallFile.m')));
if isempty(dirnameInstall)
    MessageBox('Cannot create installation package. Could not find root installation folder.');
    deleteNamespace(exename)
    return;
end
addpath(dirnameInstall, '-end')
cd(dirnameInstall);

% Start with a clean slate
cleanup(dirnameInstall, dirnameApp, 'start');

% Set the executable names based on the platform type
platform = setplatformparams();

if exist([dirnameInstall, installfilename],'dir')
    rmdir_safe([dirnameInstall, installfilename]);
end
if exist([dirnameInstall, installfilename, '.zip'],'file')
    delete([dirnameInstall, installfilename, '.zip']);
end
mkdir([dirnameInstall, installfilename]);
mkdir([dirnameInstall, installfilename, '/FuncRegistry']);
mkdir([dirnameInstall, installfilename, '/FuncRegistry/UserFunctions']);
mkdir([dirnameInstall, installfilename, '/SubjDataSample']);

% Generate executables
if ~strcmp(options, 'nobuild')
	Buildme_Setup();
	Buildme();
    if islinux()
        perl('./makesetup.pl','./run_setup.sh','./setup.sh');
    elseif ismac()
        perl('./makesetup.pl','./run_setup.sh','./setup.command');
    end
end

dirnameDb2DotMat = findWaveletDb2([dirnameInstall, installfilename]);

% Copy files to installation package folder
for ii=1:length(platform.exename)
    if exist([dirnameInstall, platform.exename{ii}],'file')
        copyfile([dirnameInstall, platform.exename{ii}], [dirnameInstall, installfilename, '/', platform.exename{ii}]);
    end
end
if exist([dirnameInstall, platform.setup_script],'file')==2
    copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, installfilename]);
end
for ii=1:length(platform.setup_exe)
    if exist([dirnameInstall, platform.setup_exe{ii}],'file')
        if ispc()
            copyfile([dirnameInstall, platform.setup_exe{1}], [dirnameInstall, installfilename, '/installtemp']);
        else
            copyfile([dirnameInstall, platform.setup_exe{ii}], [dirnameInstall, installfilename, '/', platform.setup_exe{ii}]);
        end
    end
end

if exist([dirnameApp, 'SubjDataSample'],'dir')
    copyfile([dirnameApp, 'SubjDataSample'], [dirnameInstall, installfilename, '/SubjDataSample']);
end

for ii=1:length(platform.createshort_script)
    if exist([dirnameInstall, platform.createshort_script{ii}],'file')
        copyfile([dirnameInstall, platform.createshort_script{ii}], [dirnameInstall, installfilename]);
    end
end

if exist([dirnameApp, 'AppSettings.cfg'],'file')
    copyfile([dirnameApp, 'AppSettings.cfg'], [dirnameInstall, installfilename]);
end

if exist([dirnameDb2DotMat, 'db2.mat'],'file')
    copyfile([dirnameDb2DotMat, 'db2.mat'], [dirnameInstall, installfilename]);
end

if exist([dirnameInstall, 'makefinalapp.pl'],'file')
    copyfile([dirnameInstall, 'makefinalapp.pl'], [dirnameInstall, installfilename]);
end

if exist([dirnameInstall, 'generateDesktopPath.bat'],'file')
    copyfile([dirnameInstall, 'generateDesktopPath.bat'], [dirnameInstall, installfilename]);
end

if exist([dirnameApp, 'README.md'],'file')
    copyfile([dirnameApp, 'README.md'], [dirnameInstall, installfilename]);
end

if exist([dirnameApp, 'FuncRegistry/UserFunctions'],'dir')
    copyfile([dirnameApp, 'FuncRegistry/UserFunctions'], [dirnameInstall, installfilename, '/FuncRegistry/UserFunctions']);
end

if ispathvalid([dirnameInstall, 'uninstall.bat'])
    copyfile([dirnameInstall, 'uninstall.bat'], [dirnameInstall, installfilename, '/uninstall.bat']);
end

% Zip it all up into a single installation file
zip([dirnameInstall, installfilename, '.zip'], [dirnameInstall, installfilename]);

% Clean up 
deleteNamespace(exename)
fclose all;
cleanup(dirnameInstall, dirnameApp);


