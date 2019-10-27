function dotmfiles = findDotMFiles(subdir, exclList)

if ~exist('exclList','var')
    exclList = {};
end

dotmfiles = {};
currdir = pwd;

if exist(subdir, 'dir')~=7
    fprintf('Warning: folder %s doesn''t exist under %s\n', subdir, pwd);
    return;
end
cd(subdir);

% If current subjdir is in the exclList then go back to curr dir and exit
subdirFullpath = pwd;

for ii=1:length(exclList)
    if ~isempty(findstr(exclList{ii}, subdirFullpath))
        cd(currdir);
        return;
    end
end

files = dir('*');
if isempty(files)
    return;
end

for ii=1:length(files)
    exclFlag = false;
    if isdotmfile(files(ii))
        for kk=1:length(exclList)
            if strcmp(files(ii).name, exclList{kk})
                exclFlag = true;
            end
        end
        if exclFlag==true
            continue;
        end
        dotmfiles{end+1} = sprintf('%s%s%s', pwd, filesep, files(ii).name);
    elseif files(ii).isdir && ~iscurrdir(files(ii)) && ~isparentdir(files(ii))
        dotmfiles = [dotmfiles, findDotMFiles(files(ii).name, exclList)];
    end
end
cd(currdir);



% -------------------------------------------------------------------------
function b = isdotmfile(file)

b=0;
if file.isdir
    return;
end
if file.name(end) ~= 'm' || file.name(end-1) ~= '.'
    return;
end
b=1;



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
% Helper function: remove name arg from list
function list = removeEntryFromList(name, list)

temp = strfind(list, name);
k=[];
for ii=1:length(temp)
    if ~isempty(temp{ii})
        k=ii;
    end
end
list(k) = [];



