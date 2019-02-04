function varargout = procStreamGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @procStreamGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @procStreamGUI_OutputFcn, ...
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



% -------------------------------------------------------------
function varargout = procStreamGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% -------------------------------------------------------------
function procStreamGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global procStreamGui
global hmr

procStreamGui = [];

%%%% Begin parse arguments 

procStreamGui.format = '';
procStreamGui.pos = [];
if ~isempty(hmr)
    procStreamGui.format = hmr.format;
end

% Format argument
if isempty(procStreamGui.format)
    if isempty(varargin)
        procStreamGui.format = 'snirf';
    elseif ischar(varargin{1})
        procStreamGui.format = varargin{1};
    end
end

% Position argument
if isempty(procStreamGui.pos)
    if length(varargin)==1 && ~ischar(varargin{1})
        procStreamGui.pos = varargin{1};
    elseif length(varargin)==2 && ~ischar(varargin{2})
        procStreamGui.pos = varargin{2};
    end
end

%%%% End parse arguments 


% See if we can set the position
p = procStreamGui.pos;
if ~isempty(p)
    set(hObject, 'position', [p(1), p(2), p(3), p(4)]);
end


% Choose default command line output for procStreamGUI
handles.output = hObject;
guidata(hObject, handles);

procStreamGui.iRunPanel = 2;
procStreamGui.iSubjPanel = 3;
procStreamGui.iGroupPanel = 1;
procStreamGui.iReg = {[],[],[]};
procStreamGui.iPanel = 1;

iRunPanel   = procStreamGui.iRunPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iGroupPanel = procStreamGui.iGroupPanel;

procStreamGui.dataTree = LoadDataTree(procStreamGui.format, hmr);
procStreamGui.R = procStreamGui.dataTree.R;

% Update handles structure
LoadRegistry(handles);

% Create tabs for run, subject, and group and move the panels to corresponding tabs. 
htabgroup = uitabgroup('parent',hObject, 'units','normalized', 'position',[.04, .04, .95, .95]);
htabR = uitab('parent',htabgroup, 'title','       Run         ', 'ButtonDownFcn',{@uitabRun_ButtonDownFcn, guidata(hObject)});
htabS = uitab('parent',htabgroup, 'title','       Subject         ', 'ButtonDownFcn',{@uitabSubj_ButtonDownFcn, guidata(hObject)});
htabG = uitab('parent',htabgroup, 'title','       Group         ', 'ButtonDownFcn',{@uitabGroup_ButtonDownFcn, guidata(hObject)});
htab = htabR;

set(handles.uipanelRun, 'parent',htabR, 'position',[0, 0, 1, 1]);
set(handles.uipanelSubj, 'parent',htabS, 'position',[0, 0, 1, 1]);
set(handles.uipanelGroup, 'parent',htabG, 'position',[0, 0, 1, 1]);

setGuiFonts(hObject);

if isempty(procStreamGui.dataTree) || procStreamGui.dataTree.IsEmpty()
    return;
end
procStreamGui.procElem{iRunPanel} = procStreamGui.dataTree.group(1).subjs(1).runs(1).copy;
procStreamGui.procElem{iSubjPanel} = procStreamGui.dataTree.group(1).subjs(1).copy;
procStreamGui.procElem{iGroupPanel} = procStreamGui.dataTree.group(1).copy;
switch(class(procStreamGui.dataTree.currElem.procElem))
    case 'RunClass'
        htab = htabR;
        procStreamGui.iPanel = iRunPanel;
    case 'SubjClass'
        htab = htabS;
        procStreamGui.iPanel = iSubjPanel;
    case 'GroupClass'
        htab = htabG;
        procStreamGui.iPanel = iGroupPanel;
end
set(htabgroup,'SelectedTab',htab);

% Before we exit display current proc stream by default
LoadProcStream(handles);


% -------------------------------------------------------------
function LoadRegistry(handles)
global procStreamGui
R = procStreamGui.R;
if isempty(R) || R.IsEmpty()
    return;
end

iGroupPanel = procStreamGui.iGroupPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iRunPanel   = procStreamGui.iRunPanel;

procStreamGui.funcNamesGroup = R.funcReg(R.IdxGroup).GetFuncNames();
procStreamGui.funcNamesSubj = R.funcReg(R.IdxSubj).GetFuncNames();
procStreamGui.funcNamesRun = R.funcReg(R.IdxRun).GetFuncNames();

set(handles.listboxFuncReg(iGroupPanel),'string',procStreamGui.funcNamesGroup);
set(handles.listboxFuncReg(iSubjPanel),'string',procStreamGui.funcNamesSubj);
set(handles.listboxFuncReg(iRunPanel),'string', procStreamGui.funcNamesRun);
    


% --------------------------------------------------------------------
function LoadProcStream(handles, reload)
global procStreamGui

iGroupPanel = procStreamGui.iGroupPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iRunPanel   = procStreamGui.iRunPanel;

if ~exist('reload','var')
    reload=false;
end

