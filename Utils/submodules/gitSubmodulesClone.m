function [cmds, errs, msgs] = gitSubmodulesClone(repo, preview, options)
cmds = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end
if ~exist('options','var')
    options = 'init';
end


repoFull = filesepStandard_startup(repo,'full');
ii = 1;

submodules = parseGitSubmodulesFile(repoFull);
url = gitGetOrigin(repoFull);
urlroot = fileparts(url);
branch = gitGetBranch(repoFull);

if optionExists(options, 'update')
    try
        rmdir([repoFull, '/submodules'],'s')
    catch
    end
end
if ~ispathvalid([repoFull, '/submodules'])
    mkdir([repoFull, '/submodules'])
end

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
for jj = 1:size(submodules,1)
    [~, submodulename] = fileparts(submodules{jj,1});
    if ~ispathvalid([repoFull, 'submodules/', submodulename])
        cmds{ii,1} = sprintf('git clone --branch %s %s %s', branch, [urlroot, '/', submodulename], [repoFull, 'submodules/', submodulename]); ii = ii+1;
    end
end

[errs, msgs] = exeShellCmds(cmds, preview);

