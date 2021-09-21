function [cmds, errs, msgs] = gitSubmoduleCommit(submodule, repo, changedFiles, preview)
cmds = {};
errs = [];
msgs = {};

if ~exist('submodule','var')
    return;
end
if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('changedFiles','var') || isempty(changedFiles)
    changedFiles = '.';
end
if ~exist('preview','var')
    preview = false;
end

currdir = pwd;

repoFull = filesepStandard_startup(repo,'full');

ii = 1;

%%%% Commit submodule
[modified, added, deleted, untracked] = gitStatus([repo, submodule]);
changedFilesStr = getChangedFilesStr([modified; added; deleted; untracked]);
if isempty(changedFilesStr)
    cmds = {};
    cd(currdir)
    return;
end
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('cd %s', submodule); ii = ii+1;
cmds{ii,1} = sprintf('git add %s', changedFilesStr); ii = ii+1;
commit = CommitGUI([repoFull, submodule], 'userargs');
if isempty(commit.changedFiles)
    msgs = {'cancelled'};
    cd(currdir)
    return;
end
cmds{ii,1} = sprintf('git commit -m "%s"', commit.comment); ii = ii+1;


%%%% Commit parent repo
[modified, added, deleted, untracked] = gitStatus(repo);
changedFilesStr = getChangedFilesStr([modified; added; deleted; untracked]);
if isempty(changedFilesStr)
    cmds = {};
    cd(currdir)
    return;
end
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git add %s', submodule); ii = ii+1;
commit = CommitGUI(repoFull, submodule, 'userargs');
if isempty(commit.changedFiles)
    msgs = {'cancelled'};
    cd(currdir)
    return;
end
cmds{ii,1} = sprintf('git commit -m "%s"', commit.comment); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);

cd(currdir)

