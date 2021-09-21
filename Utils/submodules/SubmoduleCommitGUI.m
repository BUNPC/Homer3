function varargout = SubmoduleCommitGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SubmoduleCommitGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SubmoduleCommitGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && ~strcmp(varargin{end},'userargs')
    if varargin{1}(1)=='.'
        varargin{1}(1) = '';
    end
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


% ---------------------------------------------------------------------------------
function EnableDisable(handles, onoff)
global submoduleCommit
if ~exist('onoff','var')
    if isempty(submoduleCommit.submodules)
        set(handles.pushbuttonCommit, 'enable','off')
        set(handles.pushbuttonPush, 'enable','off')
    else
        set(handles.pushbuttonCommit, 'enable','on')
        set(handles.pushbuttonPush, 'enable','on')
    end
else
    set(handles.pushbuttonCommit, 'enable',onoff)
    set(handles.pushbuttonPush, 'enable',onoff)
end
if isempty(submoduleCommit.submodules)
    submodules = {''};
else
    submodules = submoduleCommit.submodules(:,1);
end
set(handles.popupmenuSubmodule, 'string',submodules);
SetRevID(handles);
set(handles.listboxLocalRepositories, 'string',submoduleCommit.repos);
submoduleCommit.branch = gitGetBranch(submoduleCommit.repos{submoduleCommit.iRepo});
set(handles.editBranch, 'string', submoduleCommit.branch)


% ---------------------------------------------------------------------------------
function Initialize()
global submoduleCommit
submoduleCommit = struct('repos',{{}}, 'iRepo',1, 'branch','', 'submodules',{{}}, 'currdir','', ...
                         'cmds',{{}}, 'errs',[], 'msgs',{{}}, ...
                         'cmdsOutputFile',struct('name','','loc',[]));


% ---------------------------------------------------------------------------------
function SubmoduleCommitGUI_OpeningFcn(hObject, ~, handles, varargin)
if nargin < 4
    varargin = {};
end

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

Initialize();

if length(varargin)==0
    repo = pwd;
elseif length(varargin)==1
    repo = varargin{1};
else
    repo = varargin{1};
end

ResetGitOutput();
AddRepo(repo, handles);
EnableDisable(handles);
ShowError([], [], [], handles, 'load');


% ---------------------------------------------------------------------------------
function varargout = SubmoduleCommitGUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;



% ---------------------------------------------------------------------------------
function listboxLocalRepositories_Callback(hObject, eventdata, handles)
global submoduleCommit
if isa(eventdata, 'double')
    set(hObject, 'value', eventdata);
end
repos = get(hObject, 'string');
iRepo = get(hObject, 'value');
repo = filesepStandard_startup(repos{iRepo});
cd(repo);

submoduleCommit.iRepo = iRepo; 

GetSubmodules(repo);
EnableDisable(handles);
ShowError([], [], [], handles, 'load');



% ---------------------------------------------------------------------------------
function err = AddRepo(repo, handles) %#ok<*DEFNU>
global submoduleCommit
err = -1;
GetSubmodules(repo);
if isempty(submoduleCommit.submodules)
    return
end
for ii = 1:length(submoduleCommit.repos)
    if pathscompare_startup(submoduleCommit.repos{ii}, repo)
        msgbox('This repo is already added');
        return;
    end
end
submoduleCommit.repos  = [submoduleCommit.repos, repo]';
submoduleCommit.iRepo = size(submoduleCommit.repos,1);
submoduleCommit.branch = gitGetBranch(repo);
for ii = 1:length(submoduleCommit.repos)
    submoduleCommit.repos{ii} = filesepStandard_startup(submoduleCommit.repos{ii});
end
set(handles.listboxLocalRepositories, 'value', length(submoduleCommit.repos))
set(handles.editBranch, 'string', submoduleCommit.branch)
SetRevID(handles);

cd(submoduleCommit.repos{submoduleCommit.iRepo});

err = 0;


% ---------------------------------------------------------------------------------
function pushbuttonAddLocalRepository_Callback(~, ~, handles) %#ok<*DEFNU>
pname = uigetdir();
if pname == 0
    return;
end

err = AddRepo(pname, handles);

if err==0
    cd(pname);
end

EnableDisable(handles);
ShowError([], [], [], handles, 'load');



% -------------------------------------------------------------------
function pushbuttonCommit_Callback(~, ~, handles)
global submoduleCommit
if isempty(submoduleCommit.submodules)
    return;
end

