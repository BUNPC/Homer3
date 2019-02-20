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
handles.updateptr = @procStreamGUI_Update;
handles.closeptr = [];
varargout{1} = handles;


% -------------------------------------------------------------
function procStreamGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global procStreamGui
global hmr

% Choose default command line output for procStreamGUI
handles.output = hObject;
guidata(hObject, handles);

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
procStreamGui.version = get(hObject, 'name');

procStreamGui.iRunPanel = 2;
procStreamGui.iSubjPanel = 3;
procStreamGui.iGroupPanel = 1;
procStreamGui.iPanel = 1;

iRunPanel   = procStreamGui.iRunPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iGroupPanel = procStreamGui.iGroupPanel;

procStreamGui.dataTree = LoadDataTree(procStreamGui.format, hmr);
procStreamGui.funcReg = [];

% Current proc stream listbox strings for the 3 panels
procStreamGui.listPsUsage = StringsClass().empty();

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

if procStreamGui.dataTree.IsEmpty()
    return;
end
procStreamGui.procElem{iRunPanel} = procStreamGui.dataTree.group(1).subjs(1).runs(1).copy;
procStreamGui.procElem{iSubjPanel} = procStreamGui.dataTree.group(1).subjs(1).copy;
procStreamGui.procElem{iGroupPanel} = procStreamGui.dataTree.group(1).copy;
switch(class(procStreamGui.dataTree.currElem))
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

% Update handles structure
LoadRegistry(handles);

% Before we exit display current proc stream by default
LoadProcStream(handles);




% -------------------------------------------------------------
function LoadRegistry(handles)
global procStreamGui

iGroupPanel = procStreamGui.iGroupPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iRunPanel   = procStreamGui.iRunPanel;
reg         = procStreamGui.dataTree.reg;
if reg.IsEmpty()
    return;
end

funcReg(iGroupPanel) = reg.funcReg(reg.IdxGroup);
funcReg(iSubjPanel) = reg.funcReg(reg.IdxSubj);
funcReg(iRunPanel) = reg.funcReg(reg.IdxRun);
procStreamGui.funcReg = funcReg;

funcReg = procStreamGui.funcReg;
for iPanel=1:length(procStreamGui.procElem)
    set(handles.listboxFuncReg(iPanel),'string',funcReg(iPanel).GetFuncNames());
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    funcname = funcReg(iPanel).GetFuncName(iFunc);
    set(handles.listboxUsageOptions(iPanel),'string',funcReg(iPanel).GetUsageNames(funcname));
    set(handles.listboxUsageOptions(iPanel), 'value',1);
    LookupHelp(iFunc, handles);
end



% --------------------------------------------------------------------
function LoadProcStream(handles, reload)
global procStreamGui

iGroupPanel = procStreamGui.iGroupPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iRunPanel   = procStreamGui.iRunPanel;
listPsUsage = procStreamGui.listPsUsage;
funcReg     = procStreamGui.funcReg;

if isempty(funcReg)
    return;
end

if ~exist('reload','var')
    reload=false;
end
if reload
    procStreamGui.procElem{iRunPanel} = procStreamGui.dataTree.group(1).subjs(1).runs(1).copy;
    procStreamGui.procElem{iSubjPanel} = procStreamGui.dataTree.group(1).subjs(1).copy;
    procStreamGui.procElem{iGroupPanel} = procStreamGui.dataTree.group(1).copy;
end

% Create 3 strings objects for run , subject and group: this is
% what will be the current proc stream listbox strings for the 3 panels
if isempty(listPsUsage)
    listPsUsage(length(procStreamGui.procElem)) = StringsClass();
end
for iPanel=1:length(procStreamGui.procElem)
    listPsUsage(iPanel).Initialize();    
    procInput = procStreamGui.procElem{iPanel}.procStream.input;
    for iFcall=1:procInput.GetFuncCallNum()
        fname     = procInput.fcalls(iFcall).GetName();
        fcallname = funcReg(iPanel).GetUsageName(procInput.fcalls(iFcall));
        
        % Line up the procStream entries into 2 columns: func name and func call name, so it's cleares
        listPsUsage(iPanel).Insert(sprintf('%s: %s', fname, fcallname));
    end
    listPsUsage(iPanel).Tabularize();
    set(handles.listboxFuncProcStream(iPanel),'string',listPsUsage(iPanel).Get());
