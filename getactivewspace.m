function [paths_excl, wspath] = getactivewspace(appname)

paths_excl = {};
paths_all = str2cell(path, delimiter);

wspath = '';
kk=1;
[wsname, wspath] = getwspacename(appname);
if isempty(wsname)
    return;
end

for ii=1:length(paths_all)
    if ~all(strcmp(getpathparts(paths_all{ii}), wsname)==0)
        paths_excl{kk,1} = paths_all{ii};
        kk=kk+1;
    end
end

