function files = mydir(str)

files = FileClass().empty();
if ~exist('str','var')
    str = '.';
elseif isempty(str)
    str = '.';
elseif str(end) == '*'
    str(end) = '';
end
dirs = dir(str);
if isempty(dirs)
    return;
end
kk = 1;
for ii=1:length(dirs)
    foo = FileClass(dirs(ii));
    if ~foo.IsEmpty()
        files(kk) = foo;
        files(kk).pathfull = convertToStandardPath(fileparts(fullpath(str)));
        kk=kk+1;
    end
end

