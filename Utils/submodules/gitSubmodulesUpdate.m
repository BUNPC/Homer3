function [cmds, errs, msgs] = gitSubmodulesUpdate(repo, options, preview)
cmds = {};


currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('options','var')
    options = 'init';
end
if ~exist('preview','var')
    preview = false;
end

repoFull = filesepStandard_startup(repo,'full');

branch = gitGetBranch(repoFull);
submodules = parseGitSubmodulesFile(repoFull);

ii = 1;

cmds{ii,1} = sprintf('git config --global http.sslverify "false"'); ii = ii+1;
for jj = 1:size(submodules,1)
    cmds{ii+jj-1,1} = sprintf('cd %s', repoFull); ii = ii+1;
    cmds{ii+jj-1,1} = sprintf('cd %s', submodules{jj,3}); ii = ii+1;
    cmds{ii+jj-1,1} = sprintf('git pull origin %s', branch);
end

[errs, msgs] = exeShellCmds(cmds, preview);

cd(currdir);

