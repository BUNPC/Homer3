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
%   Sets all the paths needed by the app in the current folder. It also uses git commands to downloasd
%   all its associated submodules if they exist and changes their branch and origin to match the parent app.
%
%   If GIT is NOT available, setpaths will try to download and install the non-git versions of the submodules
%   after asking the user to input the source branch that matches the parent app.
%
%   options:
%        1. no arguments
%           Add search paths for parent app under current folder and all its associated submodules. 
%           It is equivalent to argument value of 1. NOTE: This option will NOT automatically 
%           download submodules. (See 'init' or 'update' options)
%
%        2. 1
%           Add search paths for parent app under current folder and all its associated submodules. NOTE: 
%           This option will NOT automatically download submodules. (See 'init' or 'update' options)
%
%        3. 0
%           Remove search paths for parent app under current folder and all its associated submodules
%
%        4. 'init'
%           Add search paths for parent app under current folder and all its associated submodules. Initialize
%           all submodules to same branch and origin as parent app
%
%        5. 'update'
%           Update all submodules to their latest revision for their current branches. If used on a newly
%           downloaded parent app it will do the equivalent of setpaths('init').
%
%        6. 'branch: <branchname>'
%           Add search paths for parent app under current folder and all its associated submodules. Initialize all
%           submodules to same branch and origin as parent app. Checkout branch <branchname> for parent app and
%           submodules. If branch <branchname> doesn't exist create based off current branch and then check it out.
%
%        7. 'branch: <branchname src>, <branchname dst>'
%           Add search paths for parent app under current folder and all its associated submodules. Initialize all
%           submodules and parent repo to <branchname src> and change submodule origin to match parent app. The branch
%           <branchname src> must exist (otherwise setpaths will fail to checkout the appropriate branch). Then create
%           new branch <branchname dst> if it does not exist already based off <branchname src>. If branch
%           <branchname dst> DOES exist then simply check it out.
%
%
% EXAMPLES:
%
%   % Example 1:   Set search paths for parent app in the current folder and any associated submodules.
%   %   Download associated submodule and change their branch and origin to match that of parent app.
%
%   setpaths
%
%
%   % Example 2:   Remove all search paths for parent app in the current folder and its associated submodules
%
%   setpaths(0)
%
%
%   % Example 3:   Update all submodules to their latest revision for their current branches. If used on a
%   %   newly downloaded repo it will do the equivalent of setpaths with no args or setpaths('init').
%
%   setpaths('update')
%
%
%   % Example 4:   Set search paths for parent app in the current folder and any associated submodules.
%   %   Change submodule current branch and origin to match parent app. Then create/checkout branch
%   %   'mynewbranch1'. If 'mynewbranch1' is new it will be based off 'development' branch in the parent
%   %   app AND all submodules.
%
%   setpaths('branch: development, mynewbranch1')
%
%
%   % Example 5:   Set search paths for parent app in the current folder and any associated submodules.
%   %   Download associated submodule and change their branch and origin to match that of parent app.
%   %   Then create/checkout branch 'mynewbranch1'. If 'mynewbranch1' is new it will be created in the
%   %   parent app AND all submodules based off the current branch in each of those repos.
%
%   setpaths('branch: mynewbranch1')

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

