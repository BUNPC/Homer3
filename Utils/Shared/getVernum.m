function [v, appname] = getVernum(appname, appdir)
v = '';
if ~exist('appname','var') || isempty(appname)
    appname = '';
    if ~exist('appdir','var') || isempty(appdir)
        appdir = getAppDir();
    end
    if isempty(appdir)
        return
    end
    if appdir(end)=='/' || appdir(end)=='\'
        appdir(end) = '';
    end
    [~,f,e] = fileparts(appdir);
    appname = [f,e];
end
if ~exist('appdir','var') || isempty(appdir)
    appdir = getAppDir();
end
if isempty(appdir)
    return
end
libdir = '/Shared';
if isdeployed()
    p = appdir;    
elseif length(appdir) > length(libdir)  &&  strcmp( appdir( end-length(libdir)+1 : end ), libdir )
    p = appdir;
elseif ispathvalid([appdir, libdir])
    p = [appdir, libdir];
elseif ispathvalid([appdir, appname, libdir])
    p = [appdir, appname, libdir];
elseif ispathvalid([appdir, appname, '.m'])
    p = appdir;
else
    p = findFolder(appdir, appname);
    if ~ispathvalid(p)
        k = strfind(appname,'Class');
        if ~isempty(k)
            p = findFolder(appdir, appname(1:k-1));
        end
    end
end
verfile = [p, '/Version.txt'];
if ~ispathvalid(verfile)
    return;
end
fd = fopen(verfile,'rt');
v = fgetl(fd);
fclose(fd);



% --------------------------------------------------------------------
function dirpath = findFolder(repo, dirname)
dirpath = '';
if ~exist('repo','var')
    repo = filesepStandard(pwd);
end
dirpaths = findDotMFolders(repo, {'.git', '.idea'});

for ii = 1:length(dirpaths)
    [~, f, e] = fileparts(dirpaths{ii}(1:end-1));
    if strcmp(dirname, [f,e])
        dirpath = dirpaths{ii};
        break;
    end
    if ispathvalid([dirname, dirpaths{ii}])
        dirpath = dirpaths{ii};
        break;
    end
end



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
    [c,d] = str2cell(exclList{ii},'*');
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


