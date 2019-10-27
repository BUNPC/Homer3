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
    'homer3_exe',{{}}, ...
    'setup_exe',{{}}, ...
    'setup_script','', ...
    'dirnameApp', getAppDir('isdeployed'), ...
    'mcrpath','' ...
    );

if ismac()
    platform.arch = 'Darwin';
    platform.homer3_exe{1} = 'Homer3.app';
    platform.homer3_exe{2} = 'run_Homer3.sh';
    platform.setup_exe{1} = 'setup.app';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.command';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = [dirnameHome, 'libs/mcr'];
elseif islinux()
    platform.arch = 'Linux';
    platform.homer3_exe{1} = 'Homer3';
    platform.homer3_exe{2} = 'run_Homer3.sh';
    platform.setup_exe{1} = 'setup';
    platform.setup_exe{2} = 'run_setup.sh';
    platform.setup_script = 'setup.sh';
    platform.createshort_script{1} = 'createShortcut.sh';
    platform.mcrpath = [dirnameHome, 'libs/mcr'];
elseif ispc()
    platform.arch = 'Win';
    platform.homer3_exe{1} = 'Homer3.exe';
    platform.setup_exe{1} = 'setup.exe';
    platform.setup_exe{2} = 'installtemp';
    platform.setup_script = 'setup.bat';
    platform.createshort_script{1} = 'createShortcut.bat';
    platform.createshort_script{2} = 'createShortcut.vbs';
end


