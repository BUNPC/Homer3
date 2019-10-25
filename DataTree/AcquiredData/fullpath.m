function pnamefull = fullpath(pname, style)

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
if exist(pname,'file')==2
    [p,f,e] = fileparts(pname);
    pname = p;
   
    % If path to file wasn't specified at all, that is, if only the filename was
    % provided without an absolute or relative path, the add './' prefix to file name. 
    if isempty(pname)
        [p,f,e] = fileparts(['./', pname]);
        pname = p;
    end        
end

% get full pathname 
currdir = pwd;

if exist(pname,'dir')==7
    cd_safe(pname);
else
    return;
end

if strcmp(style, 'linux')
    sep = '/';
else
    sep = filesep;
end
pnamefull = [pwd,sep,f,e];
pnamefull(pnamefull=='/' | pnamefull=='\') = sep;

cd(currdir);


