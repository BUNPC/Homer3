function pnamefull = fullpath_startup(pname, style)

pnamefull = '';

if ~exist('pname','var')
    return;
end
if ~exist(pname,'file')
    return;
end
if ~exist('style','var')
    style = 'linux';
end

% If path is file, extract pathname
p = ''; 
f = '';
e = '';
if strcmp(pname, '.')
    p = pwd; f = ''; e = '';
elseif strcmp(pname, '..')
    currdir = pwd;
    cd('..');
    p = pwd; f = ''; e = '';
    cd(currdir);
else
    [p,f,e] = fileparts(pname);
    if length(f)==1 && f=='.' && length(e)==1 && e=='.' 
        f = ''; 
        e = '';
    elseif isempty(f) && length(e)==1 && e=='.' 
        e = '';
    end
end
pname = removeExtraDots_startup(p);

% If path to file wasn't specified at all, that is, if only the filename was
% provided without an absolute or relative path, the add './' prefix to file name.
if isempty(pname)
    p = fileparts(['./', pname]);
    pname = p;
end


% get full pathname 
currdir = pwd;

try
    cd(pname);
catch
    try 
        cd(p)
    catch        
        return;
    end
end

if strcmp(style, 'linux')
    sep = '/';
else
    sep = filesep;
end
pnamefull = [pwd,sep,f,e];
if ~exist(pnamefull, 'file')
    pnamefull = '';
    cd(currdir);
    return;
end

pnamefull(pnamefull=='/' | pnamefull=='\') = sep;

cd(currdir);