idx = get(handles.popupmenuSubmodule, 'value');
set(handles.textError, 'string','');
ResetGitOutput();

[cmds, errs, msgs] = gitSubmoduleCommit(submoduleCommit.submodules{idx,1}, submoduleCommit.repos{submoduleCommit.iRepo}, '', get(handles.checkboxPreview, 'value'));
if isempty(cmds)
    msg = sprintf('Nothing to commit for %s ...\n', [submoduleCommit.repos{submoduleCommit.iRepo}, submoduleCommit.submodules{idx,1}]);
    msgbox(msg);
    set(handles.textError, 'string',msg, 'foregroundcolor',[.30, .70, .10]);
    return;
end
if ~isempty(msgs) && strcmp(msgs{1}, 'cancelled')
    return;
end
ShowError(cmds, errs, msgs, handles, 'commit');
submoduleCommit.cmds = cmds;
submoduleCommit.errs = errs;
submoduleCommit.msgs = msgs;
GenGitOutput(cmds);



% ---------------------------------------------------------------------------------
function pushbuttonPush_Callback(~, ~, handles)
global submoduleCommit
idx = get(handles.popupmenuSubmodule, 'value');
set(handles.textError, 'string','');
if all(submoduleCommit.errs == 0) || get(handles.checkboxPreview, 'value')==true
    [cmds, errs, msgs] = gitSubmodulePush(submoduleCommit.submodules{idx,1}, submoduleCommit.repos, get(handles.checkboxPreview, 'value')); %#ok<*ASGLU>
    ShowError(cmds, errs, msgs, handles, 'push');
end
GenGitOutput(cmds);




% ---------------------------------------------------------------------------------
function ResetGitOutput()
global submoduleCommit
pname = which('SubmoduleCommitGUI.m');
[pname, fname, ext] = fileparts(pname);
submoduleCommit.cmdsOutputFile.name = [getAppDir(), 'submoduleUpdate.bat'];
submoduleCommit.cmdsOutputFile.loc  = 0;
if ispathvalid_startup(submoduleCommit.cmdsOutputFile.name)
    delete(submoduleCommit.cmdsOutputFile.name);
end
fclose('all');




% ---------------------------------------------------------------------------------
function GenGitOutput(cmds)
global submoduleCommit
fid = fopen(submoduleCommit.cmdsOutputFile.name, 'at+');
if fid<0
    return
end
fseek(fid, submoduleCommit.cmdsOutputFile.loc, 'bof');
for ii = 1:length(cmds)
    fprintf(fid, '%s\n', cmds{ii});
end
if submoduleCommit.cmdsOutputFile.loc == 0
    submoduleCommit.cmdsOutputFile.loc = ftell(fid);
end
fclose(fid);



% -------------------------------------------------------------------
function pushbuttonExit_Callback(~, ~, handles)
delete(handles.figure1);



% ---------------------------------------------------------------------------------
function popupmenuSubmodule_Callback(~, ~, handles)
SetRevID(handles);



% ---------------------------------------------------------------------------------
function s = GetSubmodules(repo)
global submoduleCommit
s = parseGitSubmodulesFile(repo);
submoduleCommit.submodules = cell(size(s,1),2);
for ii = 1:size(s,1)
    submoduleCommit.submodules{ii,1} = s{ii,3};
    submoduleCommit.submodules{ii,2} = s{ii,1};
end



% ---------------------------------------------------------------------------------
function editBranch_Callback(~, ~, ~)



% ---------------------------------------------------------------------------------
function checkboxPreview_Callback(~, ~, ~)



% ---------------------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
Initialize()
ResetGitOutput();
delete(handles.figure1);



% ---------------------------------------------------------------------------------
function msg = CombineErrMessages(cmds, msgs)
msg = '';
for ii = 1:length(msgs)
    if ~isempty(msgs{ii})
        if isempty(msg)
            msg = sprintf('%s :\n%s', cmds{ii}, msgs{ii});
        else
            msg = sprintf('%s\n%s :\n%s', msg, cmds{ii}, msgs{ii});
        end
    end
end



% ---------------------------------------------------------------------------------
function ShowError(cmds, errs, msgs, handles, action)
global submoduleCommit

if ~exist('action','var') || isempty(action)
    action = 'commit';
end

colSuccess = [.30, .70, .10];
colFailure = [.80, .30, .10];

if isempty(submoduleCommit.submodules) || ~all(errs == 0)
    col = colFailure;
else
    col = colSuccess;
end

