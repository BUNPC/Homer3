function [cmds, errs, msgs] = gitSubmodulesInit(repo, preview)
cmds = {};

if ~exist('mode','var')
    mode = 'init';
end

currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end

repoFull = filesepStandard_startup(repo,'full');
ii = 1;

s = parseGitSubmodulesFile();

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git config --global http.sslverify "false"');
cmds{ii,1} = sprintf('git submodule update --init'); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);

branch = gitGetBranch(repo);

submodules = parseGitSubmodulesFile(repo);
for ii = 1:size(submodules,1)
    cd(repoFull)
    cd(submodules{ii,3})
    gitSetBranch(branch);
end

cd(currdir);

