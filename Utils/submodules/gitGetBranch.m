function [name, cmds, errs, msgs] = gitGetBranch(repo, quiet)
name = '';
cmds = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('quiet','var') || isempty(quiet)
    quiet = 1;
end

currdir = pwd;

repoFull = filesepStandard_startup(repo,'full');

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('%sgit branch',setTerminal()); ii = ii+1; kk = ii-1;

[errs, msgs] = exeShellCmds(cmds, false, quiet);

if all(errs==0)
    branches = str2cell_startup(msgs{kk});
    for jj = 1:length(branches)
        if branches{jj}(1)=='*'
            break;
        end
    end
    name = extractBranchName(branches{jj});
end

cd(currdir);




% -----------------------------------------
function b = extractBranchName(b)
b = removeGarbage(b);
k = find(b<43);
b(k) = ''; %#ok<FNDSB>



% -----------------------------------------
function b = removeGarbage(b)

% Remove garbage strings from branch name. Matlab for MAC 
% creates these issues because of peculiar shell environemnt 
if ismac()
    k = [];
    knownGarbage = {
        '[m';
        '[32m';
        };
    for kk = 1:length(knownGarbage)
        j = strfind(b, knownGarbage{kk});
        for jj = 1:length(j)
            k = [k, j(jj):j(jj)+length(knownGarbage{kk})-1]; %#ok<AGROW>
        end
    end
    b(k) = '';
end


