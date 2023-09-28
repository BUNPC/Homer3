function path3 = getRelativePath(path1, path2)
path3 = '';
path1 = filesepStandard_startup(path1);
path2 = filesepStandard_startup(path2);

k = strfind(path1, path2);
if isempty(k) %#ok<*STREMP>
    return
end
if ispathvalid(path1, 'dir')
    j = 1;
else
    j = 0;
end
path3 = path1(length(path2)+1:end-j);

