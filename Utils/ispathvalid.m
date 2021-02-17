function b = ispathvalid(p, type)
% ispathvalid can replace matlab's o.isdir, o.isfile and exist functions
% all of which have flaws (e.g., isdir not fully backwards compatible, 
% exist has bugs where it'll confuse files and folders)
%
b = false;
if ~exist('type','var')
    type = '';
end
if strcmp(type,'file')
    if isdir_private(p)
        return;
    end
end
if strcmp(type,'dir')
    if isfile_private(p)
        return;
    end
end
b = ~isempty(dir(p));