if reload
    procStreamGui.procElem{iRunPanel} = procStreamGui.dataTree.group(1).subjs(1).runs(1).copy;
    procStreamGui.procElem{iSubjPanel} = procStreamGui.dataTree.group(1).subjs(1).copy;
    procStreamGui.procElem{iGroupPanel} = procStreamGui.dataTree.group(1).copy;
end

for iPanel=1:3
    procElem = procStreamGui.procElem{iPanel};
    procInput = procElem.procStream.input;
    nFcall = procInput.GetFuncCallNum();
    fcallnames = cell(nFcall,1);
    for iFcall=1:nFcall
        fcallnames{iFcall} = procInput.GetFuncCallName(iFcall);
    end
    set(handles.listboxFuncProcStream(iPanel),'string',fcallnames);
end


% -------------------------------------------------------------
function listboxFuncReg_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;

ii = get(hObject,'value');
if isempty(ii)
    return;
end

set(handles.listboxFuncReg(iPanel),'value',ii);
foos = procStreamHelpLookup(ii);
set(handles.textHelp(iPanel),'string',foos);


% -------------------------------------------------------------
function listboxFuncProcStream_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;

ii = get(hObject,'value');
if isempty(ii)
    return;
end

funcProcStream = get(handles.listboxFuncProcStream(iPanel),'string');
foos = procStreamHelpLookup(funcProcStream{ii});
set(handles.textHelp(iPanel),'string',foos);


% -------------------------------------------------------------
function pushbuttonAddFunc_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

iFunc = get(handles.listboxFuncReg(iPanel),'value');
iFcall = get(handles.listboxFuncProcStream(iPanel),'value');



% -------------------------------------------------------------
function pushbuttonDeleteFunc_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

n = length(iReg);
if n<1
    return
end

iPS = get(handles.listboxFuncProcStream(iPanel),'value');
if n>1
    iRegTmp = iReg;
    iRegTmp(iPS) = [];
    iPS2 = max(iPS-1,1);
else
    iRegTmp = [];
    iPS2 = 1;
end
iReg = iRegTmp;

procStreamGui.iReg{iPanel} = iReg;
updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonMoveUp_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

iPS = get(handles.listboxFuncProcStream(iPanel),'value');
if iPS == 1
    return
end

iRegTmp = iReg;
iRegTmp([iPS-1 iPS]) = iReg([iPS iPS-1]);
iPS2 = max(iPS-1,1);
iReg = iRegTmp;

procStreamGui.iReg{iPanel} = iReg;
updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonMoveDown_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

iPS = get(handles.listboxFuncProcStream(iPanel),'value');
n = length(iReg);
if iPS == n
    return
end

iRegTmp = iReg;
iRegTmp([iPS iPS+1]) = iReg([iPS+1 iPS]);
iPS2 = iPS+1;
iReg = iRegTmp;

procStreamGui.iReg{iPanel} = iReg;
updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonLoad_Callback(hObject, eventdata, handles)
global procStreamGui

reload=false;

ch = menu('Load current processing stream or config file?','Current processing stream','Config file','Cancel');
if ch==3
    return;
end
if ch==1
    reload = true;
elseif ch==2
    % load cfg file
    [filename,pathname] = uigetfile( '*.cfg', 'Process Options Config File');
    if filename == 0
        return;
    end    
end
for iPanel=1:3
    procElem = procStreamGui.procElem{iPanel};
    if ch==2
        fid = fopen([pathname,filename]);
        procElem.procStream.input.fcalls = FuncCallClass().empty();
        procElem.procStream.input.ParseFile(fid, class(procElem));
        fclose(fid);
    end
end
LoadProcStream(handles, reload);





% -------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global procStreamGui
iReg        = procStreamGui.iReg;
iRunPanel   = procStreamGui.iRunPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iGroupPanel = procStreamGui.iGroupPanel;
procElem    = procStreamGui.procElem;


% -------------------------------------------------
function helpstr = procStreamHelpLookup(name)
global procStreamGui

helpstr = '';

iPanel = procStreamGui.iPanel;
R = procStreamGui.R;
if isempty(R) || R.IsEmpty()
    return;
end

iGroupPanel = procStreamGui.iGroupPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iRunPanel   = procStreamGui.iRunPanel;

idx=[];
switch(iPanel)
    case iGroupPanel
        idx = R.IdxGroup;
    case iSubjPanel
        idx = R.IdxSubj;
    case iRunPanel
        idx = R.IdxRun;
end 
if isempty(idx) || idx>length(R.funcReg)
    return;
end
helpstr = R.funcReg(idx).GetFuncHelp(name);


% --------------------------------------------------------------------
function uitabRun_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui

procStreamGui.iPanel = procStreamGui.iRunPanel;


% --------------------------------------------------------------------
function uitabSubj_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui

procStreamGui.iPanel = procStreamGui.iSubjPanel;


% --------------------------------------------------------------------
function uitabGroup_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui

procStreamGui.iPanel = procStreamGui.iGroupPanel;


% -------------------------------------------------------------
function updateProcStreamList(handles,idx)
global procStreamGui
iPanel = procStreamGui.iPanel;

% set(handles.listboxFuncProcStream(iPanel),'string',foos)
% set(handles.listboxFuncProcStream(iPanel),'value',idx)



