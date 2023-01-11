function submodules = downloadDependencies(repoParent)
%
% Syntax:
%   downloadDependencies(repoParent, urlroot, branch)
%   downloadDependencies(repoParent, urlroot)
%   downloadDependencies(repoParent)
%   downloadDependencies()
%
% Examples:
%   downloadDependencies()
%   downloadDependencies('c:\users\public\DataTree')
%
%

if ~exist('repoParent','var')
    repoParent = pwd;
end
repoParentFull = fullpath_startup(repoParent);
submodules = parseGitSubmodulesFile(repoParentFull);
gitSubmodulesClone(repoParentFull, false, 'init');



% ------------------------------------------------------------------
function submodules = parseGitSubmodulesFile(repo)
submodules = cell(0,3);

if ~exist('repo','var') || isempty(repo)
    repo = pwd;
end
currdir = pwd;
if repo(end) ~= '/' && repo(end) ~= '\'
    repo = [repo, '/'];
end

filename = [repo, '.gitmodules'];
if ~exist(filename, 'file')
    return;
end
cd(repo);

fid = fopen(filename, 'rt');
strs = textscan(fid, '%s');
strs = strs{1};
kk = 1;
for ii = 1:length(strs)
    if strcmp(strs{ii}, '[submodule')
        jj = 1;
        while ~strcmp(strs{ii+jj}, '[submodule')
            if ii+jj+2>length(strs)
                break;
            end
            if strcmp(strs{ii+jj}, 'path')
                submodules{kk,2} = [pwd, '/', strs{ii+jj+2}];
            end
            if strcmp(strs{ii+jj}, 'path')
                submodules{kk,3} = strs{ii+jj+2};
            end
            if strcmp(strs{ii+jj}, 'url')
                submodules{kk,1} = strs{ii+jj+2};
            end
            jj = jj+1;
        end
        kk = kk+1;
    end
end
fclose(fid);
cd(currdir);



% -------------------------------------------------------------------------
function [errs, msgs] = exeShellCmds(cmds, preview, quiet)
% Change #2
errs = zeros(length(cmds),1) - 1;
msgs = cell(length(cmds),1);

if nargin==0
    return;
end
if ~exist('preview','var')
    preview = false;
end
if ~exist('quiet','var')
    quiet = false;
end
for ii = 1:length(cmds)
    if preview == false
        c = str2cell_startup(cmds{ii}, ' ');
        if strcmp(c{1}, 'cd')
            try
                cd(c{2})
                errs(ii) = 0;
                msgs{ii} = '';
            catch
                errs(ii) = 1;
                msgs{ii} = 'ERROR: folder does not exist or is in use';
            end
        else
            [errs(ii), msgs{ii}] = system(cmds{ii});
        end
    end
    if quiet == false
        fprintf('%s\n', cmds{ii});
    end
end



% ------------------------------------------------------------------------
function [url, cmds, errs, msgs] = gitGetOrigin(repo, preview, quiet)
url = '';
cmds = {};

currdir = pwd;

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end
if ~exist('quiet','var')
    quiet = true;
end

repoParentFull = fullpath_startup(repo,'full');
ii = 1;

cmds{ii,1} = sprintf('cd %s', repoParentFull); ii = ii+1;
cmds{ii,1} = sprintf('git remote -v'); kk = ii;

[errs, msgs] = exeShellCmds(cmds, preview, quiet);

c = str2cell_startup(msgs{kk}, {char(9), char(10), char(13), char(32)}); %#ok<CHARTEN>

for ii = 1:length(c)
    if ~isempty(strfind(c{ii},'http'))
        url = c{ii};
    end
end

cd(currdir);



% -------------------------------------------------------------------------
function [cmds, errs, msgs] = gitSubmodulesClone(repoParent, preview, options)
cmds = {};

if ~exist('repo','var') || isempty(repoParent)
    repoParent = [pwd, '/'];
end
if ~exist('preview','var')
    preview = false;
end
if ~exist('options','var')
    options = 'init';
end
repoParentFull = fullpath_startup(repoParent);
ii = 1;

submodules = parseGitSubmodulesFile(repoParentFull);
url = gitGetOrigin(repoParentFull);
urlroot = fileparts(url);
branch = gitGetBranch(repoParentFull);

