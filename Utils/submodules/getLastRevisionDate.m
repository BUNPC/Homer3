function [dateNum, dateStr] = getLastRevisionDate(repoParent, subdir)

if ~exist('repoParent','var') || isempty(repoParent)
    repoParent = pwd;
end
repoParentFull = filesepStandard(repoParent, 'full');

if ~exist('subdir','var') || isempty(subdir)
    subdir = repoParentFull;
end

if pathscompare(repoParentFull, subdir)
    [dateNum, dateStr] = gitLastRevDate(repoParentFull);
else
    subdir = pathsubtract(subdir, repoParentFull);
    [dateNum, dateStr] = gitLastRevDate(repoParentFull, subdir);
end
