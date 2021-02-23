function createInstallFile(options)

if ~exist('options','var') | isempty(options)
    options = 'all';
end

% Find installation path and add it to matlab search paths
dirnameApp = getAppDir;
if isempty(dirnameApp)
    MessageBox('Cannot create installation package. Could not find root application folder.');
    return;
end
dirnameInstall = filesepStandard(fileparts(which('createInstallFile.m')));
if isempty(dirnameInstall)
    MessageBox('Cannot create installation package. Could not find root installation folder.');
    return;
end
addpath(dirnameInstall, '-end')
cd(dirnameInstall);

% Start with a clean slate
cleanup(dirnameInstall, dirnameApp, 'start');

% Set the executable names based on the platform type
platform = setplatformparams();

if exist([dirnameInstall, 'homer3_install'],'dir')
    rmdir_safe([dirnameInstall, 'homer3_install']);
end
if exist([dirnameInstall, 'homer3_install.zip'],'file')
    delete([dirnameInstall, 'homer3_install.zip']);
end
mkdir([dirnameInstall, 'homer3_install']);
mkdir([dirnameInstall, 'homer3_install/FuncRegistry']);
mkdir([dirnameInstall, 'homer3_install/FuncRegistry/UserFunctions']);
mkdir([dirnameInstall, 'homer3_install/SubjDataSample']);

% Generate executables
if ~strcmp(options, 'nobuild')
	Buildme_Setup();
	Buildme_Homer3();
    if islinux()
        perl('./makesetup.pl','./run_setup.sh','./setup.sh');
    elseif ismac()
        perl('./makesetup.pl','./run_setup.sh','./setup.command');
    end
end

dirnameDb2DotMat = findWaveletDb2([dirnameInstall, 'homer3_install/']);

% Copy files to installation package folder
for ii=1:length(platform.exename)
    if exist([dirnameInstall, platform.exename{ii}],'file')
        copyfile([dirnameInstall, platform.exename{ii}], [dirnameInstall, 'homer3_install/', platform.exename{ii}]);
    end
end
if exist([dirnameInstall, platform.setup_script],'file')==2
    copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, 'homer3_install']);
    if ispc()
        copyfile([dirnameInstall, platform.setup_script], [dirnameInstall, 'homer3_install/Autorun.bat']);
    end
end
for ii=1:length(platform.setup_exe)
    if exist([dirnameInstall, platform.setup_exe{ii}],'file')
        if ispc()
            copyfile([dirnameInstall, platform.setup_exe{1}], [dirnameInstall, 'homer3_install/installtemp']);
        else
            copyfile([dirnameInstall, platform.setup_exe{ii}], [dirnameInstall, 'homer3_install/', platform.setup_exe{ii}]);
        end
	end
end

if exist([dirnameApp, 'SubjDataSample'],'dir')
    copyfile([dirnameApp, 'SubjDataSample'], [dirnameInstall, 'homer3_install/SubjDataSample']);
end

for ii=1:length(platform.createshort_script)
    if exist([dirnameInstall, platform.createshort_script{ii}],'file')
        copyfile([dirnameInstall, platform.createshort_script{ii}], [dirnameInstall, 'homer3_install']);
    end
end

if exist([dirnameApp, 'AppSettings.cfg'],'file')
    copyfile([dirnameApp, 'AppSettings.cfg'], [dirnameInstall, 'homer3_install']);
end

if exist([dirnameDb2DotMat, 'db2.mat'],'file')
    copyfile([dirnameDb2DotMat, 'db2.mat'], [dirnameInstall, 'homer3_install']);
end

if exist([dirnameInstall, 'makefinalapp.pl'],'file')
    copyfile([dirnameInstall, 'makefinalapp.pl'], [dirnameInstall, 'homer3_install']);
end

if exist([dirnameInstall, 'generateDesktopPath.bat'],'file')
    copyfile([dirnameInstall, 'generateDesktopPath.bat'], [dirnameInstall, 'homer3_install']);
end

if exist([dirnameApp, 'README.md'],'file')
    copyfile([dirnameApp, 'README.md'], [dirnameInstall, 'homer3_install']);
end

if exist([dirnameApp, 'FuncRegistry/UserFunctions'],'dir')
    copyfile([dirnameApp, 'FuncRegistry/UserFunctions'], [dirnameInstall, 'homer3_install/FuncRegistry/UserFunctions']);
end

% Zip it all up into a single installation file
zip([dirnameInstall, 'homer3_install.zip'], [dirnameInstall, 'homer3_install']);

% Clean up 
fclose all;
cleanup(dirnameInstall, dirnameApp);

