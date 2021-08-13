function dotmfiles = findDotMFiles(subdir, exclList)
if ~exist('subdir','var')
    subdir = pwd;
end
if ~exist('exclList','var')
    exclList = {};
end

if ~iscell(exclList)
    exclList = {exclList};
end

dotmfiles = {};

if ~ispathvalid(subdir, 'dir')
    fprintf('Warning: folder %s doesn''t exist under %s\n', subdir, pwd);
    return;
end

% If current subjdir is in the exclList then go back to curr dir and exit
subdirFullpath = filesepStandard(fullpath(subdir));
if isExcluded(subdirFullpath, exclList)
    return;
end

files = dir([subdirFullpath, '*']);
if isempty(files)
    return;
end

for ii = 1:length(files)
    exclFlag = false;
    if isdotmfile(files(ii))
        for kk = 1:length(exclList)
            if strcmp(files(ii).name, exclList{kk})
                exclFlag = true;
            end
        end
        if exclFlag==true
            continue;
        end
        dotmfiles{end+1,1} = filesepStandard(sprintf('%s%s%s', subdirFullpath, files(ii).name), 'nameonly');
    elseif files(ii).isdir && ~iscurrdir(files(ii)) && ~isparentdir(files(ii))
        dotmfiles = [dotmfiles; findDotMFiles([subdirFullpath, files(ii).name], exclList)];
    end
end



% -------------------------------------------------------------------------
function b = isdotmfile(file)
b = false;
if file.isdir
    return;
end
[~, ~, ext] = fileparts(file.name);
if ~strcmp(ext, '.m')
    return;
end
b = true;



% -------------------------------------------------------------------------
function b = iscurrdir(file)
b=0;
if ~file.isdir
    return;
end
if isempty(file.name)
    return;
end
if isempty(file.name)
    return;
end
if length(file.name)==1
    if file.name(1)~='.'
        return;
    end
end
if (length(file.name)==2)
    if (file.name(1)~='.') || (file.name(2)~='/' && file.name(2)~='\')
        return;
    end
end
if (length(file.name)>2)
    return;
end
b=1;



% -------------------------------------------------------------------------
function b = isparentdir(file)
b=0;
if ~file.isdir
    return;
end
if isempty(file.name)
    return;
end
if isempty(file.name)
    return;
end
if length(file.name)==1
    return;
end
if (length(file.name)==2)
    if (file.name(1)~='.') || (file.name(2)~='.')
        return;
    end
end
if (length(file.name)==3)
    if (file.name(1)~='.') || (file.name(2)~='.') || (file.name(2)~='/' && file.name(2)~='\')
        return;
    end
end
if (length(file.name)>3)
    return;
end
b=1;


% -------------------------------------------------------------------------
function b = isExcluded(pname, exclList)
b = true;
if pname(end)=='/'
    pname(end) = '';
end
[~,f,e] = fileparts(pname);
for ii = 1:length(exclList)
    if strcmp(exclList{ii}, [f,e])
        return;
    end
end
b = false;



