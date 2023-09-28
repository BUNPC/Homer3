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

subdirFullpath = filesepStandard_startup(subdir,'full');

if ~ispathvalid_startup(subdirFullpath, 'dir')
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
    dotmfolders = {filesepStandard_startup(subdirFullpath, 'nameonly')};
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
if ~ispathvalid_startup(folder, 'dir')
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
    rootdir = pathsubtract_startup(rootdir, 'Utils/submodules','nochange');
    p = pathsubtract_startup(folder, rootdir);
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
if ~ispathvalid_startup(pname,'dir')
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



