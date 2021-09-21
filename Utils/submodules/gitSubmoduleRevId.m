function [revid, cmds, errs, msgs] = gitSubmoduleRevId(repo, submodule, preview)
revid = '';
cmds = {};
errs = [];
msgs = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('submodule','var')
    return;
end
if ~exist('preview','var')
    preview = false;
end

currdir = pwd;

repoFull = filesepStandard_startup(repo,'full');

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git ls-files -s %s', submodule); ii = ii+1;

[errs, msgs] = exeShellCmds(cmds, preview);
k = 2;
if length(msgs)<k
    cd(currdir)
    return
end
if isempty(msgs{k})
    cd(currdir)
    return
end
c = str2cell_startup(msgs{k}, ' ');
revid = c{2};

cd(currdir)
