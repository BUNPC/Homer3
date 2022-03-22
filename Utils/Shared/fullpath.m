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

cdflag = true;

% If path is file, extract pathname
try
    [p0,f0,e0] = fileparts(pname);
    if ispathvalid(pname, 'file') || ~isempty(strfind(f0,'*')) || ~isempty(strfind(e0,'*')) %#ok<*STREMP>
        % We have a valid file path 
        
        % Fix performance issue: its expensive to call cd so avoid it if we can. A valid path is either 
        % relative or absolute. If pname is absolute then we are done. No need to change current folder to
        % create an absolute path. We check this by prepending './'. If a valid path is absolute then 
        % prepending a './' will make it invalid. JD, Mar 21, 2022
        if ~ispathvalid(['./', pname], 'file')
            cdflag = false;
        else
            cd(p0);
        end
        
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
    
    % Fix performance issue: if current folder is same as the one we started in, then don't
    % redundantly change current folder - its expensive to call cd. JD, Mar 21, 2022
    if cdflag
        cd(currdir);
    end
    return;
end

pnamefull(pnamefull=='/' | pnamefull=='\') = sep;

% Fix performance issue: if current folder is same as the one we started in, then don't
% redundantly change current folder - its expensive to call cd. JD, Mar 21, 2022
if cdflag
    cd(currdir);
end





