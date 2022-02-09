function r = gitAdd(repo, pname)
r = -1;
if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
repoFull = filesepStandard_startup(repo,'full');
currdir = pwd;

if ~ispathvalid(pname)
    return
end

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git add %s', pname); ii = ii+1;

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
