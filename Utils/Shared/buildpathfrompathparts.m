function pathname = buildpathfrompathparts(pp, options)
pathname='';
if ~iscell(pp)
    return
end
if ~exist('options', 'var')
    options = '';
end
for ii = 1:length(pp)
    if ~isempty(pathname) && pathname(end)=='/'
        pathname = [pathname, strtrim(pp{ii}), '/'];
    else
        pathname = [strtrim(pp{ii}), '/'];
    end
end
if ispathvalid(['/', pathname])
    pathname = ['/', pathname];
end
if optionExists(options, 'rmTrailSep')
    if pathname(end)=='/'
        pathname(end) = '';
    end
end
