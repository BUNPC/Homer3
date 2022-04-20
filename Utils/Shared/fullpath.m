function pnamefull = fullpath(pname, style)

pnamefull = '';
currdir = pwd;

if ~exist('pname','var')
    return;
end
if ~exist('style','var')
    style = 'linux';
end

if strcmp(style, 'linux')
    sep = '/';
else
    sep = filesep;
end


% If path to file wasn't specified at all, that is, if only the filename was
% provided without an absolute or relative path, the add './' prefix to file name.
if isempty(fileparts(pname))
    pname = ['./', pname];
end

% Fix performance issue: its expensive to call cd so avoid it if we can. A valid path is either
% relative or absolute. If pname is already absolute then no need to change folder or anything else
% we are done and simply exist function. We check full path by prepending './'. If a valid path is
% absolute then prepending a './' will make it invalid. JD, Mar 21, 2022
if ispathvalid(pname) && ~ispathvalid(['./', pname])
    pnamefull = pname;
    pnamefull(pnamefull=='/' | pnamefull=='\') = sep;
    return;
end

% If path is file, extract pathname
try

    [p0,f0,e0] = fileparts(pname);
    if ispathvalid(pname, 'file') || ~isempty(strfind(f0,'*')) || ~isempty(strfind(e0,'*')) %#ok<*STREMP>
        % We have a valid file path         
        cd(p0);
        f = f0;
        e = e0;
    elseif ispathvalid(pname, 'dir')
        cd(pname);
        f = '';
        e = '';
    else
        return
    end
    
catch ME
    
    cd(currdir)
    % rethrow(ME)
    return
    
end
p = pwd;

pnamefull = [p,sep,f,e];
if ~ispathvalid(pnamefull)
    pnamefull = '';
    cd(currdir);
    return;
end

pnamefull(pnamefull=='/' | pnamefull=='\') = sep;

cd(currdir);


