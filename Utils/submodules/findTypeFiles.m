function typefiles = findTypeFiles(subdir, type, exclList)
if ~exist('subdir','var')
    subdir = pwd;
end
if ~exist('exclList','var')
    exclList = {};
end

if ~iscell(exclList)
    exclList = {exclList};
end

typefiles = {};

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
    if istypefile(files(ii), type)
        for kk = 1:length(exclList)
            if strcmp(files(ii).name, exclList{kk})
                exclFlag = true;
            end
        end
        if exclFlag==true
            continue;
        end
        typefiles{end+1,1} = filesepStandard(sprintf('%s%s%s', subdirFullpath, files(ii).name), 'nameonly');
    elseif files(ii).isdir && ~iscurrdir(files(ii)) && ~isparentdir(files(ii))
        typefiles = [typefiles; findTypeFiles([subdirFullpath, files(ii).name], type, exclList)];
    end
end



% -------------------------------------------------------------------------
function b = istypefile(file, type)
b = false;
if file.isdir
    return;
end
[~, ~, ext] = fileparts(file.name);
if ~strcmp(ext, type)
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



