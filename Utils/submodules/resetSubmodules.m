function resetSubmodules(repo)
% The main use of resetSubmodules is a tool to quickly reset the state 
% of libraries when debugging issues in syncSubmodules
if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
repoFull = filesepStandard_startup(repo,'full');
submodules = parseGitSubmodulesFile(repoFull);
cd(repoFull);
for jj = 1:size(submodules,1)
    fprintf('Reseting "%s":\n', submodules{jj,2});
    gitRevert(submodules{jj,2});
    fprintf('\n');
end




