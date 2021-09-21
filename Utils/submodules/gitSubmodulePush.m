function [cmds, errs, msgs] = gitSubmodulePush(submodule, repo, preview)
cmds = {};
errs = -1;
msgs = {};

if ~exist('submodule','var')
    return;
end
if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end

currdir = pwd;

repoFull = filesepStandard_startup(repo,'full');

ii = 1;

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('cd %s', submodule); ii = ii+1;
cmds{ii,1} = sprintf('git push origin %s', gitGetBranch()); ii = ii+1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git push'); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);

cd(currdir);

