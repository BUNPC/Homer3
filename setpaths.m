function setpaths(options_str)

%
% USAGE: 
%
%   setpaths
%   setpaths(1)
%   setpaths(0)
%   setpaths(options)
%
% DESCRIPTION:
%
%   Sets all the paths needed by a tool 
%
% INPUTS:
%
%   options:   Char string containing one or more options. To select mutiple options, combine 
%              together the 4 mutually exclusive options below in any order, separating 
%              individual options with ',',':' or '|'. The list of mutually exclusive 
%              options are:
%
%           {'add','remove'}               (default: add)         Add or remove paths of current 
%                                                                 workspace to search path
%           {'conflcheck','noconflcheck'}  (default: conflcheck)    
%           {'mvpathconfl','rmpathconfl'}  (default: mvpathconfl) 'conflcheck' option must be selected 
%                                                                  for this this option not to be ignored
%           {'quiet','verbose'}            (default: quiet)
%    
% EXAMPLES:
%
%   Example 1: Add paths for current workspace quietly and do not do any
%              checking for conflicting workspaces.
% 
%   setpaths;
%      setpaths(1);
%
%   Example 2: Quietly add paths for current workspace to have precedence over any 
%              conflicting workspace. The paths for any conflicting workspace will 
%              be made lower precedence than current workspace. 
%
%      setpaths('add:conflcheck');
%
%
%   Example 3: Quietly remove paths for current workspace quietly.
% 
%   setpaths(0);
%      setpaths('remove');
%      setpaths('remove:quiet');
%
%
%   Example 4: Add paths for the current workspace verbosely and remove all 
%              paths of conflicting workspaces. 
%
%      setpaths('rmpathconfl:verbose');
%      setpaths('add:rmpathconfl:verbose');
%      setpaths('add:conflcheck:rmpathconfl:verbose');
%      setpaths('rmpathconfl|verbose|add|conflcheck');
%


% Parse arguments
if ~exist('options_str','var')
    options_str = 1;
end
options = parseOptions(options_str);

if ~options.add
    options.conflcheck = false;
end

[paths, wspaths, paths_excl_str] = getpaths(options);
if ~isempty(wspaths)
    if pathscompare(wspaths{1}, pwd)
        fprintf('Current workspace %s already at the top of the search path.\n', wspaths{1});
        addwspaths(wspaths, paths_excl_str, options);
        return;
    end
end


% Add or remove paths for this application
rootpath = pwd;
rootpath(rootpath=='\')='/';
paths_str = '';
for ii=1:length(paths)
    paths{ii} = [rootpath, paths{ii}];
    
    if options.verbose
        if options.add
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
if options.add
    fprintf('ADDED search paths for worspace %s\n', pwd);    
    addwspaths(wspaths, paths_excl_str, options);
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
function addwspaths(wspaths, paths_excl_str, options)

if isempty(wspaths)
    return;
end

% Add the primary workspace to the search path
addpath(paths_excl_str{1}, '-end');

if options.rmpathconfl
    msg = 'Removed the following similar workspaces from the search path to avoid conflicts:';
else
    msg = 'Order of precedence of similar workspaces:';
end

% Add all the other similar workspaces that have been found and removed
if length(wspaths)>1
    fprintf('\n');
    fprintf('%s\n', msg);
    for ii=2:length(wspaths)
        fprintf('  %s\n', wspaths{ii});
        if options.rmpathconfl
            continue;
        end
        addpath(paths_excl_str{ii}, '-end');
    end
end

if exist('./setpaths_proprietary.m','file')
    setpaths_proprietary(options);
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





