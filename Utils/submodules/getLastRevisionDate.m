function [dateNum, dateStr] = getLastRevisionDate(repoParent, subdir)
dateNum = [];
dateStr = '';

if ~exist('repoParent','var') || isempty(repoParent)
    repoParent = pwd;
end
repoParentFull = filesepStandard(repoParent, 'full');
if ~exist('subdir','var') || isempty(subdir)
    subdir = repoParentFull;
end

if ~ispathvalid(subdir)
    return
end
if ~ispathvalid(repoParent)
    return
end

if pathscompare_startup(repoParentFull, subdir)
    [dateNum, dateStr] = gitLastRevDate(repoParentFull);
else
    subdir = pathsubtract_startup(subdir, repoParentFull);
    [dateNum, dateStr] = gitLastRevDate(repoParentFull, subdir);
end

