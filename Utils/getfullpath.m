function pathname = getfullpath(relpath)

% Usage 
% 
%     pathname = getfullpath(relpath);
% 
% Take any valid path, relpath, which can be reached from the current directory, 
% and convert to a full pathname. The argument relpath can be either a directory 
% name or file name 
%

currdir = pwd;
relpath = filesepStandard(relpath);
pathname = '';
if ~(exist(relpath, 'dir')==7) & ~(exist(relpath, 'file')==2)
    return;
end

pp={''};
if ~isdir(relpath)
    [pp,fs] = getpathparts(relpath);
    relpath = buildpathfrompathparts(pp(1:end-1),fs(1:end-1,:));
end
if ~exist(relpath,'dir')
    pathname = [];
    return;
end

cd(relpath);
pathname = filesepStandard([pwd,'/',pp{end}]);

if ispc()
    pathname = lower(pathname);
end

cd(currdir);

