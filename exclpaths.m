function paths_excl = exclpaths(appnames, utilsdir)

if ischar(appnames)
    appnames = {appnames};
end
if ~exist('utilsdir','var')
    utilsdir = pwd;
end


paths_excl = {};

currdir = pwd;
cd(utilsdir);
paths_all = str2cell(path,';');
cd(currdir); 

kk=1;
for jj=1:length(appnames)
    [~, excldir] = fileparts(fileparts(which(appnames{jj})));
    if isempty(excldir)
        return;
    end
    for ii=1:length(paths_all)
        
        if ~isempty(findstr(paths_all{ii}, excldir))
            paths_excl{kk,1} = paths_all{ii};
            kk=kk+1;
        end
        
    end
end