function pnamefull = fullpath(pname)

pnamefull = '';

if ~exist(pname,'file')
    return;
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

pnamefull = [pwd,'/',f,e];
k = find(pnamefull=='\');
pnamefull(k) = '/';
cd(currdir);

