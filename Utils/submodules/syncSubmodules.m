function [cmds, errs, msgs] = syncSubmodules(repo, options, preview)

% Syntax:
%   [cmds, errs, msgs] = syncSubmodules()
%   [cmds, errs, msgs] = syncSubmodules(repo)
%   [cmds, errs, msgs] = syncSubmodules(repo, options)
%   [cmds, errs, msgs] = syncSubmodules(repo, options, preview)
%
% Examples:
%   syncSubmodules(pwd, 'init', true);
%   syncSubmodules(pwd, 'update');
%   syncSubmodules(pwd);
%
%

cmds = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('options','var')
    options = '';
end
if ~exist('preview','var')
    preview = false;
end

repoFull = filesepStandard_startup(repo,'full');
ii = 1;

submodules = parseGitSubmodulesFile(repoFull);

if ~ispathvalid([repoFull, '/submodules']) || strcmp(options, 'update')
    [cmds, errs, msgs] = gitSubmodulesClone(repoFull);
end

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
for jj = 1:size(submodules,1)
    [~, f, e] = fileparts(submodules{jj,1});
    submodulename = [f, e];
    
    repo1 = submodules{jj,2};
    repo2 = [repoFull, 'submodules/', submodulename];
    
    if repo1(end)=='\' || repo1(end)=='/'
        repo1 = repo1(1:end-1);
    end
    if repo2(end)=='\' || repo2(end)=='/'
        repo2 = repo2(1:end-1);
    end
    
    fprintf('Synching "%s" library:\n', submodulename);
    fprintf('Repo1:  %s, v%s\n', repo1, getVernum(submodulename, repo1));
    fprintf('Repo2:  %s, v%s\n', repo2, getVernum(submodulename, repo2));
    fprintf('====================================================================\n');   
    
    identical(1) = sync(repo1, repo2, false, preview);
    identical(2) = sync(repo2, repo1, true, preview);

    if all(identical) 
        fprintf('Repos are IDENTICAL\n');
    end
    
    fprintf('\n\n')
end



% ----------------------------------------------------------------------------
function identical = sync(repo1, repo2, peerlessOnly, preview)
identical = true;

if ~exist('peerlessOnly','var')
    peerlessOnly = false;
end
if ~exist('preview','var')
    preview = false;
end

f1_1 = findTypeFiles(repo1, '.m');
f1_2 = findTypeFiles(repo1, '.txt');
f1_3 = findTypeFiles(repo1, '.numberfiles');
f2_1 = findTypeFiles(repo2, '.m');
f2_2 = findTypeFiles(repo2, '.txt');
f2_3 = findTypeFiles(repo2, '.numberfiles');
f1 = [f1_1; f1_2; f1_3];
f2 = [f2_1; f2_2; f2_3];

for kk = 1:length(f2)
    foundflag = false;
    [~, fname2,ext2] = fileparts(f2{kk});
    for ll = 1:length(f1)
        [~, fname1,ext1] = fileparts(f1{ll});
        if strcmp([fname1,ext1], [fname2,ext2]) 
            if ~filesEqual(f2{kk}, f1{ll},'exact') && ~peerlessOnly
                fprintf('Copying %s to %s\n', f2{kk}, f1{ll})
                identical = false;
                if preview == false
                    copyfile(f2{kk}, f1{ll})
                end
            end
            foundflag = true;
            break;
        end
    end
    
    if ~foundflag
        if ~peerlessOnly
            p = pathsubtract(f2{kk}, repo2);
            fprintf('Adding %s\n', [repo1, p]);
            if preview == false
                copyfile(f2{kk}, [repo1, p]);
                gitAdd(repo1, p);
            end
            identical = false;
        else
            fprintf('Deleting %s\n', f2{kk});
            if preview == false
                gitDelete(repo2, f2{kk});
            end
            identical = false;
        end
    end
    
end


