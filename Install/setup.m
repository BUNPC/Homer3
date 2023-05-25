function setup()
global h
global nSteps
global dirnameSrc
global dirnameDst

try
    
    currdir = filesepStandard(pwd);
        
    h = waitbar(0,'Installation Progress ...');
       
    [~, exename] = getAppname();
    setNamespace(exename)
    
    dirnameSrc = currdir;
    dirnameDst = getAppDir('isdeployed');

    cleanup();
    
    main();
    
    % Check that everything was installed properly
    finishInstallGUI(exename);
    
    waitbar(nSteps/nSteps, h);
    close(h);
    
catch ME
    
    printStack(ME)
    cd(currdir)
    if ishandles(h)
        close(h);
    end
    rethrow(ME)
        
end
cd(currdir)


    

% ------------------------------------------------------------
function main()
global h
global nSteps
global iStep
global platform
global logger
global dirnameSrc
global dirnameDst

nSteps = 100;
iStep = 1;

fprintf('dirnameSrc = %s\n', dirnameSrc)
fprintf('dirnameDst = %s\n', dirnameDst)

logger = Logger([dirnameSrc, 'Setup']);

[~, exename] = getAppname();

v = getVernum(exename);
logger.Write('==========================================\n');
logger.Write('Setup script for %s v%s:\n', exename, v);
logger.Write('==========================================\n\n');

logger.Write('Platform params:\n');
logger.Write('  arch: %s\n', platform.arch);
logger.Write('  exename: %s\n', platform.exename{1});
logger.Write('  setup_exe: %s\n', platform.setup_exe{1});
logger.Write('  setup_script: %s\n', platform.setup_script);
logger.Write('  dirnameApp: %s\n', platform.dirnameApp);
logger.Write('  mcrpath: %s\n', platform.mcrpath);

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
for ii = 1:length(platform.exename)
    copyFile([dirnameSrc, platform.exename{ii}], [dirnameDst, platform.exename{ii}]);
end
copyFile([dirnameSrc, 'db2.mat'],           dirnameDst);
copyFile([dirnameSrc, 'AppSettings.cfg'],   dirnameDst);
copyFile([dirnameSrc, 'DataTree'],          [dirnameDst, 'DataTree']);
copyFile([dirnameSrc, 'FuncRegistry'],      [dirnameDst, 'FuncRegistry']);
copyFile([dirnameSrc, 'SubjDataSample'],    [dirnameDst, 'SubjDataSample']);
copyFile([dirnameSrc, 'SDGcolors.csv'],     dirnameDst);
copyFile([dirnameSrc, 'Version.txt'],     dirnameDst);
copyFile([dirnameSrc, 'LastCheckForUpdates.dat'],     dirnameDst);

% Create desktop shortcuts to Homer3
createDesktopShortcuts(dirnameSrc, dirnameDst);

waitbar(iStep/nSteps, h); iStep = iStep+1;
pause(2);




% -----------------------------------------------------------------
function err = cleanup()
global dirnameSrc
global dirnameDst
global logger 

err = 0;

logger = [];

% Uninstall old installation
try
    if exist(dirnameDst,'dir')
        rmdir(dirnameDst, 's');
    end
catch ME
    printStack(ME);
    msg{1} = sprintf('Error: Could not remove old installation folder %s. It might be in use by other applications.\n', dirnameDst);
    msg{2} = sprintf('Try closing and reopening file browsers or any other applications that might be using the\n');
    msg{3} = sprintf('installation folder and then retry installation.');
    MenuBox(msg, 'OK');
    pause(5);
    rethrow(ME)
end

% Change source dir if not on PC
if ~ispc()
    dirnameSrc0 = dirnameSrc;
    dirnameSrc = sprintf('%sDownloads/%s_install/', homePageFullPath(), lower(getAppname));
    fprintf('SETUP:    current folder is %s\n', pwd);   
    
    if ~isdeployed()
        rmdir_safe(sprintf('%sDesktop/%s_install/', homePageFullPath(), lower(getAppname())));
        if ~pathscompare(dirnameSrc, dirnameSrc0)
            rmdir_safe(dirnameSrc);            
            if ispathvalid(dirnameSrc)
                err = -1;
            end
            copyFile(dirnameSrc0, dirnameSrc);
        end
        rmdir_safe(sprintf('%sDesktop/Test/', homePageFullPath()));
        
        if ispathvalid(sprintf('%sDesktop/%s_install/', homePageFullPath()))
            err = -1;
        end
        if ispathvalid(sprintf('%sDesktop/Test/', homePageFullPath()))
            err = -1;
        end
        cd(dirnameSrc);
    end
end





% -------------------------------------------------------------------
function copyFile(src, dst, type)
global h
global nSteps
global iStep
global logger

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
    
    logmsg = sprintf('Copying %s to %s\n', src, dst);
    if isempty(logger)
        fprintf(logmsg);
    else
        logger.Write(logmsg);
    end
    copyfile(src, dst);

    if ~isempty(iStep)
        waitbar(iStep/nSteps, h); iStep = iStep+1;
    end
    pause(1);
catch ME
    if ishandles(h)
        close(h);
    end
    printStack(ME);
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
catch ME
    msg{1} = sprintf('Error: Could not create %s shortcuts on Desktop. Exiting installation.', exename);
    MenuBox(msg, 'OK');
    printStack(ME)
    return;    
end




