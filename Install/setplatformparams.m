function platform = setplatformparams()

% Set the home directoty on linux and mac to full path so it can be
% displayed in full at setup time.
if ismac() || islinux()
    currdir = pwd;
    cd ~/;
    dirnameHome = [pwd, '/'];
    cd(currdir);
else
    dirnameHome = 'c:/users/public/';
end

platform = struct(...
    'arch','', ...
    'exename',{{}}, ...
    'exenameDesktopPath','', ...
    'setup_exe',{{}}, ...
    'setup_script','', ...
    'dirnameApp', getAppDir('isdeployed'), ...
    'mcrpath','', ...
    'desktopPath',generateDesktopPath() ...
    );

if ismac()
    platform.arch = 'Darwin';
    platform.exename{1} = 'Homer3.app';
    platform.exename{2} = 'run_Homer3.sh';
    platform.exenameDesktopPath = [platform.desktopPath, '/Homer3.command'];
    platform.setup_exe{1} = 'setup.app';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.command';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = [dirnameHome, 'libs/mcr'];
elseif islinux()
    platform.arch = 'Linux';
    platform.exename{1} = 'Homer3';
    platform.exename{2} = 'run_Homer3.sh';
    platform.exenameDesktopPath = [platform.desktopPath, '/', platform.exename{1}];
    platform.setup_exe{1} = 'setup';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.sh';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = [dirnameHome, 'libs/mcr'];
elseif ispc()
    platform.arch = 'Win';
    platform.exename{1} = 'Homer3.exe';
    platform.exenameDesktopPath = [platform.desktopPath, '/', platform.exename{1}, '.lnk'];
    platform.setup_exe{1} = 'setup.exe';
    platform.setup_exe{2} = 'installtemp';
    platform.setup_script = 'setup.bat';
    platform.createshort_script{1} = 'createShortcut.bat';
    platform.createshort_script{2} = 'createShortcut.vbs';
end


