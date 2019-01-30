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
% path_arr = getpathparts(str);
% currpath_arr = getpathparts(pwd);
% 
% name = '';
% for ii=1:length(fullpath_arr)
%     if ~ismember(fullpath_arr)
%     end
% end
%  
for ii=1:length(dirs)
    files(ii) = FileClass(dirs(ii));
end

