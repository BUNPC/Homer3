function r = gitDelete(repo, pname)
r = -1;
if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
repoFull = filesepStandard_startup(repo,'full');
currdir = pwd;

if ~ispathvalid(pname)
    return
end

cached = '';
if ispathvalid([repoFull, '.git/modules/', pname])
    cached = '--cached';
end

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
if isfile_private(pname)
    cmds{ii} = sprintf('git rm %s %s', cached, pname); ii = ii+1;
else
    cmds{ii} = sprintf('git rm -r %s %s', cached, pname); ii = ii+1;
end
if ~isempty(cached)
    cmds = deleteShellCmd(repoFull, cmds); ii = ii+1;
end

[errs, msgs] = exeShellCmds(cmds, false, true);

if all(errs == 0)
    r = 0;
else
    k = find(errs ~= 0);
    for ii = 1:length(k)
        fprintf('%s\n', msgs{k(ii)});
    end
end

cd(currdir);



% ---------------------------------------------------------------------
function cmds = deleteShellCmd(pname, cmds)
if ispc()    
    if isfile_private(pname)
        cmds{end+1} = sprintf('del %s /f /q', pname);
    else
        cmds{end+1} = sprintf('rmdir %s /s /q', pname);
    end
elseif ismac() || isunix()
    cmds{end+1} = sprintf('rm -rf %s', pname);
end
