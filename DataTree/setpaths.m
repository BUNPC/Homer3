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
    
    appname = 'DataTreeClass';
    
    % Parse arguments
    if ~exist('addremove','var')
    	addremove = 1;
    end
    
    % Add libraries on which DataTreeClass depends
    d = addDependenciesSearchPaths();

    % Start logger only after adding library paths. Logger is in the Utils libary. 
    logger = Logger('setpaths');
    
    % Create list of possible known similar apps that may conflic with current
    % app
    appNameExclList = {'DataTree','AtlasViewerGUI','Homer3','Homer2_UI','brainScape','ResolveCommonFunctions'};
    appNameInclList = {};
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
    
    PrintSystemInfo(logger, ['DataTreeClass'; d]);
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
function dirpath = findFolder(repo, dirname)
dirpath = '';
if ~exist('repo','var')
    repo = filesepStandard_startup(pwd);
end
dirpaths = findDotMFolders(repo, {'.git', '.idea'});

for ii = 1:length(dirpaths)
    [~, f, e] = fileparts(dirpaths{ii}(1:end-1));
    if strcmp(dirname, [f,e])
        dirpath = dirpaths{ii};
        break;
    end
    if ispathvalid_startup([dirname, dirpaths{ii}])
        dirpath = dirpaths{ii};
        break;
    end
end



% -------------------------------------------------------------------------
function dotmfolders = findDotMFolders(subdir, exclList)
global logger
global MAXPATHLENGTH
MAXPATHLENGTH = 8;

dotmfolders = {};

if ~exist('subdir','var')
    subdir = pwd;
end
if ~exist('exclList','var')
    exclList = {};
end

if ~iscell(exclList)
    exclList = {exclList};
end

subdirFullpath = filesepStandard(subdir,'full');

if ~ispathvalid(subdirFullpath, 'dir')
    logger.Write('Warning: folder %s doesn''t exist\n', subdirFullpath);
    return;
end

% If current subjdir is in the exclList then go back to curr dir and exit
if isExcluded(subdirFullpath, exclList)
    return;
end

dirs = dir([subdirFullpath, '*']);
if isempty(dirs)
    return;
end

if isdotmfolder(subdirFullpath)
    dotmfolders = {filesepStandard(subdirFullpath, 'nameonly')};
end

for ii = 1:length(dirs)
    if ~dirs(ii).isdir
        continue;
    end
    if dirs(ii).name(1) == '.'
        continue;
    end
    dotmfolders = [dotmfolders; findDotMFolders([subdirFullpath, dirs(ii).name], exclList)]; %#ok<AGROW>
end





% -------------------------------------------------------------------------
function b = isdotmfolder(folder)
global MAXPATHLENGTH
b = false;
if ~ispathvalid(folder, 'dir')
    return
end
if isempty(dir([folder,'/*.m']))
    % Exceptions to rule that 'dotm' folder must have at least one '.m' file: 
    % it is a an executable folder (i.e. '/bin')
    if ~isempty(strfind(folder, '/bin/')) %#ok<*STREMP>
        b = true;
        return
    end
    return;
else
    rootdir = which('findDotMFolders');
    rootdir = fileparts(rootdir);
    rootdir = pathsubtract(rootdir, 'Utils/submodules','nochange');
    p = pathsubtract(folder, rootdir);
    if length(find(p=='/')) > MAXPATHLENGTH
        return
    end
end
b = true;




% -------------------------------------------------------------------------
function b = isExcluded(pname, exclList)
b = true;
if pname(end)=='/'
    pname(end) = '';
end
if ~ispathvalid(pname,'dir')
    return;
end
[~,f,e] = fileparts(pname);
for ii = 1:length(exclList)
    [c,d] = str2cell_startup(exclList{ii},'*');
    if isempty(d) && strcmp(c{1}, [f,e])
        return;
    end

    % Get list of all folders matching exclList{ii} pattern, whether it be
    % a single folder name or a wildcard pattern
    for jj = 1:length(c)
        k = strfind(c{jj}, [f,e]);
        if isempty(k)
            break;
        end
    end
    if ~isempty(k)
        return;
    end
end
b = false;



% -------------------------------------------------------------------------
function diff = pathsubtract(p2_0, p1_0, options)
if ~exist('options','var')
    options = '';
end
if optionExists(options, 'nochange')
    option = '';
else
    option = 'full';
end
p1 = filesepStandard(p1_0, option);
p2 = filesepStandard(p2_0, option);
if isempty(p1)
    p1 = p1_0;
