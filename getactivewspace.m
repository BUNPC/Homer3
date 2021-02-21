function [paths_excl, wspath] = getactivewspace(appname)

paths_excl = {};
paths_all = str2cell(path, delimiter);

wspath = '';
kk=1;
[wsname, wspath] = getwspacename(appname);
if isempty(wsname)
    return;
end

% Find any other workspace that is active whose appname is same as the workspace 
% we are making active (but is not yet active). Add the active workspaces'
% path to list of paths to remove
for ii=1:length(paths_all)
    if ~isempty(findstr(paths_all{ii}, wsname))
        paths_excl{kk,1} = paths_all{ii};
        kk=kk+1;
    end
end

