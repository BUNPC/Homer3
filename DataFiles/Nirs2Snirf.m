function snirf = Nirs2Snirf(nirsfiles, replace)

snirf = SnirfClass();

if ~exist('nirsfiles','var')
    nirsfiles = NirsFilesClass().files;
end
if ~exist('replace','var') || isempty(replace)
    replace = false;
end

for ii=1:length(nirsfiles)
    
    if nirsfiles(ii).isdir
        continue;
    end
    
    [pname,fname,ext] = fileparts([nirsfiles(ii).pathfull, '/', nirsfiles(ii).filename]);
    fprintf('Converting %s to %s\n', [pname,'/',fname,ext], [pname,'/',fname,'.snir5']);    
    nirs = load([pname,'/',fname,ext],'-mat');
    snirf(ii) = SnirfClass(nirs);    
    snirf(ii).Save([pname,'/',fname,'.snir5']);
    if replace
        delete([pname,'/',fname,ext]);
    end
    
end

