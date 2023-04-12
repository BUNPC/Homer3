function [status, modified, added, deleted, untracked] = hasChanges(repo, piece)
status = 0;
if ~exist('piece','var')
    piece = '';
end
[modified, added, deleted, untracked] = gitStatus(repo, piece);
for ii = 1:length(modified)
    c = str2cell(modified{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end
for ii = 1:length(added)
    c = str2cell(added{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end
for ii = 1:length(deleted)
    c = str2cell(deleted{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end
for ii = 1:length(untracked)
    c = str2cell(untracked{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end



