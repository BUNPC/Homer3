function pathname = buildrelpath(pathparts,dirsep)

if ~exist('dirsep','var')
    dirsep = repmat({'/'},length(pathparts),2);
    dirsep{1,1}='';
    dirsep{end,2}='';
else
    for ii=1:length(pathparts)
        if ~isempty(dirsep{ii,1})
            dirsep{ii,1} = '/';
        end
        if ~isempty(dirsep{ii,2})
            dirsep{ii,2} = '/';
        end
    end
end

pathname='';
for ii=1:length(pathparts)
    if isempty(pathname)
        pathname = sprintf('%s%s%s',dirsep{ii,1},pathparts{ii},dirsep{ii,2});
    else
        pathname = sprintf('%s%s%s',pathname,pathparts{ii},dirsep{ii,2});
    end
end
