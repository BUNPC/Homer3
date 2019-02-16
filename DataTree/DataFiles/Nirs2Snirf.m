function snirf = Nirs2Snirf(nirsfiles0, replace)

snirf = SnirfClass().empty();

if ~exist('nirsfiles0','var')
    nirsfiles0 = NirsFilesClass().files;
end
if ~exist('replace','var') || isempty(replace)
    replace = false;
end

nirsfiles = mydir('');
if iscell(nirsfiles0)
    for ii=1:length(nirsfiles0)
        nirsfiles(ii) = mydir(nirsfiles0{ii});
    end
elseif ischar(nirsfiles0)
    nirsfiles = mydir(nirsfiles0);
elseif isa(nirsfiles0, 'FileClass')
    nirsfiles = nirsfiles0;
end

for ii=1:length(nirsfiles)
    if nirsfiles(ii).isdir
        continue;
    end
    [pname,fname,ext] = fileparts([nirsfiles(ii).pathfull, '/', nirsfiles(ii).filename]);
    fprintf('Converting %s to %s\n', [pname,'/',fname,ext], [pname,'/',fname,'.snirf']);    
    nirs = load([pname,'/',fname,ext],'-mat');
    snirf(ii) = SnirfClass(nirs);
    snirf(ii).Save([pname,'/',fname,'.snirf']);
    if replace
        delete([pname,'/',fname,ext]);
    end
end

