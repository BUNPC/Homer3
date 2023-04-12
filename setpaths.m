function setpaths(addremove)

%
% USAGE:
%
%   % 1. Add all search paths for this repo
%   setpaths
%
%   % 2. Same as 1.. Add all search paths for this repo
%   setpaths(1)
%
%   % 3. Add all search paths for this repo while removing search 
%   %    paths of all similar workspaces
%   setpaths(2)
%
%   % 4. Remove all search paths for this repo
%   setpaths(0)
%
currdir = pwd;
global logger

try
    
    warning('off','MATLAB:rmpath:DirNotFound');
    
    appname = 'Homer3';
    
    % Parse arguments
    if ~exist('addremove','var')
    	addremove = 1;
    end
    
    % Add libraries on which Homer3 depends
    d = addDependenciesSearchPaths();

    % Start logger only after adding library paths. Logger is in the Utils libary. 
    logger = Logger('setpaths');
        
    % Create list of possible known similar apps that may conflic with current
    % app
    appNameExclList = {'Homer3','DataTree','Homer2_UI','brainScape','ResolveCommonFunctions'};
    appNameInclList = {'AtlasViewerGUI'};
    exclSearchList  = {'.git','.idea','Data','Docs','*_install','*.app','submodules'};
    
    appThis         = filesepStandard_startup(pwd);
    appThisPaths    = findDotMFolders(appThis, exclSearchList);
    
    if addremove == 0
        if ~isempty(which('deleteNamespace.m'))
            deleteNamespace(appname);
        end
        removeSearchPaths(appThis);
        return;
    elseif addremove == 2
        appNameExclList = [appNameExclList, appNameInclList];
        appNameInclList = {};
    end
    
    appExclList = {};
    appInclList = {};
    
    % Find all root folders of apps to exclude from search paths
    for ii = 1:length(appNameExclList)
        foo = which([appNameExclList{ii}, '.m'],'-all');
        
        % Before giving up and concluding the path does not exist in list of matlab
        % search paths, try appending the word 'Class' to path name. 
        if isempty(foo)
            foo = which([appNameExclList{ii}, 'Class.m'],'-all');
        end
        
        for jj = 1:length(foo)
            p = filesepStandard_startup(fileparts(foo{jj}));
            if pathscompare_startup(appThis, p)
                continue
            end
            printMethod(sprintf('Exclude paths for %s\n', p));
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
                printMethod(sprintf('Exclude paths for %s\n', p));
            else
                p = filesepStandard_startup(fileparts(foo{jj}));
                appInclList = [appInclList; p]; %#ok<AGROW>
                printMethod(sprintf('Include paths for %s\n', p));
            end
        end
    end
    
    % Remove all search paths for all other apps except for current one, to
    % make sure that we use only search from the current app for download shared
    % libraries (i.e, submodules).
    for ii = 1:length(appExclList)
        removeSearchPaths(appExclList{ii})
    end
    for ii = 1:length(appInclList)
        removeSearchPaths(appInclList{ii})
    end
    
    addSearchPaths(appThisPaths);
    
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
        setpaths_proprietary(addremove);
    end
    
    warning('on','MATLAB:rmpath:DirNotFound');
        
    PrintSystemInfo(logger, ['Homer3'; d]);
    logger.CurrTime('Setpaths completed on ');
    logger.Close();
    cd(currdir);
    
catch ME
    
    printStack(ME)
    if exist('logger','var')
        logger.Close();
    end
    cd(currdir);
    rethrow(ME)
    
end



% ---------------------------------------------------
function d = dependencies()
d = {};
submodules = parseGitSubmodulesFile(pwd);
temp = submodules(:,1);
for ii = 1:length(temp)
    [~, d{ii,1}] = fileparts(temp{ii});
end


% ---------------------------------------------------
function setpermissions(appPath)
if isunix() || ismac()
    global logger
    if ~isempty(strfind(appPath, '/bin')) %#ok<*STREMP>
        cmd = sprintf('chmod 755 %s/*\n', appPath);
        logger.Write(cmd);
        files = dir([appPath, '/*']);
        if ~isempty(files)
            system(cmd);
        end
    end
