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

toolname = 'homer3';

if ~exist('add','var') | isempty(add)
    add = true;
end

paths = getpaths();

rootpath = pwd;
k = find(rootpath=='\');
rootpath(k)='/';

paths_str = '';
err = false;
for ii=1:length(paths)
    paths{ii} = [rootpath, paths{ii}];
    if ~exist(paths{ii}, 'dir')
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
    errmsg = sprintf('WARNING: The current folder does NOT look like a %s root folder. Please change current folder to the root %s folder and rerun setpaths.', ...
                     toolname, toolname);
    menu(errmsg, 'OK');
    paths = {};
    return;
end

if add
    fprintf('ADDED %s paths to matlab search paths:\n', toolname);
    addpath(paths_str, '-end')
    
    fprintf('\n');

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
else
    fprintf('REMOVED %s paths from matlab search paths:\n', toolname);
    rmpath(paths_str);
end

checkToolboxDep();



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




% -----------------------------------------------------
function toolboxes = getToolboxesUsed()
    toolboxes = struct(...
        'Name', { ...
        'MATLAB', ...
        'Signal Processing Toolbox', ...
        'Symbolic Math Toolbox' ...
        }, ...
        'Appl', { ...
        'Homer3', ...
        'Homer3', ...
        'Homer3' ...
        } ...
        );


% -----------------------------------------------------
function checkToolboxDep()

v = ver;
toolboxesAvail = cellstr(char(v.Name));
toolboxesUsed = getToolboxesUsed();

for ii=1:length(toolboxesUsed)
    if all(~strcmp(toolboxesUsed(ii).Name, toolboxesAvail))
        warning(sprintf('%s required by %s is missing from this Matlab installation ...', ...
            toolboxesUsed(ii).Name, toolboxesUsed(ii).Appl));
        fprintf('\n');
    end
end