cmds{ii,1} = sprintf('cd %s', repoParentFull); ii = ii+1;
for jj = 1:size(submodules,1)
    [~, submodulename] = fileparts(submodules{jj,1});
    submodulepath = [repoParentFull, submodulename];
    urlsubmodule = [urlroot, '/', submodulename];
    if strcmp(options, 'update')
        try
            fprintf('Deleteing %s\n', submodulepath);
            rmdir(submodulepath,'s')
        catch
        end
    end
    if ~exist(submodulepath, 'dir')
        cmds{ii,1} = sprintf('git clone --branch %s %s %s', branch, urlsubmodule, submodulepath); ii = ii+1;
    end
end
[errs, msgs] = exeShellCmds(cmds, preview);




% -------------------------------------------------------------------------
function pname = removeExtraDots_startup(pname)
k = cell(4,3);

% Case 1:
k{1,1} = strfind(pname, '/./');
k{2,1} = strfind(pname, '/.\');
k{3,1} = strfind(pname, '\.\');
k{4,1} = strfind(pname, '\./');
for ii = 1:length(k(:,1))
    for jj = length(k{ii,1}):-1:1
        pname(k{ii,1}(jj)+1:k{ii,1}(jj)+2) = '';
    end
end

% Case 2:
k{1,2} = strfind(pname, '/.');
k{2,2} = strfind(pname, '\.');
for ii = 1:length(k(:,2))
    if ~isempty(k{ii,2})
        if k{ii,2}+1<length(pname)
            continue
        end
        pname(k{ii,2}+1) = '';
    end
end



% -------------------------------------------------------------------------
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



% -------------------------------------------------------------------------
function [C,k] = str2cell_startup(str, delimiters, options)

% Option tells weather to keep leading whitespaces. 
% (Trailing whitespaces are always removed)
if ~exist('options','var')
    options = '';
end

if ~strcmpi(options, 'keepblanks')
    str = strtrim(str);
end
str = deblank(str);

if ~exist('delimiters','var') || isempty(delimiters)
    delimiters{1} = sprintf('\n');
elseif ~iscell(delimiters)
    foo{1} = delimiters;
    delimiters = foo;
end

% Get indices of all the delimiters
k=[];
for kk=1:length(delimiters)
    k = [k, find(str==delimiters{kk})];
end
j = find(~ismember(1:length(str),k));

% The following line seems to hurt performance a little bit. It was 
% meant to preallocate to speed things up but it does not seem to do that.
% C = repmat({blanks(max(diff([k,length(str)])))}, length(k)+1, 1);
C = {};
ii=1; kk=1; 
while ii<=length(j)
    C{kk} = str(j(ii));
    ii=ii+1;
    jj=2;
    while (ii<=length(j)) && ((j(ii)-j(ii-1))==1)
        C{kk}(jj) = str(j(ii));
        jj=jj+1;
        ii=ii+1;
    end
    C{kk}(jj:end)='';
    kk=kk+1;
end
C(kk:end) = [];




% -------------------------------------------------------------------------
function [name, cmds, errs, msgs] = gitGetBranch(repo, quiet)
name = '';
cmds = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('quiet','var') || isempty(quiet)
    quiet = 1;
end

currdir = pwd;

repoFull = fullpath_startup(repo,'full');

ii = 1;
cmds{ii,1} = sprintf('cd %s', repoFull); ii = ii+1;
cmds{ii,1} = sprintf('%sgit branch',setTerminal()); ii = ii+1; kk = ii-1;

[errs, msgs] = exeShellCmds(cmds, false, quiet);

if all(errs==0)
    branches = str2cell_startup(msgs{kk});
    for jj = 1:length(branches)
        if branches{jj}(1)=='*'
            break;
        end
    end
    name = extractBranchName(branches{jj});
end
cd(currdir);




% -----------------------------------------
function b = extractBranchName(b)
b = removeGarbage(b);
k = find(b<43);
b(k) = ''; %#ok<FNDSB>




% -----------------------------------------
function b = removeGarbage(b)

% Remove garbage strings from branch name. Matlab for MAC 
% creates these issues because of peculiar shell environemnt 
if ismac()
    k = [];
    knownGarbage = {
        '[m';
        '[32m';
        };
    for kk = 1:length(knownGarbage)
        j = strfind(b, knownGarbage{kk});
        for jj = 1:length(j)
            k = [k, j(jj):j(jj)+length(knownGarbage{kk})-1]; %#ok<AGROW>
        end
    end
    b(k) = '';
end



% -------------------------------------------------------------------------
function s = setTerminal()
% This is needed on a MAC to execute some shell commands 
% Otherwise the system command executes its own shell that forces the user
% to press Enter key to continue matlab script execution.
s = '';
if ismac()
    s = 'TERM=ansi; ';
end

