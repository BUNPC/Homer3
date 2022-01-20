function pathrel = getPathRelative(pathfull, pathroot)
pathrel = '';

if ~ischar(pathfull)
    return
end
if ~ischar(pathroot)
    return
end

option1 = '';
option2 = '';

if ~ispathvalid(pathfull)
    option1 = 'nameonly';
end
if ~ispathvalid(pathroot)
    option2 = 'nameonly';
end

pathfull = filesepStandard(pathfull, option1);
pathroot = filesepStandard(pathroot, option2);

k = strfind(pathfull, pathroot);
if isempty(k)
    return;
end
if ispathvalid(pathfull, 'dir')
    j = 1;
else
    j = 0;
end
pathrel = pathfull(k+length(pathroot):end-j);