end
procStreamGui.listPsUsage = listPsUsage;



% -------------------------------------------------------------
function listboxFuncReg_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
funcReg = procStreamGui.funcReg;

if ~isempty(eventdata) && ~isobject(eventdata)
    set(hObject, 'value',eventdata);
end
    
ii = get(hObject,'value');
if isempty(ii)
    return;
end
funcnames = get(hObject,'string');
if isempty(funcnames)
    return
end
usagenames = funcReg(iPanel).GetUsageNames(funcnames{ii});
iUsage = get(handles.listboxUsageOptions(iPanel), 'value');
if iUsage>length(usagenames)
    iUsage = length(usagenames);
end
set(handles.listboxUsageOptions(iPanel), 'value', iUsage);
set(handles.listboxUsageOptions(iPanel), 'string', usagenames);
LookupHelp(ii, handles);



% -------------------------------------------------------------
function listboxFuncProcStream_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
listPsUsage = procStreamGui.listPsUsage;

ii = get(hObject,'value');
if isempty(ii)
    return;
end
usagename = listPsUsage(iPanel).GetVal(ii);
if isempty(usagename) || ~ischar(usagename)
    return;
end
LookupHelpFuncCall(usagename, handles);



% -------------------------------------------------------------
function listboxUsageOptions_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;

usagenames = get(hObject,'string');
iUsage = get(hObject,'value');
if isempty(iUsage)
    return;
end
iFunc      = get(handles.listboxFuncReg(iPanel),'value');
funcnames  = get(handles.listboxFuncReg(iPanel),'string');
usagename  = sprintf('%s: %s', funcnames{iFunc}, usagenames{iUsage});

LookupHelpFuncCall(usagename, handles);



% -------------------------------------------------------------
function pushbuttonAddFunc_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
listPsUsage = procStreamGui.listPsUsage;
procElem = procStreamGui.procElem;
type = procElem{iPanel}.type;

iFunc      = get(handles.listboxFuncReg(iPanel),'value');
funcnames  = get(handles.listboxFuncReg(iPanel),'string');
iUsage     = get(handles.listboxUsageOptions(iPanel),'value');
usagenames = get(handles.listboxUsageOptions(iPanel),'string');

if isempty(funcnames)
    msg{1} = sprintf('There are no %s-level registry functions to choose from.\n', type);
    msg{2} = sprintf('Please add %s-level functions to registry', type);
    menu([msg{:}],'OK');
    return;
end

fcallselect = sprintf('%s: %s', funcnames{iFunc}, usagenames{iUsage});

iFcall = get(handles.listboxFuncProcStream(iPanel),'value');

if listPsUsage(iPanel).IsMember(fcallselect, ':')
    menu('This usage already exist in processing stream. Each usage entry in processing stream must be unique.','OK')
    return;
end
listPsUsage(iPanel).Insert(fcallselect, iFcall, 'before');
listPsUsage(iPanel).Tabularize();
updateProcStreamListbox(handles,iPanel);
uicontrol(handles.listboxFuncProcStream(iPanel));



% -------------------------------------------------------------
function pushbuttonDeleteFunc_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
listPsUsage = procStreamGui.listPsUsage;

if isempty(listPsUsage)
    menu('Processing stream is empty. Please load or create a processing stream before using Delete button.', 'OK');
    return;
end

iFcall = get(handles.listboxFuncProcStream(iPanel), 'value');
listPsUsage(iPanel).Delete(iFcall);
updateProcStreamListbox(handles,iPanel);
uicontrol(handles.listboxFuncProcStream(iPanel));



% -------------------------------------------------------------
function pushbuttonMoveUp_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
listPsUsage = procStreamGui.listPsUsage;

