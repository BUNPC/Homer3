function setpaths(add, mode)

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

if ~exist('add','var') || isempty(add)
    add = true;
end
if ~exist('mode','var') || isempty(mode)
    mode = 'errcheck';
end

if ~add
    mode = 'noerrcheck';
end

[paths, wspaths, paths_excl_str] = getpaths(mode);
if ~isempty(wspaths)
    if pathscompare(wspaths{1}, pwd)
        fprintf('Current workspace %s already at the top of the search path.\n', wspaths{1});
        addwspaths(wspaths, paths_excl_str);
        return;
    end
end


% Add or remove paths for this application
rootpath = pwd;
rootpath(rootpath=='\')='/';
paths_str = '';
for ii=1:length(paths)
    paths{ii} = [rootpath, paths{ii}];
    
    if ~isempty(strfind(mode, 'verbose'))
        if add
            fprintf('Adding path %s\n', paths{ii});
        else
            fprintf('Removing path %s\n', paths{ii});
        end
    end
    
    if ~exist(paths{ii}, 'dir')
        fprintf('Path %s does not exist\n', paths{ii});
        menu('WARNING: The current folder does NOT look like the application root folder. Please change current folder to the root application folder and rerun setpaths.', 'OK');
        return;
    end
    
    paths_str = [paths_str, delimiter, paths{ii}];
end


% Add current workspace at the top of the stack of conflicting workspaces
wspaths = [pwd; wspaths];
paths_excl_str = [paths_str, paths_excl_str];


% Either add all conflicting workspaces to the search path or remove the
% current one, depending on user selection 
if add
    fprintf('ADDED search paths for worspace %s\n', pwd);    
    addwspaths(wspaths, paths_excl_str);
    setpermissions(paths);
else
    fprintf('REMOVED search paths for worspace %s\n', pwd);
    rmpath(paths_excl_str{1});
end




% ---------------------------------------------------
function idx = findExePaths(paths)

idx = [];
kk = 1;
for ii=1:length(paths)
    if ~isempty(strfind(paths{ii}, '/bin'))
        idx(kk) = ii;
        kk=kk+1;
    end
end



% ---------------------------------------------------
function addwspaths(wspaths, paths_excl_str)

if isempty(wspaths)
    return;
end

addpath(paths_excl_str{1}, '-end');

if length(wspaths)>1
    fprintf('\n');
    fprintf('Order of precedence of similar workspaces:\n');
else
    return;
end
for ii=1:length(wspaths)
    fprintf('  %s\n', wspaths{ii});
    addpath(paths_excl_str{ii}, '-end');
end



% ---------------------------------------------------
function setpermissions(paths)

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





