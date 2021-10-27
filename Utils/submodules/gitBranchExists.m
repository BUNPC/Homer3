function [b, cmds, errs, msgs] = gitBranchExists(repo, branch)
b = false;
cmds = {};

currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end

repoFull = filesepStandard_startup(repo,'full');
ii = 1;

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git branch --list'); ii = ii+1; %#ok<NASGU>

[errs, msgs] = exeShellCmds(cmds, false, true);

if length(msgs) == ii-1
    c = str2cell_startup(msgs{ii-1}, {char(32), char(10), char(13)}); %#ok<CHARTEN>
    for ii = 1:length(c)
        if strcmp(branch, c{ii})
            b = true;
            break;
        end
    end
end
cd(currdir);

