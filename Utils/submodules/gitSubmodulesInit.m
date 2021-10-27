function [cmds, errs, msgs] = gitSubmodulesInit(repo, options, preview)
cmds = {};

currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('options','var')
    options = 'init';
end
if ~exist('preview','var')
    preview = false;
end

repoFull = filesepStandard_startup(repo,'full');
ii = 1;

cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('git config --global http.sslverify "false"'); ii = ii+1;
cmds{ii,1} = sprintf('git submodule update --init'); ii = ii+1; %#ok<NASGU>

[errs, msgs] = exeShellCmds(cmds, preview);

submodules = parseGitSubmodulesFile(repo);

% Set origin for submodules to be same as origin for parent repo
url = gitGetOrigin(repoFull);
urlroot = fileparts(url);
for ii = 1:size(submodules,1)
    [~, submodulename] = fileparts(submodules{ii,1});
    gitSetOrigin([repoFull, submodules{ii,3}], [urlroot, '/', submodulename]);
end

% Checkout branch for parent repo and submodules. First checkout the source
% branch then destination. Source branch is the branch from which the
% destination branch is derived if destination branch is a new branch. 
[branchSrc, branchDst] = gitGetSrcDstBranches(repoFull, options);
if isempty(branchSrc) || isempty(branchDst)
    return
end
for ii = 1:size(submodules,1)
    gitSetBranch([repoFull, submodules{ii,3}], branchSrc);
end
for ii = 1:size(submodules,1)
    gitSetBranch([repoFull, submodules{ii,3}], branchDst);
end
gitSetBranch(repoFull, branchSrc);
gitSetBranch(repoFull, branchDst);

cd(currdir);




% ----------------------------------------------------------------
function [branchSrc, branchDst] = gitGetSrcDstBranches(repo, options)
branchSrc = '';
branchDst = '';
c = str2cell_startup(options, {':',','});
for ii = 1:length(c)
    c{ii} = strtrim(deblank(c{ii}));
end
if optionExists_startup(c, 'branch')
    if length(c)==2        
        branchSrc = gitGetBranch(repo);
        branchDst = c{2};
    elseif length(c)==3
        if ~gitBranchExists(repo, c{2})
            h = msgbox(sprintf('ERROR: source branch ''%s'' does not exist in this repo. Source branch must exist to create the destination branch (''%s'')\n', ...
                c{2}, c{3}));
            waitForGui_startup(h);
            return
        end
        branchSrc = c{2};
        branchDst = c{3};
    end
else
    branchSrc = gitGetBranch(repo);
    branchDst = branchSrc;
end

