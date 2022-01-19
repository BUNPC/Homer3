function setpaths(options)

%
% USAGE:
%
%   setpaths
%   setpaths(1)
%   setpaths(0)
%
currdir = pwd;

try
    
    warning('off','MATLAB:rmpath:DirNotFound');
    
    appname = 'Homer3';
    
    % Parse arguments
    addremove = 1;
    if ~exist('options','var')
        options = '';
    elseif isnumeric(options)
        if options == 0
            addremove = 0;
        else
            options = '';
        end
    end
    
    % Add startup searchpath
    if exist([pwd, '/Utils/submodules'],'dir')
        %addpath([pwd, '/Utils'],'-end');
        addpath([pwd, '/Utils/submodules'],'-end');
    end
    
    % Create list of possible known similar apps that may conflic with current
    % app
    appNameExclList = {'Homer3','Homer2_UI','brainScape','ResolveCommonFunctions'};
    appNameInclList = {'AtlasViewerGUI'};
    exclSearchList  = {'.git','Data','Docs','*_install','*.app'};
    
    appThis         = filesepStandard_startup(pwd);
    appThisPaths    = findDotMFolders(appThis, exclSearchList);
    if addremove == 0
        if ~isempty(which('deleteNamespace.m'))
            deleteNamespace(appname);
        end
        removeSearchPaths(appThis);
        return;
    end
    
    appExclList = {};
    appInclList = {};
    
    % Find all root folders of apps to exclude from search paths
    for ii = 1:length(appNameExclList)
        foo = which([appNameExclList{ii}, '.m'],'-all');
        for jj = 1:length(foo)
            p = filesepStandard_startup(fileparts(foo{jj}));
            if pathscompare_startup(appThis, p)
                continue
            end
            fprintf('Exclude paths for %s\n', p);
            appExclList = [appExclList; p]; %#ok<AGROW>
        end
    end
    
    % Find all root folders of apps to include in search paths
    for ii = 1:length(appNameInclList)
        foo = which([appNameInclList{ii}, '.m'],'-all');
        for jj = 1:length(foo)
            if jj > 1
                p = filesepStandard_startup(fileparts(foo{jj}));
                appExclList = [appExclList; p]; %#ok<AGROW>
                fprintf('Exclude paths for %s\n', p);
            else
                p = filesepStandard_startup(fileparts(foo{jj}));
                appInclList = [appInclList; p]; %#ok<AGROW>
                fprintf('Include paths for %s\n', p);
            end
        end
    end
    
    % Remove all search paths for all other apps except for current one, to
    % make that we use only search from the current app for download shared
    % libraries (i.e, submodules).
    for ii = 1:length(appExclList)
        removeSearchPaths(appExclList{ii})
    end
    for ii = 1:length(appInclList)
        removeSearchPaths(appInclList{ii})
    end
    
    addSearchPaths(appThisPaths);
    
    % Download submodules
    status = downloadLibraries(options, appname);
    if status<0
        cd(currdir);
        fprintf('ERROR: Could not download shared libraries required by this application...\n')
        return;
    end
    
    if ~isempty(which('setNamespace.m'))
        setNamespace(appname);
    end
    
    % Add back all search paths for all other apps except for current app
    for ii = 1:length(appInclList)
        % This app's path has already been added
        if pathscompare_startup(appInclList{ii}, appThis)
            continue;
        end
        foo = findDotMFolders(appInclList{ii}, exclSearchList);
        addSearchPaths(foo);
    end
    
    if  ~isempty(which('setpaths_proprietary.m'))
        setpaths_proprietary(options);
    end
    
    warning('on','MATLAB:rmpath:DirNotFound');
    
catch ME
    
    cd(currdir);
    close all force;
    fclose all;
    rethrow(ME)
    
end

cd(currdir);


% ----------------------------------------------------
function status = downloadLibraries(options, appname)
status = 0;
nTries = 2;
h = waitbar(0,'Downloading shared libraries.');
for iTry = 1:nTries
    [cmds, errs, msgs] = downloadSharedLibs(options, appname); %#ok<ASGLU>
    if all(errs==0 | errs == -2)
        break
    end
end
close(h)
if all(errs==0)
    return
end
status = -1;


% ---------------------------------------------------
function setpermissions(appPath)
if isunix() || ismac()
    if ~isempty(strfind(appPath, '/bin')) %#ok<*STREMP>
        fprintf(sprintf('chmod 755 %s/*\n', appPath));
        files = dir([appPath, '/*']);
        if ~isempty(files)
            system(sprintf('chmod 755 %s/*', appPath));
        end
    end
end


% ----------------------------------------------------
function addSearchPaths(appPaths)
for kk = 1:length(appPaths)
    addpath(appPaths{kk}, '-end');
    setpermissions(appPaths{kk});
end
fprintf('ADDED search paths for app %s\n', appPaths{1});



% ----------------------------------------------------
function removeSearchPaths(app)
p = path;
if ispc()
    delimiter = ';';
elseif ismac() || isunix()
    delimiter = ':';
end
[~,appname] = fileparts(fileparts(app));
r = version('-release');
msg = sprintf('Removing search paths for %s ...', appname);
h = waitbar(0, msg);
p = str2cell_startup(p, delimiter);
for kk = 1:length(p)
    if mod(kk,100)==0
        waitbar(kk/length(p), h);
    end
    if ~isempty(strfind(lower(p{kk}), 'matlab')) && ~isempty(strfind(p{kk}, r))
        continue;
    end
    if ~isempty(strfind(filesepStandard_startup(p{kk}), app))
        rmpath(p{kk});
    end
end
close(h);
fprintf('REMOVED search paths for app %s\n', app);

