function pnamefull = fullpath(pname, style)

pnamefull = '';
currdir = pwd;

if ~exist('pname','var')
    return;
end
if ~exist('style','var')
    style = 'linux';
end

% If path to file wasn't specified at all, that is, if only the filename was
% provided without an absolute or relative path, the add './' prefix to file name.
if isempty(fileparts(pname))
    pname = ['./', pname];
end

% If path is file, extract pathname
try
    [p0,f0,e0] = fileparts(pname);
    if ispathvalid(pname, 'file') || ~isempty(strfind(f0,'*')) || ~isempty(strfind(e0,'*')) %#ok<*STREMP>
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

if strcmp(style, 'linux')
    sep = '/';
else
    sep = filesep;
end

pnamefull = [p,sep,f,e];
if ~ispathvalid(pnamefull)
    pnamefull = '';
    cd(currdir);
    return;
end

pnamefull(pnamefull=='/' | pnamefull=='\') = sep;

cd(currdir);