end



% ----------------------------------------------------
function addSearchPaths(appPaths)
if ischar(appPaths)
    p = genpath(appPaths);
    if ispc
        delimiter = ';';
    else
        delimiter = ':';
    end        
    appPaths = str2cell(p, delimiter);
end
for kk = 1:length(appPaths)
    if strfind(appPaths{kk}, '.git')
        continue;
    end
    addpath(appPaths{kk}, '-end');
    setpermissions(appPaths{kk});
end
printMethod(sprintf('ADDED search paths for app %s\n', appPaths{1}));



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
printMethod(sprintf('REMOVED search paths for app %s\n', app));




% ----------------------------------------------------
function   d = addDependenciesSearchPaths()
if exist([pwd, '/Utils/submodules'],'dir')
    addpath([pwd, '/Utils/submodules'],'-end');
end
d = dependencies();
for ii = 1:length(d)
    rootpath = findFolder(pwd, d{ii});
    rootpath(rootpath=='\') = '/';
    if ispathvalid_startup([rootpath, '/Shared'],'dir')
        rootpath = [rootpath, '/Shared'];
    end
    if ~exist(rootpath,'dir')
        printMethod(sprintf('ERROR: Could not find required dependency %s\n', d{ii}));
        continue;
    end
    addSearchPaths(rootpath);
end




% -----------------------------------------------------------------------------
function [C,k] = str2cell(str, delimiters, options)

% Option tells weather to keep leading whitespaces. 
% (Trailing whitespaces are always removed)
if ~exist('options','var')
    options = '';
end

if ~strcmpi(options, 'keepblanks')
    str = strtrim(str);
end
str = deblank(str);

if ~exist('delimiters','var') || isempty(delimiters)
    delimiters{1} = sprintf('\n');
elseif ~iscell(delimiters)
    foo{1} = delimiters;
    delimiters = foo;
end

% Get indices of all the delimiters
k=[];
for kk=1:length(delimiters)
    k = [k, find(str==delimiters{kk})];
end
j = find(~ismember(1:length(str),k));

% The following line seems to hurt performance a little bit. It was 
% meant to preallocate to speed things up but it does not seem to do that.
% C = repmat({blanks(max(diff([k,length(str)])))}, length(k)+1, 1);
C = {};
ii=1; kk=1; 
while ii<=length(j)
    C{kk} = str(j(ii));
    ii=ii+1;
    jj=2;
    while (ii<=length(j)) && ((j(ii)-j(ii-1))==1)
        C{kk}(jj) = str(j(ii));
        jj=jj+1;
        ii=ii+1;
    end
    C{kk}(jj:end)='';
    kk=kk+1;
end
C(kk:end) = [];



% -------------------------------------------------------------------------
function printMethod(msg)
global logger
if isa(logger', 'Logger')
    try
        logger.Write(msg);
    catch
        fprintf(msg);
    end
else
    fprintf(msg);
end




% -------------------------------------------------------------------------
function submodules = parseGitSubmodulesFile(repo)
submodules = cell(0,3);

if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
currdir = pwd;
if repo(end) ~= '/' && repo(end) ~= '\'
    repo = [repo, '/'];
end

filename = [repo, '.gitmodules'];
if ~exist(filename, 'file')
    return;
end
cd(repo);

fid = fopen(filename, 'rt');
strs = textscan(fid, '%s');
strs = strs{1};
kk = 1;
for ii = 1:length(strs)
    if strcmp(strs{ii}, '[submodule')
        jj = 1;
        while ~strcmp(strs{ii+jj}, '[submodule')
            if ii+jj+2>length(strs)
                break;
            end
            if strcmp(strs{ii+jj}, 'path')
                submodules{kk,2} = [pwd, '/', strs{ii+jj+2}];
            end
            if strcmp(strs{ii+jj}, 'path')
                submodules{kk,3} = strs{ii+jj+2};
            end
            if strcmp(strs{ii+jj}, 'url')
                submodules{kk,1} = strs{ii+jj+2};
            end
            jj = jj+1;
        end
        kk = kk+1;
    end
end
fclose(fid);
cd(currdir);

