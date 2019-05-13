function snirf = Nirs2Snirf(nirsfiles0, replace, tfactors)
%
% Syntax:
%   snirf = Nirs2Snirf(nirsfiles)
%   snirf = Nirs2Snirf(nirsfiles, replace)
%   snirf = Nirs2Snirf(nirsfiles, replace, tfactors)
%
% 
%
snirf = SnirfClass().empty();

if ~exist('nirsfiles0','var') || isempty(nirsfiles0)
    nirsfiles0 = NirsFilesClass().files;
end
if ~exist('replace','var') || isempty(replace)
    replace = false;
end
if ~exist('tfactors','var') || isempty(tfactors)
    tfactors = 1;
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

h = waitbar_improved(0,'Converting .nirs files to .snirf ...');
for ii=1:length(nirsfiles)
    if nirsfiles(ii).isdir
        continue;
    end
    [pname,fname,ext] = fileparts([nirsfiles(ii).pathfull, '/', nirsfiles(ii).filename]);
    fprintf('Converting %s to %s\n', [pname,'/',fname,ext], [pname,'/',fname,'.snirf']);
    waitbar_improved(ii/length(nirsfiles), h, sprintf('Converting %s to SNIRF: %d of %d', nirsfiles(ii).name, ii, length(nirsfiles)));

    nirs = load([pname,'/',fname,ext],'-mat');
    snirf(ii) = SnirfClass(nirs, tfactors);
    snirf(ii).Save([pname,'/',fname,'.snirf']);
    if replace
        delete([pname,'/',fname,ext]);
    end
end
close(h);
