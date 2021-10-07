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



% ------------------------------------------------------------------
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
