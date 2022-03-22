function [cmds, errs, msgs] = syncSubmodules(repo, options, preview)
%
% Syntax:
%
%   [cmds, errs, msgs] = syncSubmodules()
%   [cmds, errs, msgs] = syncSubmodules(repo)
%   [cmds, errs, msgs] = syncSubmodules(repo, options)
%   [cmds, errs, msgs] = syncSubmodules(repo, options, preview)
%
% Inputs:
%
%   repo:       String type. Location of parent repository. This is the repo that has the built-in
%               copy of the libraries. Default if argumenty not supplied is
%               the current folder
%
%   options:    String argument with the possible values: {'init' | 'update'}
%               'init'   - If standalone submodules have already been downloaded then do NOT
%                          download again. Then sync the two libraries.
%               'update' - If standalone submodules have already been downloaded then move 
%                          the current version to submodules.old and download again. Then 
%                          sync the two libraries
%               Default if argument not supplied is 'init'
%
%   preview:    Boolean argument: if true, does not make any changes, default is preview
%
%
% Examples:
%
%   % Next 3 examples will only preview but will not change anything in the destination repo
%
%   syncSubmodules();
%   syncSubmodules(pwd);
%   syncSubmodules(pwd, 'init');
%
%
%   % Next 2 examples will make changes in the destination repo
%
%   syncSubmodules(pwd, 'init', false);
%   syncSubmodules(pwd, 'update', false);
%
%
global synctool

synctool = struct('repoParentFull','', 'repo1',[], 'repo2',[]);

cmds = {};

if ~exist('repo','var') || isempty(repo)
    repo = [pwd, '/'];
end
if ~exist('options','var')
    options = 'init';
end
if ~exist('preview','var')
    preview = true;
end

synctool.repoParentFull = filesepStandard_startup(repo,'full');
ii = 1;

submodules = parseGitSubmodulesFile(synctool.repoParentFull);
[cmds, errs, msgs] = gitSubmodulesClone(synctool.repoParentFull);

fprintf('\n');

cmds{ii,1} = sprintf('cd %s', synctool.repoParentFull); ii = ii+1;
for jj = 1:size(submodules,1)
    submodulename = getRepos(submodules, jj);
    
    fprintf('Synching "%s" library:\n', submodulename);
    fprintf('Repo1:  %s, %s\n', synctool.repo1.path, synctool.repo1.datetime.str);
    fprintf('Repo2:  %s, %s\n', synctool.repo2.path, synctool.repo2.datetime.str);
    fprintf('====================================================================\n');
    
    identical = syncAll(synctool.repo1, synctool.repo2, preview);    
    if all(identical==true)
        fprintf('Repos are IDENTICAL\n');
    end    
    fprintf('\n\n')
end



% ----------------------------------------------------------------------------
function  identical = syncAll(repo1, repo2, preview)
identical(1) = sync(repo1, repo2, preview, false);
if any(identical<0)
    return
end
identical(2) = sync(repo2, repo1, preview, true);



% ----------------------------------------------------------------------------
function identical = sync(repo1, repo2, preview, peerlessonly)
identical = true;

if isempty(repo1.datetime.num) || isempty(repo2.datetime.num)
    identical = false;
    return;
end

if ~exist('preview','var')
    preview = false;
end
if ~exist('peerlessonly','var')
    peerlessonly = false;
end
f1_1 = findTypeFiles(repo1.path, '.m');
f1_2 = findTypeFiles(repo1.path, '.txt');
f1_3 = findTypeFiles(repo1.path, '.numberfiles');
f2_1 = findTypeFiles(repo2.path, '.m');
f2_2 = findTypeFiles(repo2.path, '.txt');
f2_3 = findTypeFiles(repo2.path, '.numberfiles');
f1 = [f1_1; f1_2; f1_3];
f2 = [f2_1; f2_2; f2_3];

