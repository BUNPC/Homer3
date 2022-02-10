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
    % make that we use only search from the current app for download shared
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

appnames = [appname; dependencies()];
PrintSystemInfo([], appnames)

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
function addSearchPaths(appPaths, options)
if ischar(appPaths)
    p = genpath(appPaths);
    if ispc
        delimiter = ';';
    else
        delimiter = ':';
    end        
    appPaths = str2cell(p, delimiter);
end
if ~exist('options', 'var')
    options = '';
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
d = dependencies();
for ii = 1:length(d)
    rootpath = '';
    if exist([pwd, '/', d{ii}],'dir')
        rootpath = [pwd, '/'];
    elseif exist([pwd, '/../', d{ii}],'dir')
        rootpath = [pwd, '/../'];
    end
    if ~exist([rootpath, d{ii}],'dir')
        fprintf('ERROR: Could not find required dependency %s\n', d{ii})
        continue;
    end
    addSearchPaths([rootpath, d{ii}]);
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