end
if isempty(p2)
    p2 = p2_0;
end
k = strfind(p2, p1);
if ~isempty(k) && k(1)==1
    diff = p2(k(1)+length(p1):end);
elseif ~isempty(k)
    diff = p2(1:k(1)-1);
else
    diff = '';
end



% --------------------------------------------------------------------
function pathname = filesepStandard_startup(pathname0, options)

%
% Usage:
%    pathname = filesepStandard(pathname, options)
%
% Takes a pathname as argument and replaces any non-standard file/folder
% separators with standard ones, that is '/'. It also gets rid of redundant
% file seps
%
% Example:
%
%   >> pathname = 'C:\dir1\\\dir2\\dir3\test1/\test2/'
%   >> pathname = filesepStandard(pathname)
%
%   pathname =
%
%   C:/dir1/dir2/dir3/test1/test2/
%
%

pathname = '';

if nargin==0
    return
end
if isempty(pathname0)
    return
end
if ~ischar(pathname0) && ~iscell(pathname0)
    return
end

if ~exist('options', 'var')
    options = '';
end

if ischar(pathname0)
    pathname0 = removeExtraDots_startup(pathname0);
    
    % Do basic error check to see if path exists; if not wexist without
    % doing anything 
    if ~optionExists_startup(options,'nameonly')
        if ~ispathvalid_startup(pathname0)
            return
        end
    end
    
    % Change all path file separators to standard forward slash
    idxs = [];        
    k = find(pathname0=='\' | pathname0=='/');
    for ii = 1:length(k)
        if (ii>1) && (k(ii) == k(ii-1)+1)
            idxs = [idxs, k(ii)]; %#ok<AGROW>
            continue;
        end
        pathname0(k(ii)) = '/';
    end
    
    % Remove any extraneous file separators
    pathname0(idxs) = '';
        
    % Change path to full path if option requesting it exists
    if optionExists_startup(options,'full') || optionExists_startup(options,'fullpath') || optionExists_startup(options,'absolute')
        if ispathvalid_startup(pathname0)
            pathname0 = fullpath_startup(pathname0);
        end
    end
    
    % Add traling separator only for directory path names 
    if (isdir_private_startup(pathname0) || optionExists_startup(options, 'dir')) && ~optionExists_startup(options, 'file')
        if pathname0(end) ~= '/'
            pathname0(end+1) = '/';
        end
    elseif (isfile_private_startup(pathname0) || optionExists_startup(options, 'file')) && ~optionExists_startup(options, 'dir')
        if pathname0(end) == '/'
            pathname0(end) = '';
        end
    else
        if pathname0(end) == '/'
            pathname0(end) = '';
        end
    end
        
    % Change path to full path if option requesting it exists
    pathname = pathname0;
    return;
end
pathname = pathname0;

% Call filesepStandard recursively for all path names in cell array
for ii = 1:length(pathname)
    pathname{ii} = filesepStandard_startup(pathname{ii}, options);
end




% ---------------------------------------------------------------------
function b = isfile_private_startup(dirname)
%
% isfile_private() is a backward compatible version of matlab's isfile()
% function.
%
% isfile() is a new matlab function that is an improvment over exist() to 
% tell if a pathname is a file or not. But it didn't exist prior to R2017. 
% Therefore we use try/catch to still be able to use isfile when it exists

try
    b = isfile(dirname);
catch
    b = (exist(dirname,'file') == 2);
end




% ---------------------------------------------------------------------
function b = isdir_private_startup(dirname)
%
% isdir_private() is a backward compatible version of matlab's isdir()
% function.
%
% isdir() is a new matlab function that is an improvment over exist() to 
% tell if a pathname is a directory or not. But it didn't exist prior to R2017. 
% Therefore we use try/catch to still be able to use isdir when it exists

try
    b = isdir(dirname);
catch
    b = (exist(dirname,'dir') == 7);
end



% ---------------------------------------------------------------------
function pname = removeExtraDots_startup(pname)
k = cell(4,3);

% Case 1:
k{1,1} = strfind(pname, '/./');
k{2,1} = strfind(pname, '/.\');
k{3,1} = strfind(pname, '\.\');
k{4,1} = strfind(pname, '\./');
for ii = 1:length(k(:,1))
    for jj = length(k{ii,1}):-1:1
        pname(k{ii,1}(jj)+1:k{ii,1}(jj)+2) = '';
    end
end

% Case 2:
k{1,2} = strfind(pname, '/.');
k{2,2} = strfind(pname, '\.');
for ii = 1:length(k(:,2))
    if ~isempty(k{ii,2})
        if k{ii,2}+1<length(pname)
            continue
        end
        pname(k{ii,2}+1) = '';
    end
end




% ---------------------------------------------------------------------
function b = optionExists_startup(options, option)
% Check if option (arg2) exists in a set of options (arg1)
b = false;
if isempty(options)
    return;
end
if iscell(options)
    options = options{1};
end
if ~ischar(options)
    return;
end

if ~exist('option','var') || isempty(option)
    b = false;
    return;
end
options2 = str2cell_startup(options,{':',';',','});
b = ~isempty(find(strcmp(options2,option))); %#ok<EFIND>

% b = ~isempty(findstr(options, option)); %#ok<*FSTR>




% ---------------------------------------------------------------------
function b = ispathvalid_startup(p, options)
% ispathvalid can replace matlab's o.isdir, o.isfile and exist functions
% all of which have flaws (e.g., isdir not fully backwards compatible, 
% exist has bugs where it'll confuse files and folders)
%
b = false;
if ~exist('options','var')
    options = '';
end
if ~ischar(options)
    return;
end
if ~isempty(options)
    if optionExists_startup(options,'file')
        
        % Err check 1.
        if isdir_private_startup(p)
            return;
        end
        
        % Err check 2.
        if optionExists_startup(options, 'checkextension')
            [~, ~, ext] = fileparts(p);
            if isempty(ext)
                return;
            end
        end
        
    elseif optionExists_startup(options,'dir')
        if isfile_private_startup(p)
            return;
        end
    else
        return;
    end
end
b = ~isempty(dir(p));




% -------------------------------------------------------------------------
function b = pathscompare_startup(path1, path2, options)

b = 0;

if ~exist('options','var')
    options = '';
end
if optionExists_startup(options,'nameonly')
    b = pathsCompareNameOnly(path1, path2);
    return;
end

if exist(path1,'file') ~= exist(path2,'file')
    return;
end
if exist(path1,'file')==0
    return;
end
if exist(path2,'file')==0
    return;
end

currdir = pwd;

% If paths are files, compare just the file names, then the folders 
fullpath1 = filesepStandard_startup(path1, 'full');
fullpath2 = filesepStandard_startup(path2, 'full');


% Compare folders
b = strcmpi(fullpath1, fullpath2);

cd(currdir);



% -------------------------------------------------------------------------
function b = pathsCompareNameOnly(path1, path2)
b = 0;
if ispc()
    path1 = lower(path1);
    path2 = lower(path2);
end
p1 = str2cell(path1,{'\','/'});
p2 = str2cell(path2,{'\','/'});
if length(p1) ~= length(p2)
    return;
end
for ii = 1:length(p1)
    if ~strcmp(p1{ii},p2{ii})
        return
    end
end
b = true;



% -------------------------------------------------------------------------
function pnamefull = fullpath_startup(pname, style)

pnamefull = '';

if ~exist('pname','var')
    return;
end
if ~exist(pname,'file')
    return;
end
if ~exist('style','var')
    style = 'linux';
end

% If path is file, extract pathname
p = ''; 
f = '';
e = '';
if strcmp(pname, '.')
    p = pwd; f = ''; e = '';
elseif strcmp(pname, '..')
    currdir = pwd;
    cd('..');
    p = pwd; f = ''; e = '';
    cd(currdir);
else
    [p,f,e] = fileparts(pname);
    if length(f)==1 && f=='.' && length(e)==1 && e=='.' 
        f = ''; 
        e = '';
    elseif isempty(f) && length(e)==1 && e=='.' 
        e = '';
    end
end
pname = removeExtraDots_startup(p);

% If path to file wasn't specified at all, that is, if only the filename was
% provided without an absolute or relative path, the add './' prefix to file name.
if isempty(pname)
    p = fileparts(['./', pname]);
    pname = p;
end


% get full pathname 
currdir = pwd;

try
    cd(pname);
catch
    try 
        cd(p)
    catch        
        return;
    end
end

if strcmp(style, 'linux')
    sep = '/';
else
    sep = filesep;
end
pnamefull = [pwd,sep,f,e];
if ~exist(pnamefull, 'file')
    pnamefull = '';
    cd(currdir);
    return;
end

pnamefull(pnamefull=='/' | pnamefull=='\') = sep;

cd(currdir);


