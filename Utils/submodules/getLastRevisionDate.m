function [date, dateS] = getLastRevisionDate(repo)
date = 0;
dateS = '';
if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
repoFull = filesepStandard_startup(repo, 'full');
[~,f,e] = fileparts(repoFull(1:end-1));

h = waitbar(0, sprintf('Please wait for date of last rev for "%s" ...', [f,e]));

f1 = findTypeFiles(repoFull, '.m');
f2 = findTypeFiles(repoFull, '.txt');
f3 = findTypeFiles(repoFull, '.numberfiles');
f = [f1; f2; f3];

for ii = 1:length(f)
    pathrel = pathsubtract(f{ii}, repoFull);
    [d, ds] = gitLastRevDate(repoFull, pathrel);
    if d>date
        date = d;
        dateS = ds;
    end
    waitbar(ii / length(f), h)
end

close(h);
