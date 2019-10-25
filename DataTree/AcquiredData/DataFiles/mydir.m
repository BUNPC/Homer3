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
for ii=1:length(dirs)
    files(ii) = FileClass(dirs(ii));
    
    if isempty(files(ii).pathfull)
        files(ii).pathfull = fileparts(fullpath(str));
    end
end

