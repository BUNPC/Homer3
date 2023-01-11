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
    
    appname = 'DataTreeClass';
    
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
    
    % Add libraries on which DataTreeClass depends
    addDependenciesSearchPaths()    
    
    % Create list of possible known similar apps that may conflic with current
    % app
    appNameExclList = {'AtlasViewerGUI','Homer3','Homer2_UI','brainScape','ResolveCommonFunctions'};
    appNameInclList = {};
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


% ---------------------------------------------------
function d = dependencies()
d = {
    'Utils';
    'FuncRegistry';
    };


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
if ischar(appPaths)
    p = genpath(appPaths);
    if ispc
        delimiter = ';';
    else
        delimiter = ':';
    end        
    appPaths = str2cell_startup(p, delimiter);
end
for kk = 1:length(appPaths)
    if strfind(appPaths{kk}, '.git')
        continue;
    end
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




% ----------------------------------------------------
function   addDependenciesSearchPaths()
submodules = downloadDependencies();
for ii = 1:size(submodules)
    submodulespath = [pwd, '/', submodules{ii,end}];
    if ~exist(submodulespath,'dir')
        fprintf('ERROR: Could not find required dependency %s\n', submodules{ii,end})
        continue;
    end
    fprintf('Adding searchpaths for submodule %s\n', submodulespath);
    addSearchPaths(submodulespath);
end



% -----------------------------------------------------------------------------
function [C,k] = str2cell_startup(str, delimiters, options)

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
function dotmfolders = findDotMFolders(subdir, exclList)
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
    fprintf('Warning: folder %s doesn''t exist\n', subdirFullpath);
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



