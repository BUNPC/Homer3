function varargout = CommitGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CommitGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @CommitGUI_OutputFcn, ...
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



% -------------------------------------------------------------------
function CommitGUI_OpeningFcn(hObject, ~, handles, varargin)
global commit
commit = [];

% Update handles structure
guidata(hObject, handles);

Initialize();

if length(varargin)==2
    commit.repo = varargin{1};
end
if length(varargin)==3
    commit.repo = varargin{1};
    commit.changedFiles{1,1} = varargin{2};
    commit.changedFiles{1,2} = 0;
end
if isempty(varargin)
    commit.repo = filesepStandard_startup(pwd);
end
cd(commit.repo);
set(handles.textRepo, 'string',commit.repo);
set(handles.pushbuttonCommit,'enable','off');
DisplayChangedFiles(handles);
waitForGui_startup(hObject);



% -------------------------------------------------------------------
function varargout = CommitGUI_OutputFcn(~, ~, ~) 
global commit
varargout{1} = commit;



% -------------------------------------------------------------------
function editComment_Callback(hObject, ~, handles)
global commit
commit.comment = get(hObject, 'string');
if isempty(commit.comment)
    set(handles.pushbuttonCommit,'enable','off');
else
    set(handles.pushbuttonCommit,'enable','on');
end


% -------------------------------------------------------------------
function pushbuttonCommit_Callback(hObject, ~, handles)
s = get(hObject, 'string');
if isempty(s)
    return;
end
delete(handles.figure1);



% -------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
Initialize();
delete(handles.figure1);



% -------------------------------------------------------------------
function figure1_DeleteFcn(~, ~, ~)
global commit
for ii = 1:length(commit.hf)
    if ishandle(commit.hf(ii))
        delete(commit.hf(ii));
    end
end



% -------------------------------------------------------------------
function DisplayChangedFiles(handles)
global commit

if ~ispathvalid_startup(commit.repo)
    repo = filesepStandard_startup(pwd);
else
    repo = commit.repo;
end

if isempty(commit.changedFiles)
    [modified, added, deleted, untracked] = gitStatus(repo);
    changedFiles = [modified; added; deleted; untracked];
    for ii = 1:length(changedFiles)
        commit.changedFiles{ii,1} = changedFiles{ii};
        commit.changedFiles{ii,2} = 0;
    end
end

if isempty(commit.changedFiles)
    set(handles.listboxChangedFiles, 'string','Nothing to commit');
    set(handles.editComment, 'enable','off')
else
    set(handles.listboxChangedFiles, 'string',commit.changedFiles(:,1));
    set(handles.editComment, 'enable','on')
end



% -----------------------------------------------------------------
function Initialize()
global commit
if ~isempty(commit)
    commit.repo = '';
    commit.comment = '';
    commit.changedFiles = {};
    commit.currdir = '';
else
    commit = struct('repo','', 'comment','', 'changedFiles',{{}}, 'currdir','', 'hf',-1);
end



% -----------------------------------------------------------------
function listboxChangedFiles_Callback(hObject, ~, handles)
global commit
strs = get(hObject, 'string');
if isempty(strs)
    return;
end

% Get new figure index
for ii = 1:length(commit.hf)
    if ~ishandle(commit.hf(ii))
        break;
    end
end
if ii == length(commit.hf) && ishandle(commit.hf(ii))
    ii = ii+1;
end

idx = get(hObject, 'value');
c = str2cell_startup(strs{idx}, ' ');
filename = deblank(strtrim(c{2}));
checkboxVisible = 'off';
switch(c{1})
    case 'modified:'
        cmd = sprintf('git diff HEAD~1 %s', filename);
        [~, msg] = system(cmd);
    case 'added:'
        msg = showFileContents(filename);
    case 'deleted:'
        msg = sprintf('"%s"  is a deleted file\n', filename);
    case 'untracked:'
        msg = showFileContents(filename, 'untracked');
        checkboxVisible = 'on';
end
hf = figure('Name',sprintf('Changes in %s', filename), 'NumberTitle','off', 'MenuBar','none', 'toolbar','none');
he = uicontrol('parent',hf, 'style','edit', 'string',msg, 'horizontalalignment','left', ...
              'units','normalized', 'position',[.10, .15, .80, .70], ...
              'max',10.0, 'min',0.0);
hp = uicontrol('parent',hf, 'style','pushbutton', 'string','OK', 'fontsize',10, 'fontweight','bold', ...
              'units','normalized', 'position',[.45, .05, .10, .06], 'callback',{@pushbttnOk_Callback, handles});
hc = uicontrol('parent',hf, 'style','checkbox', 'string','Add', 'fontsize',10, 'fontweight','bold', ...
              'units','normalized', 'position',[.10, .88, .10, .06], 'callback',{@checkboxAdd_Callback, filename}, ...
              'visible',checkboxVisible);
commit.hf(ii) = hf;



% -----------------------------------------------------------------
function figure1_CloseRequestFcn(hObject, ~, ~)
Initialize()
delete(hObject);



% -----------------------------------------------------------------
function pushbttnOk_Callback(hObject, ~, handles)
hf = get(hObject, 'parent');
changedFilesStr = GetUntrackedFilesStr();
if ~isempty(changedFilesStr)
    cmd = sprintf('git add %s', changedFilesStr);
    [err, msg] = system(cmd); %#ok<ASGLU>
end
DisplayChangedFiles(handles);
delete(hf);



% -----------------------------------------------------------------
function checkboxAdd_Callback(hObject, ~, filename)
global commit
hf = get(hObject, 'parent');
val = get(hObject, 'value');
for ii = 1:size(commit.changedFiles,1)
    s = str2cell_startup(commit.changedFiles{ii,1}, ':');
    changedFile = deblank(strtrim(s{2}));    
    if strcmp(changedFile, filename)
        commit.changedFiles{ii,2} = val;
        break;
    end
end



% -----------------------------------------------------------------
function editComment_KeyPressFcn(~, ~, handles)
set(handles.pushbuttonCommit,'enable','on');



% -----------------------------------------------------------------
function msg = showFileContents(filename, status)
if ~exist('status', 'var')
    status = 'Added';
end
fid = fopen(filename,'rt');
txt = fread(fid,'char');
fclose(fid);
status(1) = upper(status(1));
msg{1} = sprintf('%s file  "%s"  contents :\n', status, filename);
msg{2} = sprintf('%s\n\n', repmat('=', 1,uint32(4/5*length(msg{1}))));
msg{3} = char(txt(:)');
msg = [msg{:}];



% ---------------------------------------------------------------------------------
function changedFilesStr = GetUntrackedFilesStr()
global commit
changedFilesStr = '';
for ii = 1:size(commit.changedFiles,1)
    if ~commit.changedFiles{ii,2}
        continue;
    end
    s = str2cell_startup(commit.changedFiles{ii,1}, ':');
    changedFiles{ii,1} = deblank(strtrim(s{2}));
    if isempty(changedFilesStr)
        changedFilesStr = changedFiles{ii,1};
    else
        changedFilesStr = sprintf('%s %s', changedFilesStr, changedFiles{ii,1});
    end
end


