function files = mydir(str)

files = FileClass().empty();
if ~exist('str','var')
    dirs = dir();
else
    dirs = dir(str);
end

if isempty(dirs)
    return;
end 

for ii=1:length(dirs)
    files(ii) = FileClass(dirs(ii));
end

