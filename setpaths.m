function setpaths(add, fluence_simulate)

%
% USAGE: 
%
%   paths_str = setpaths(add, fluence_simulate)
%
% DESCRIPTION:
%
%   Sets all the paths needed by the homer3 and atlasViewer source code. 
%
% INPUTS:
%
%   add: if false or ommitted then setpaths adds all the homer3 paths,
%           specified in getpaths. If true, adds all the homer3 paths 
%           specified in getpaths. 
%
%   fluence_simulate: If true, then setpaths searches for precalculated fluence
%                       profile files used by AtlasViewer. When found it tries
%                       to add a second fluence profile to the fluence file
%                       to simulate a second wavelength if an actual
%                       fluence profile at a second wavelength doesn't
%                       already exist.
%
% OUTPUTS:
%
%   path homer3  
%    
% EXAMPLES:
%
%   setpaths;
%   paths = setpaths(0);
%   paths = setpaths(1);
%   paths = setpaths(0,0);
%   paths = setpaths(0,1);
%   paths = setpaths([],1);
%



if ~exist('add','var') | isempty(add)
    add = true;
end
if ~exist('fluence_simulate','var') | isempty(fluence_simulate)
    fluence_simulate = false;
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
    menu('WARNING: The current folder does NOT look like a homer3 root folder. Please change current folder to the root homer3 folder and rerun setpaths.', 'OK');
    paths = {};
    return;
end


if add
    fprintf('ADDED homer3 paths to matlab search paths:\n');
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
    if fluence_simulate
        genMultWlFluenceFiles_CurrWorkspace;
    end
else
    fprintf('REMOVED homer3 paths from matlab search paths:\n');
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