if isempty(listPsUsage)
    menu('Processing stream is empty. Please load or create a processing stream before using Move Up button.', 'OK');
    return;
end


iFcall = get(handles.listboxFuncProcStream(iPanel),'value');
if iFcall == 0
    return
end
listPsUsage(iPanel).Move(iFcall, iFcall-1);
if iFcall>1
    iFcall=iFcall-1;
end
set(handles.listboxFuncProcStream(iPanel), 'value',iFcall)
set(handles.listboxFuncProcStream(iPanel), 'string',listPsUsage(iPanel).Get())
uicontrol(handles.listboxFuncProcStream(iPanel));



% -------------------------------------------------------------
function pushbuttonMoveDown_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
listPsUsage = procStreamGui.listPsUsage;

if isempty(listPsUsage)
    menu('Processing stream is empty. Please load or create a processing stream before using Move Down button.', 'OK');
    return;
end

iFcall = get(handles.listboxFuncProcStream(iPanel),'value');
if iFcall == 0
    return
end
listPsUsage(iPanel).Move(iFcall, iFcall+1);
if iFcall<listPsUsage(iPanel).GetSize()
    iFcall = iFcall+1;
end
set(handles.listboxFuncProcStream(iPanel), 'value',iFcall)
set(handles.listboxFuncProcStream(iPanel), 'string',listPsUsage(iPanel).Get())
uicontrol(handles.listboxFuncProcStream(iPanel));



% -------------------------------------------------------------
function pushbuttonLoad_Callback(hObject, eventdata, handles)
global procStreamGui
reg = procStreamGui.dataTree.reg;
procElem = procStreamGui.procElem;

if reg.IsEmpty()
    msg{1} = sprintf('Cannot load processing stream because no user functions are registered.\n');
    msg{2} = sprintf('Please add user functions to registry before loading processing stream.');
    menu([msg{:}],'OK');
    return;
end

q = menu('Load current processing stream or config file?','Current processing stream','Config file','Cancel');
if q==3
    return;
end
reload=false;
if q==1
    reload = true;
elseif q==2
    % load cfg file
    [filename,pathname] = uigetfile( '*.cfg', 'Process Options Config File to Load From?');
    if filename == 0
        return;
    end
    for iPanel=1:length(procElem)
        procElem{iPanel}.LoadProcInputConfigFile([pathname,filename], reg);
    end
end
LoadProcStream(handles, reload);



% -------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global procStreamGui
procElem    = procStreamGui.procElem;
group       = procStreamGui.dataTree.group;
listPsUsage = procStreamGui.listPsUsage;
funcReg     = procStreamGui.funcReg;
iGroupPanel = procStreamGui.iGroupPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iRunPanel   = procStreamGui.iRunPanel;

if isempty(listPsUsage)
    menu('Processing stream is empty. Please load or create a processing stream before saving it.', 'OK');
    return;
end

q = menu('Save to current processing stream or config file?','Current processing stream','Config file','Cancel');
if q==3
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First get the user selection of proc stream function calls from the proc stream listbox 
% (listboxFuncProcStream) and load them into the procElem for all panels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iPanel=1:length(procElem)
    % First clear the existing func call chain for this procElem
    procElem{iPanel}.procStream.input.ClearFcalls();
    
    % Add each listbox selection to the procElem{iPanel}.procStream.input list 
    % of function calls
    for jj=1:listPsUsage(iPanel).GetSize()
        selection = listPsUsage(iPanel).GetVal(jj);
        parts = str2cell(selection,':');
        if length(parts)<2
            fprintf('#%d: %s does not seem to be a valid selection. Skipping ...\n', jj, selection);
            continue;
        end
        funcname = strtrim(parts{1});
        usagename = strtrim(parts{2});
        fcall = funcReg(iPanel).GetFuncCallDecoded(funcname, usagename);
        procElem{iPanel}.procStream.input.Add(fcall);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now save procElem to current procStream or to  a config file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if q==1
    group.CopyFcalls(procElem{iGroupPanel});
    group.CopyFcalls(procElem{iSubjPanel});
    group.CopyFcalls(procElem{iRunPanel});
