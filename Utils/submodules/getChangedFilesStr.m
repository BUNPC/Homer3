function [changedFilesStr, changedFiles] = GetChangedFilesStr(strs)
changedFilesStr = '';
changedFiles = {};
for ii = 1:length(strs)
    s = str2cell_startup(strs{ii}, ':');
    if strcmp(s{1}, 'untracked')
        continue;
    end
    if strcmp(s{1}, 'deleted')
        continue;
    end
    changedFiles{ii,1} = deblank(strtrim(s{2}));
    if isempty(changedFilesStr)
        changedFilesStr = changedFiles{ii,1};
    else
        changedFilesStr = sprintf('%s %s', changedFilesStr, changedFiles{ii,1});
    end
end

