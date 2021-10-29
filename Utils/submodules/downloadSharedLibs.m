function [cmds, errs, msgs] = downloadSharedLibs(options, appname)
cmds = {};
errs = 0;
msgs = {};

if ~exist('options','var') || (isnumeric(options) && options==0)
    options = 'init';
end

s = parseGitSubmodulesFile();

% Check for missing libs
kk = checkMissingLibraries(s);
if isempty(kk) && optionExists_startup(options, 'init')
    return;
end

if optionExists_startup(options, 'update')
    [cmds, errs, msgs] = gitSubmodulesUpdate(pwd, options);
else
    [cmds, errs, msgs] = gitSubmodulesInit(pwd, options);
end

% Check again for missing libs
kk = checkMissingLibraries(s);
if isempty(kk) && (optionExists_startup(options, 'init') || all(errs==0))
    return;
end

% Try to install missing libs without git
branch = warningGitFailedToInstall(s(kk,:), appname);
if ~isempty(branch)
    if optionExists_startup(options, 'init')
        downloadSubmodulesWithoutGit(s(kk,:), branch);
    elseif optionExists_startup(options, 'update')
        updateSubmodulesWithoutGit(s, branch);
    end
end

% Check again for missing libs
kk = checkMissingLibraries(s);
if isempty(kk)
    errs = 0;
    return;
end

q = warningManualInstallRequired(s(kk,:));
if q==1
    errs = -2;
else
    paths = searchFiles();
    if isempty(paths)
        errs = -1;
    end
end



% ----------------------------------------------------------
function kk = checkMissingLibraries(s)
kk = [];
for ii = 1:size(s,1)
    if isIncompleteSubmodule(s{ii,3})
        removeFolderContents(s{ii,3});
        kk = [kk, ii]; %#ok<AGROW>
    else
        addSearchPaths(s(ii,:));
    end    
end


% ----------------------------------------------------------
function branch = warningGitFailedToInstall(s, appname)
ii = 1;
branch = guessBranch(s, appname);
msg{ii} = sprintf('Git was not able to install the following libraries required by this application:\n\n'); ii = ii+1;
for jj = 1:size(s,1)
    msg{ii} = sprintf('    %s\n', s{jj,1}); ii = ii+1;
end
msg{ii} = sprintf('\n'); ii = ii+1; %#ok<SPRINTFN>
msg{ii} = sprintf('Git might not be installed on your computer. \n'); ii = ii+1;
msg{ii} = sprintf('These libraries can still be installed without git. The assumed submodule branch that matches \n'); ii = ii+1;
msg{ii} = sprintf('the branch of the parent repo, ''%s'', is ''%s''\n\n', appname, branch); ii = ii+1;
msg = [msg{:}];

fprintf(msg)
pause(2);



% ----------------------------------------------------------
function q = warningManualInstallRequired(s)
ii = 1;
msg{ii} = sprintf('WARNING: The following libraries required by this application are still missing:\n\n'); ii = ii+1;
for jj = 1:size(s,1)
    msg{ii} = sprintf('    %s\n', s{jj,1}); ii = ii+1;
end
msg{ii} = sprintf('\n'); ii = ii+1;
msg{ii} = sprintf('Either a) install git and rerun setpaths or b) download the submodules manually and provide their locations. '); ii = ii+1;
msg{ii} = sprintf('Select option:');
msg = [msg{:}];

q = menu(msg, {'Quit setpaths, install git and rerun setpaths','Download submodules manually and provide their locations'});




% ----------------------------------------------------------
function addSearchPaths(s)
kk = [];
exclSearchList  = {'.git'};
for ii = 1:size(s,1)
    foo = findDotMFolders(s{ii,3}, exclSearchList);
    for kk = 1:length(foo)
        addpath(foo{kk}, '-end');
        setpermissions(foo{kk});
    end
end




% ---------------------------------------------------
function setpermissions(appPath)
if isunix() || ismac()
    if ~isempty(strfind(appPath, '/bin'))
        fprintf(sprintf('chmod 755 %s/*\n', appPath));
        files = dir([appPath, '/*']);
        if ~isempty(files)
            system(sprintf('chmod 755 %s/*', appPath));
        end
    end
end




% ----------------------------------------------------
function branchGuess = guessBranch(submodules, appname)
branchGuess = '';
rootdir = fileparts(which([appname, '.m']));
k = strfind(appname, 'GUI');
if ~isempty(k)
    appname0 = appname(1:k-1);
else
    appname0 = appname;
end
k = strfind(rootdir, appname0);
if (k+length(appname0)) <= length(rootdir)
    j = 0;
    if rootdir(k+length(appname0))=='-'
        j = 1;
    end
    branchGuess = rootdir(k+length(appname0)+j:end);
end
fprintf('\nBranch guess:  ''%s''\n', branchGuess);

% Check to see if submodule urls exist. If not edfault to 'master' branches. 
for ii = 1:size(submodules,1)
    url             = submodules{ii,1};
    submodulepath   = submodules{ii,3};
    
    urlfull = sprintf('%s/archive/refs/heads/%s.zip', url, branchGuess);
    [~, urlExists] = urlread(urlfull); %#ok<*URLRD>
    if urlExists
        fprintf('Success:  %s  exists\n', urlfull);
    else
        fprintf('Failed:  %s  does NOT exist. Switching to ''master'' branch\n', urlfull);
        branchGuess = 'master';
    end   
end
fprintf('\n');