if get(handles.checkboxPreview, 'value')
    msg = sprintf('Preview action on. No action taken. Git commands script saved in %s', submoduleCommit.cmdsOutputFile.name);
    set(handles.textError, 'string',msg, 'foregroundcolor',colSuccess);
    return;
end

if strcmp(action, 'load')
    if isempty(submoduleCommit.submodules) || ~all(errs == 0)
        txt = sprintf('ERROR: Current folder is either not a repository or has no submodules.\n');
    else
        txt = sprintf('Repository loaded successfully.\n');
    end
elseif strcmp(action, 'push')
    txt = sprintf('Push:\n');
elseif strcmp(action, 'commit')
    txt = sprintf('Commit:\n');
end

msgs = CombineErrMessages(cmds, msgs);
txt = sprintf('%s\n%s', txt, msgs);

set(handles.textError, 'string',txt, 'foregroundcolor',col);



% -------------------------------------------------------------
function pname = getAppDir()
global submoduleCommit
global namespace
pname = '';
if isempty(namespace)
    foo = filesepStandard_startup(which('SubmoduleCommitGUI.m'));
    pname = fileparts(foo);
else
    idx = [];
    for ii = 1:length(namespace)
        if submoduleCommit.iRepo > length(submoduleCommit.repos)
            return;
        end
        if pathscompare_startup(namespace(ii).pname, submoduleCommit.repos{submoduleCommit.iRepo})
            idx = ii;
            break
        end
    end
    if isempty(idx)
        return;
    end
    pname = namespace(idx).pname;
end



% -----------------------------------------------------------------
function pushbuttonSyncRepositories_Callback(~, ~, handles)
global submoduleCommit

listboxLocalRepositories_Callback(handles.listboxLocalRepositories, 1, handles);
branch = submoduleCommit.branch;

for ii = 1:length(submoduleCommit.repos)
    % Skip primary repo
    if ii == submoduleCommit.iRepo
        continue;
    end
    
    % Error check
    branch2 = gitGetBranch(submoduleCommit.repos{ii});
    q = SyncErrorCheck(submoduleCommit.repos{submoduleCommit.iRepo}, branch, submoduleCommit.repos{ii}, branch2);
    if q == 0 || q == 2
        return
    elseif q == 3
        gitSetBranch(submoduleCommit.repos{ii}, branch);
    end     
    
    % Get submodules of repo we want to sync with primary repo
    submodules = parseGitSubmodulesFile(submoduleCommit.repos{ii});
    for kk = 1:size(submoduleCommit.submodules,1)
        revid = gitSubmoduleRevId(submoduleCommit.repos{submoduleCommit.iRepo}, submoduleCommit.submodules{kk});
        for jj = 1:size(submodules,1)
            if strcmp(submodules{jj,1}, submoduleCommit.submodules{kk,2})                
                [cmds, errs, msgs] = gitSubmoduleRefUpdate(submoduleCommit.repos{ii}, ...
                                                           submodules{jj,3}, ...
                                                           revid, ...
                                                           get(handles.checkboxPreview, 'value'));
                ShowError(cmds, errs, msgs, handles, 'commit');
                break;
            end
        end
    end
end




% -----------------------------------------------------------------
function q = SyncErrorCheck(repo1, branch1, repo2, branch2)
q = -1;
if strcmp(branch1, branch2)
    return
end

[~, repo1] = fileparts(repo1(1:end-1));
[~, repo2] = fileparts(repo2(1:end-1));

msg{1} = sprintf('WARNING: Repository branches do not match ("%s : %s"   vs   "%s : %s").\n', repo1, branch1, repo2, branch2);
msg{2} = sprintf('Attempting to sync submodules of different branches might lead to undesired results. \n');
msg{3} = sprintf('Are you sure you want to continue?');
q = menu([msg{:}], {'YES','NO',sprintf('Checkout "%s : %s" and continue', repo2, branch1)});




% ---------------------------------------------------------------
function SetRevID(handles)
global submoduleCommit
idx = get(handles.popupmenuSubmodule, 'value');
revid = gitSubmoduleRevId(submoduleCommit.repos{submoduleCommit.iRepo}, submoduleCommit.submodules{idx,1});
set(handles.editRevId, 'string', sprintf(' %s ...', revid(1:8)));




% ---------------------------------------------------------------
function pushbuttonPushSyncChanges_Callback(~, ~, handles)
global submoduleCommit

[cmds, errs, msgs] = gitPush(submoduleCommit.repos{submoduleCommit.iRepo}, get(handles.checkboxPreview, 'value'));

