function [modified, added, deleted, untracked, cmds, errs, msgs] = gitStatus(repo, piece)
modified = {};
added = {};
deleted = {};
untracked = {};
cmds = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('piece','var')
    piece = '';
end
currdir = pwd;
repoFull = filesepStandard(repo,'full');

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
if isempty(piece)
	cmds{ii,1} = sprintf('git status'); ii = ii+1; kk = ii-1;
else
    cmds{ii,1} = sprintf('git status %s', piece); ii = ii+1; kk = ii-1;
end
cmds{ii,1} = sprintf('cd %s', currdir);

[errs, msgs] = exeShellCmds(cmds, false, true);

kk1 = 1;
kk2 = 1;
kk3 = 1;
kk4 = 1;
lines = str2cell(msgs{kk}, sprintf('\n'))';
untrackedFlag = false;
for jj = 1:length(lines)
    if ~isempty(strfind(lines{jj}, 'nothing to commit'))
        break
    end
    if ~isempty(strfind(lines{jj}, 'modified:'))
        k = strfind(lines{jj}, '(modified content)');
        if ~isempty(k)
            lines{jj} = sprintf('%s (submodule)', lines{jj}(1:k-1));
        end
        modified{kk1,1} = strtrim(deblank(lines{jj}));
        kk1 = kk1+1;
    end
    if ~isempty(strfind(lines{jj}, 'new file:'))
        k = strfind(lines{jj}, 'new file:');
        l = length('new file:');
        lines{jj} = sprintf('added: %s', lines{jj}(k+l:end));
        added{kk2,1} = strtrim(deblank(lines{jj}));
        kk2 = kk2+1;
    end
    if ~isempty(strfind(lines{jj}, 'deleted:'))
        deleted{kk3,1} = strtrim(deblank(lines{jj})); %#ok<*AGROW>
        kk3 = kk3+1;
    end
    if ~isempty(strfind(lines{jj}, 'Untracked files:'))
        untrackedFlag = true;
        continue;
    end
    if ~isempty(strfind(lines{jj}, '(use "git add <file>..." to include in what will be committed)'))
        untrackedFlag = true;
        continue;
    end
    if untrackedFlag==true
        untrackedFlag = false;
        while 1
            if jj+kk4-1 > length(lines)
                break;
            end
            filename = strtrim(deblank(lines{jj+kk4-1}));
            if ~ispathvalid(filename)
                break
            end
            untracked{kk4,1} = sprintf('untracked:  %s', filename);
            kk4 = kk4+1;
        end
    end

end

cd(currdir)

