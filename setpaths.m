function setpaths(add)

%
% USAGE: 
%
%   setpaths
%   setpaths(1)
%   setpaths(0)
%
% DESCRIPTION:
%
%   Sets all the paths needed by a tool 
%
% INPUTS:
%
%   add: if false or ommitted then setpaths adds all the tool paths,
%           specified in getpaths. If true, removes all the tool paths 
%           specified in getpaths. 
%
%    
% EXAMPLES:
%
%   setpaths;
%   setpaths(0);
%   setpaths(1);
%
if ~exist('add','var') | isempty(add)
    add = true;
end

paths = getpaths()';

rootpath = pwd;
k = find(rootpath=='\');
rootpath(k)='/';

paths_str = '';
err = false;
for ii=1:length(paths)
    paths{ii} = [rootpath, paths{ii}];
    if add
        fprintf('Adding path %s\n', paths{ii});
    else
        fprintf('Removing path %s\n', paths{ii});
    end
    
    if ~exist(paths{ii}, 'dir')
        fprintf('Path %s does not exist\n', paths{ii});
        err = true;
        continue;
    end
    if isempty(paths_str)
        paths_str = paths{ii};
    else
        paths_str = [paths_str, ';', paths{ii}];
    end
end

if err
    menu('WARNING: The current folder does NOT look like the application root folder. Please change current folder to the root application folder and rerun setpaths.', 'OK');
    paths = {};
    return;
end


if add
    fprintf('ADDED application paths to matlab search paths:\n');
    addpath(paths_str, '-end')
    
    if isunix()
        idx = findExePaths(paths);
        for ii=1:length(idx)
            fprintf(sprintf('chmod 755 %s/*\n', paths{idx(ii)}));
            files = dir([paths{idx(ii)}, '/*']);
            if ~isempty(files)
                system(sprintf('chmod 755 %s/*', paths{idx(ii)}));
            end
        end
    end
    
    if exist('./setpaths_proprietary.m','file')
        setpaths_proprietary();
    end
else
    fprintf('REMOVED application paths from matlab search paths:\n');
    rmpath(paths_str);
end



% ---------------------------------------------------
function idx = findExePaths(paths)

idx = [];
kk = 1;
for ii=1:length(paths)
    if ~isempty(findstr(paths{ii}, '/bin'))
        idx(kk) = ii;
        kk=kk+1;
    end
end

