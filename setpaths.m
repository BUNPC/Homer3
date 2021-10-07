function setpaths(options)

%
% USAGE:
%
%   setpaths
%   setpaths(1)
%   setpaths(0)
%   setpaths(options)
%
% DESCRIPTION:
%
%   Sets all the paths needed by a tool
%

warning('off','MATLAB:rmpath:DirNotFound');

% Parse arguments
addremove = 1;
if ~exist('options','var')
    options = 'init';
elseif isnumeric(options)
    if options == 0
        addremove = 0;
    else
        options = 'init';
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
exclSearchList  = {'.git','Data','Docs'};

appThis         = filesepStandard_startup(pwd);
appThisPaths    = findDotMFolders(appThis, exclSearchList);
if addremove == 0
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
        appExclList = [appExclList; p];
    end
end

% Find all root folders of apps to include in search paths
for ii = 1:length(appNameInclList)
    foo = which([appNameInclList{ii}, '.m'],'-all');
    for jj = 1:length(foo)
        if jj > 1
            p = filesepStandard_startup(fileparts(foo{jj}));
            appExclList = [appExclList; p];
            fprintf('Exclude paths for %s\n', p);
        else
            p = filesepStandard_startup(fileparts(foo{jj}));
            appInclList = [appInclList; p];
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
status = downloadLibraries(options);
if status<0
    fprintf('ERROR: Could not download shared libraries required by this application...\n')
    return;
end
setNamespace('Homer3');


% Add back all search paths for all other apps except for current app
for ii = 1:length(appInclList)
    foo = findDotMFolders(appInclList{ii}, exclSearchList);
    addSearchPaths(foo);
end

if exist([pwd, '/Utils/Shared/setpaths_proprietary.m'],'file')
    setpaths_proprietary(options);
end

warning('on','MATLAB:rmpath:DirNotFound');




% ----------------------------------------------------
function status = downloadLibraries(options)
status = 0;
nTries = 2;
h = waitbar(0,'Downloading shared libraries.');
for iTry = 1:nTries
    [cmds, errs, msgs] = downloadSharedLibs(options); %#ok<ASGLU>
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
    if ~isempty(strfind(appPath, '/bin'))
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
p = str2cell_startup(p,';');
for kk = 1:length(p)
    if ~isempty(strfind(filesepStandard_startup(p{kk}), app))
        rmpath(p{kk});
    end
end
fprintf('REMOVED search paths for app %s\n', app);