q = 0;
for kk = 1:length(f2)
    
    if q==2
        break;
    end
    
    foundflag = false;
    [~, fname2,ext2] = fileparts(f2{kk});
    for ll = 1:length(f1)
        [~, fname1,ext1] = fileparts(f1{ll});
        if strcmp([fname1,ext1], [fname2,ext2])
            if ~filesEqual(f2{kk}, f1{ll},'exact') && ~peerlessonly
                if repo1.datetime.num > repo2.datetime.num
                    fsrc = f1{ll};
                    fdst = f2{kk};
                    repo = repo2;
                else
                    fsrc = f2{kk};
                    fdst = f1{ll};
                    repo = repo1;
                end
                identical = false;
                q = makeChange('copy', fsrc, fdst, repo, preview, q);
            end
            foundflag = true;
            break;
        end
    end
    
    if ~foundflag
        
        % If f2 does not exist in repo1 and repo2 last rev is later than
        % repo1, then ADD f2 to repo1
        if repo2.datetime.num > repo1.datetime.num  
            
            p = pathsubtract(f2{kk}, repo2.path);
            q = makeChange('add',  f2{kk}, [repo1.path, p], repo1, preview, q);
            identical = false;
            
        % If f2 does not exist in repo1 and repo2 last rev is earlier than
        % repo1, then delete f2 from repo2
        else
            
            q = makeChange('delete',  [], f2{kk}, repo2, preview, q);
            identical = false;
            
        end
    end
    
end

if q == 2
    identical = -1;
end


% -----------------------------------------------------------------------------------
function submodulename = getRepos(submodules, jj)
global synctool

synctool.repo1 = initRepo();
synctool.repo2 = initRepo();

[~, f, e] = fileparts(submodules{jj,1});
submodulename = [f, e];
r1 = submodules{jj,2};
r2 = [synctool.repoParentFull, 'submodules/', submodulename];

if r1(end)=='\' || r1(end)=='/'
    r1 = r1(1:end-1);
end
if r2(end)=='\' || r2(end)=='/'
    r2 = r2(1:end-1);
end
[date1, dateS1] = getLastRevisionDate(synctool.repoParentFull, r1);
[date2, dateS2] = getLastRevisionDate(r2);
status1 = hasChanges(r1);
status2 = hasChanges(r2);

synctool.repo1 = initRepo([r1, '/'], status1, date1, dateS1);
synctool.repo2 = initRepo([r2, '/'], status2, date2, dateS2);



% -------------------------------------------------------------------------------------
function q = makeChange(action, fsrc, fdst, repo, preview, q)
if q==0
    if repo.status
        msg{1} = sprintf('WARNING: There are uncommitted changes in %s ', repo.path);
        msg{2} = sprintf('which may be lost if you proceed. Do you want to continue?');
        fprintf('%s\n', [msg{:}])
        if preview == false
            q = MenuBox(msg, {'YES','NO'},[],[],'quiet');
        else
            q = 2;
        end
        if q==2
            return;
        end
        
    end
end
switch(lower(action))
    case 'copy'
        if preview == false
            actionstr = 'Copying';
            copyfile(fsrc, fdst)
        else
            actionstr = 'Preview copying';
        end
        fprintf('%s %s to %s\n', actionstr, fsrc, fdst)
    case 'add'
        if preview == false
            actionstr = 'Adding';
            copyfile(fsrc, fdst);
            gitAdd(repo.path, fdst);
        else
            actionstr = 'Preview adding';
        end
        fprintf('%s %s\n', actionstr, fdst);

    case 'delete'
        if preview == false
            actionstr = 'Deleting';
            if preview == false
                gitDelete(repo.path, fdst);
            end
        else
            actionstr = 'Preview deleting';
        end
        fprintf('%s %s\n', actionstr, fdst);
end



% --------------------------------------------------------------------------
function status = hasChanges(repo)
status = 0;
[modified, added, deleted, untracked] = gitStatus(repo);
for ii = 1:length(modified)
    c = str2cell(modified{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end
for ii = 1:length(added)
    c = str2cell(added{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end
for ii = 1:length(deleted)
    c = str2cell(deleted{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end
for ii = 1:length(untracked)
    c = str2cell(untracked{ii}, ' ');
    if isempty(strfind(c{2}, '..'))
        status = 1;
    end        
end



% ------------------------------------------------------------------------
function repo = initRepo(path, status, dateNum, dateStr)
if nargin==0
    repo = struct('path','', 'status',0, 'datetime',struct('num',0, 'str',''));
elseif nargin==3
    repo = struct('path',path, 'status',0, 'datetime',struct('num',dateNum, 'str',dateStr));
elseif nargin==4
    repo = struct('path',path, 'status',status, 'datetime',struct('num',dateNum, 'str',dateStr));
end

