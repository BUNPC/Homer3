function [cmds, errs, msgs] = gitSubmoduleRefUpdate(repo, submodule, revid, preview)
cmds = {};
errs = [];
msgs = {};

if ~exist('submodule','var')
    return;
end
if ~exist('revid','var')
    return;
end
if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end
revid2 = gitSubmoduleRevId(repo, submodule);
if strcmp(revid, revid2)
    cmds = {''};
    errs = 0;
    msgs = {sprintf('Submodule %s already up to date', submodule)};
    return;
end

currdir = pwd;
repoFull = filesepStandard_startup(repo,'full');

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('cd %s', submodule); ii = ii+1;
cmds{ii,1} = sprintf('git reset --hard %s', revid); ii = ii+1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git add %s', submodule); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);

commit = CommitGUI([repoFull, submodule], 'userargs');
if isempty(commit.changedFiles)
    cmds = {};
    cd(currdir)
    return;
end
cmds{ii,1} = sprintf('git commit -m "%s"', commit.comment); ii = ii+1;
%cmds{ii,1} = sprintf('git push'); ii = ii+1;

[errs2, msgs2] = exeShellCmds(cmds, preview);
errs = [errs; errs2];
msgs = [msgs; msgs2];

cd(currdir)
