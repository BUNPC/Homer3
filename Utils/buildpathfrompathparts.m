function pathname = buildpathfrompathparts(pp, fs)

pathname='';
for ii=1:length(pp)
    if ~isempty(pathname) & pathname(end)=='/'
        pathname = [pathname, pp{ii}, fs{ii,2}];
    else
        pathname = [pathname, fs{ii,1}, pp{ii}, fs{ii,2}];
    end
end