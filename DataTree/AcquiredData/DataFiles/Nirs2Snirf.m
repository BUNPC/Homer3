function [snirf, nirsfiles] = Nirs2Snirf(dirname, nirsfiles0, replace, ntimebases)
%
% Syntax:
%   snirf = Nirs2Snirf(dirname, nirsfiles)
%   snirf = Nirs2Snirf(dirname, nirsfiles, replace)
%   snirf = Nirs2Snirf(dirname, nirsfiles, replace, ntimebases)
%
% Description:
%   Convert all .nirs files in the folder dirname to .snirf
%
% 
%

DEBUG=false;

snirf = SnirfClass().empty();

if ~exist('dirname','var') || isempty(dirname)
    dirname = filesepStandard(pwd);
end
if ~exist('nirsfiles0','var') || isempty(nirsfiles0)
    nirsfiles0 = DataFilesClass(dirname,'nirs').files;
end
if ~exist('replace','var') || isempty(replace)
    replace = false;
end
if ~exist('ntimebases','var') || isempty(ntimebases)
    ntimebases = 1;
end

nirsfiles = mydir(dirname);
if iscell(nirsfiles0)
    for ii=1:length(nirsfiles0)
        nirsfiles(ii) = mydir(nirsfiles0{ii});
    end
elseif ischar(nirsfiles0)
    nirsfiles = mydir(nirsfiles0);
elseif isa(nirsfiles0, 'FileClass')
    nirsfiles = nirsfiles0;
end

fprintf('\n');

h = waitbar_improved(0, sprintf('Converting %d .nirs files to .snirf ...', length(nirsfiles)));
for ii=1:length(nirsfiles)
    if nirsfiles(ii).isdir
        continue;
    end
    [pname, fname, ext] = fileparts([nirsfiles(ii).rootdir, '/', nirsfiles(ii).name]);
    
    src = filesepStandard([pname,'/',fname, ext]);
    dst = filesepStandard([pname,'/',fname,'.snirf'], 'nameonly');
    
    fprintf('Converting %s to %s\n', src, dst);
    waitbar_improved(ii/length(nirsfiles), h, sprintf('Converting %s to SNIRF: %d of %d', nirsfiles(ii).name, ii, length(nirsfiles)));

    nirs = load(src,'-mat');
    
    if DEBUG==false
        snirf(ii) = SnirfClass(nirs);
    else
        snirf(ii) = SnirfClass(nirs, ntimebases);
    end
    
    snirf(ii).Save(dst);
    if replace
        delete(src);
    end
end
close(h);

fprintf('\n');
