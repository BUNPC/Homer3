function setup()
global h
global nSteps

[~, exename] = getAppname();

setNamespace(exename)

h = waitbar(0,'Installation Progress ...');

main();

% Check that everything was installed properly
r = finishInstallGUI(exename);

waitbar(nSteps/nSteps, h);
close(h);

cleanup();



% ------------------------------------------------------------
function main()
global h
global nSteps
global iStep
global platform

nSteps = 100;
iStep = 1;

[appname, exename] = getAppname();

if ismac()
    dirnameSrc = sprintf('~/Downloads/%s_install/', lower(appname));
else
	dirnameSrc = [pwd, '/'];
end
dirnameDst = getAppDir('isdeployed');

v = getVernum();
fprintf('=================================\n');
fprintf('Setup script for %s v%s.%s:\n', exename, v{1}, v{2});
fprintf('=================================\n\n');

fprintf('Platform params:\n');
fprintf('  arch: %s\n', platform.arch);
fprintf('  exename: %s\n', platform.exename{1});
fprintf('  setup_exe: %s\n', platform.setup_exe{1});
fprintf('  setup_script: %s\n', platform.setup_script);
fprintf('  dirnameApp: %s\n', platform.dirnameApp);
fprintf('  mcrpath: %s\n', platform.mcrpath);

deleteShortcuts();

pause(2);

% Create destination folders
try 
    mkdir(dirnameDst);
catch ME
    msg{1} = sprintf('Error: Could not create installation folder. It might be in use by other applications.\n');
    msg{2} = sprintf('Try closing and reopening file browsers or any other applications that might be using the\n');
    msg{3} = sprintf('installation folder and then retry installation.');
    menu([msg{:}], 'OK');
    close(h);
    rethrow(ME)
end

% Get full paths for source and destination directories
dirnameSrc = fullpath(dirnameSrc);
dirnameDst = fullpath(dirnameDst);

% Copy files from source folder to destination installation folder
for ii=1:length(platform.exename)
    copyFileToInstallation([dirnameSrc, platform.exename{ii}], [dirnameDst, platform.exename{ii}]);
end
copyFileToInstallation([dirnameSrc, 'db2.mat'],           dirnameDst);
copyFileToInstallation([dirnameSrc, 'AppSettings.cfg'],   dirnameDst);
copyFileToInstallation([dirnameSrc, 'FuncRegistry'],      [dirnameDst, 'FuncRegistry']);
copyFileToInstallation([dirnameSrc, 'SubjDataSample'], [dirnameDst, 'SubjDataSample']);

% Create desktop shortcuts to Homer3
createDesktopShortcuts(dirnameSrc, dirnameDst);

waitbar(iStep/nSteps, h); iStep = iStep+1;
pause(2);




% -----------------------------------------------------------------
function cleanup()
if ismac()
    rmdir_safe(sprintf('~/Desktop/%s_install/', lower(getAppname())));
    rmdir_safe('~/Downloads/%s_install/', lower(getAppname()));
end



% -------------------------------------------------------------------
function copyFileToInstallation(src, dst, type)
global h
global nSteps
global iStep

if ~exist('type', 'var')
    type = 'file';
end

try
    % If src is one of several possible filenames, then src to any one of
    % the existing files.
    if iscell(src)
        for ii=1:length(src)
            if ~isempty(dir(src{ii}))
                src = src{ii};
                break;
            end
        end
    end
    
    assert(logical(exist(src, type)));
    
    % Check if we need to untar the file 
    k = findstr(src,'.tar.gz'); %#ok<FSTR>
    if ~isempty(k)
        untar(src,fileparts(src));
        src = src(1:k-1);
    end
    
    % Copy file from source to destination folder
    fprintf('Copying %s to %s\n', src, dst);
    copyfile(src, dst);

    waitbar(iStep/nSteps, h); iStep = iStep+1;
    pause(1);
catch ME
    close(h);
    printStack();
    if iscell(src)
        src = src{1};
    end
    menu(sprintf('Error: Could not copy %s to installation folder.', src), 'OK');
    pause(5);
    rethrow(ME);
end




% --------------------------------------------------------------
function deleteShortcuts()
global platform

if exist(platform.exenameDesktopPath, 'file')
    try
        delete(platform.exenameDesktopPath);
    catch
    end
end
if exist([platform.desktopPath, '/Test'], 'dir')
    try
        rmdir([platform.desktopPath, '/Test'], 's');
    catch
    end
end



% ---------------------------------------------------------
function createDesktopShortcuts(dirnameSrc, dirnameDst)
[~, exename] = getAppname();
try
    if ispc()
        
        k = dirnameDst=='/';
        dirnameDst(k)='\';
        
        cmd = sprintf('call "%s\\createShortcut.bat" "%s" %s.exe', dirnameSrc(1:end-1), dirnameDst, exename);
        system(cmd);
        
        cmd = sprintf('call "%s\\createShortcut.bat" "%s" SubjDataSample', dirnameSrc(1:end-1), dirnameDst(1:end-1));
        system(cmd);
        
    elseif islinux()
        
        cmd = sprintf('sh %s/createShortcut.sh sh', dirnameSrc(1:end-1));        
        system(cmd);
        
    elseif ismac()
        
        cmd = sprintf('sh %s/createShortcut.sh command', dirnameSrc(1:end-1));
        system(cmd);
        
    end
catch
    msg{1} = sprintf('Error: Could not create %s shortcuts on Desktop. Exiting installation.', exename);
    menu([msg{:}], 'OK');
    return;    
end

