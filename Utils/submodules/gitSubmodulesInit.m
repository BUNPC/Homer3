function [cmds, errs, msgs] = gitSubmodulesInit(repo, preview)
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

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git config --global http.sslverify "false"');
cmds{ii,1} = sprintf('git submodule update --init'); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);

url = gitGetOrigin(repoFull);
urlroot = fileparts(url);
branch = gitGetBranch(repo);

submodules = parseGitSubmodulesFile(repo);
for ii = 1:size(submodules,1)
    [~, submodulename] = fileparts(submodules{ii,1});
    gitSetBranch([repoFull, submodules{ii,3}], branch);
    gitSetOrigin([repoFull, submodules{ii,3}], [urlroot, '/', submodulename]);
end

cd(currdir);

