function [cmds, errs, msgs] = gitSubmodulesClone(repo, preview)
cmds = {};

currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end

repoFull = filesepStandard_startup(repo,'full');
ii = 1;

submodules = parseGitSubmodulesFile(repoFull);
url = gitGetOrigin(repoFull);
urlroot = fileparts(url);
branch = gitGetBranch(repoFull);

if ispathvalid([repoFull, '/submodules'])
    try
        rmdir([repoFull, '/submodules'],'s')
    catch
    end
end
mkdir([repoFull, '/submodules'])

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
for jj = 1:size(submodules,1)
    [~, submodulename] = fileparts(submodules{jj,1});
    cmds{ii,1} = sprintf('git clone --branch %s %s %s', branch, [urlroot, '/', submodulename], [repoFull, 'submodules/', submodulename]); ii = ii+1;
end

[errs, msgs] = exeShellCmds(cmds, preview);