elseif q==2
    % load cfg file
    [filename,pathname] = uiputfile( '*.cfg', 'Process Options Config File to Save To?');
    if filename == 0
        return;
    end
    for iPanel=1:length(procElem)
        procElem{iPanel}.SaveProcInputConfigFile([pathname,filename]);
    end
end



% -------------------------------------------------
function helptxt = LookupHelp(name, handles)
global procStreamGui
funcReg = procStreamGui.funcReg;
iPanel = procStreamGui.iPanel;

helptxt = '';
if isempty(funcReg)
    return;
end
if ischar(name)
    [~,idx] = funcReg(iPanel).GetFuncName(strtrim(name));
elseif iswholenum(name)&& name>0
    idx = name;
end
helptxt = sprintf('%s\n', funcReg(iPanel).GetFuncHelp(idx));
set(handles.textHelp(iPanel), 'string',helptxt);
set(handles.textHelp(iPanel), 'value',1);



% -------------------------------------------------
function helptxt = LookupHelpFuncCall(usagename, handles)
global procStreamGui
funcReg = procStreamGui.funcReg;
iPanel = procStreamGui.iPanel;

helptxt = '';
foo = str2cell(usagename, ':');
if isempty(foo) || ~iscell(foo) || ~ischar(foo{1})
    return;
end
funcname  = strtrim(foo{1});
fcallname = strtrim(foo{2});

fcallstr = funcReg(iPanel).GetFuncCallStrDecoded(funcname, fcallname);
paramtxt = funcReg(iPanel).GetParamText(funcname);
helptxt = sprintf('%s\n\n%s\n', fcallstr, paramtxt);
set(handles.textHelp(iPanel), 'string',helptxt);
setListboxValueToLast(handles.textHelp(iPanel));



% --------------------------------------------------------------------
function uitabRun_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui
procStreamGui.iPanel = procStreamGui.iRunPanel;
iPanel = procStreamGui.iPanel;

helptxt = get(handles.textHelp(iPanel),'string');
if isempty(helptxt)
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    LookupHelp(iFunc, handles);
end


% --------------------------------------------------------------------
function uitabSubj_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui
procStreamGui.iPanel = procStreamGui.iSubjPanel;
iPanel = procStreamGui.iPanel;

helptxt = get(handles.textHelp(iPanel),'string');
if isempty(helptxt)
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    LookupHelp(iFunc, handles);
end


% --------------------------------------------------------------------
function uitabGroup_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui
procStreamGui.iPanel = procStreamGui.iGroupPanel;
iPanel = procStreamGui.iPanel;

helptxt = get(handles.textHelp(iPanel),'string');
if isempty(helptxt)
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    LookupHelp(iFunc, handles);
end



% --------------------------------------------------------------------
function updateProcStreamListbox(handles, iPanel)
global procStreamGui
listPsUsage = procStreamGui.listPsUsage;

if ~exist('iPanel','var')
    iPanel=1:length(procStreamGui.procElem);
end
for ii=iPanel
    iFcall = get(handles.listboxFuncProcStream(ii),'value');
    if iFcall>listPsUsage(ii).GetSize()
        iFcall = listPsUsage(ii).GetSize();
    end
    if iFcall<1
        iFcall=1;
    end
    set(handles.listboxFuncProcStream(ii), 'value',iFcall)
    set(handles.listboxFuncProcStream(ii), 'string',listPsUsage(ii).Get())    
end


% --------------------------------------------------------------------
function pushbuttonClearProcStream_Callback(hObject, eventdata, handles)
global procStreamGui

for iPanel=1:length(procStreamGui.listPsUsage)
    procStreamGui.listPsUsage(iPanel).Initialize();
    updateProcStreamListbox(handles, iPanel);
end



% --------------------------------------------------------------------
function procStreamGUI_Update(handles)
global procStreamGui


