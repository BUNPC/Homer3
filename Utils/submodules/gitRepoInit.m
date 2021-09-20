function [cmds, errs, msgs] = gitRepoInit(repoLocal, url)
cmds = {};
errs = [];
msgs = {};

[~, repoName] = fileparts(repoLocal);

if isempty(repoLocal)
    repoLocal = pwd;
end
if isempty(url)
    url = '';
end
repoLocal = filesepStandard(repoLocal);
currdir = pwd;

cd(repoLocal)

if ispathvalid('./.git')
    rmdir('./.git','s')
end
if ispathvalid('./temp')
    rmdir('./temp','s')
end

%%%% 1. Check to make sure remote repo exists and is empty
mkdir('./temp')
cd('./temp');
cmd = sprintf('git clone %s', url);
[e, m] = system(cmd); %#ok<ASGLU>

% Does repo exist?
if ~ispathvalid(['./', repoName, '/.git'])
    cd(repoLocal);
    errs = -1;
    return;
end

% Is repo empty? That is if it contains any other file or folder 
% other than .git then we exit
if ~isRepoEmpty(['./', repoName])
    cd(repoLocal);
    errs = -1;
end

cd(repoLocal);
rmdir('./temp','s')

%%%% 2. Initialize empty repo with code 
ii = 1;
cmds{ii,1} = sprintf('git init'); ii = ii+1;
cmds{ii,1} = sprintf('git add .'); ii = ii+1;
cmds{ii,1} = sprintf('git commit -m "First commit for standalone code"'); ii = ii+1;
cmds{ii,1} = sprintf('git remote add origin %s', url); ii = ii+1;
cmds{ii,1} = sprintf('git push --set-upstream origin master'); ii = ii+1;
cmds{ii,1} = sprintf('git checkout -b development'); ii = ii+1;
cmds{ii,1} = sprintf('git push --set-upstream origin development'); ii = ii+1;
[errs, msgs] = exeShellCmds(cmds);




% ------------------------------------------------------------
function b = isRepoEmpty(repoName)
b = false;
dirs = dir([repoName, '/*']);
nfiles = 0;
for ii = 1:length(dirs)
    if strcmp(dirs(ii).name, '.')
        continue
    end
    if strcmp(dirs(ii).name, '..')
        continue
    end
    nfiles = nfiles+1;
end
if nfiles>1
    return;
end
b = true;


