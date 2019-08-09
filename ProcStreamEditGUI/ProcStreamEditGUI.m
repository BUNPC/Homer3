function varargout = ProcStreamEditGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProcStreamEditGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProcStreamEditGUI_OutputFcn, ...
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
function varargout = ProcStreamEditGUI_OutputFcn(hObject, eventdata, handles)
handles.updateptr = @ProcStreamEditGUI_Update;
handles.closeptr = [];
varargout{1} = handles;


% -------------------------------------------------------------
function ProcStreamEditGUI_OpeningFcn(hObject, eventdata, handles, varargin)
%
%  Syntax:
%
%     ProcStreamEditGUI()
%     ProcStreamEditGUI(format)
%     ProcStreamEditGUI(format, pos)
%  
%  Description:
%     GUI used for editing the processing stream chain of function calls. 
%     
%     NOTE: This GUIs input parameters are passed to it either as formal arguments 
%     or through the calling parent GUIs generic global variable, 'maingui'. If it's 
%     the latter, this GUI follows the rule that it accesses the parent GUIs global 
% 	  variable ONLY at startup time, that is, in the function <GUI Name>_OpeningFcn(). 
%
%  Inputs:
%     format:    Which acquisition type of files to load to dataTree: e.g., nirs, snirf, etc
%     pos:       Size and position of last figure session
%
global procStreamEdit
global maingui

% Choose default command line output for ProcStreamEditGUI
handles.output = hObject;
guidata(hObject, handles);

procStreamEdit = [];

%%%% Begin parse arguments 

procStreamEdit.format = '';
procStreamEdit.pos = [];
procStreamEdit.updateParentGui = [];

if ~isempty(maingui)
    procStreamEdit.format = maingui.format;
    procStreamEdit.updateParentGui = maingui.Update;

    % If parent gui exists disable these menu options which only make sense when 
    % running this GUI standalone
    set(handles.menuItemChangeGroup,'visible','off');
    set(handles.menuItemSaveGroup,'visible','off');
end

% Format argument
if isempty(procStreamEdit.format)
    if isempty(varargin)
        procStreamEdit.format = 'snirf';
    elseif ischar(varargin{1})
        procStreamEdit.format = varargin{1};
    end
end

% Position argument
if isempty(procStreamEdit.pos)
    if length(varargin)==1 && ~ischar(varargin{1})
        procStreamEdit.pos = varargin{1};
    elseif length(varargin)==2 && ~ischar(varargin{2})
        procStreamEdit.pos = varargin{2};
    end
end

%%%% End parse arguments 


% See if we can set the position
p = procStreamEdit.pos;
if ~isempty(p)
    set(hObject, 'position', [p(1), p(2), p(3), p(4)]);
end
procStreamEdit.version = get(hObject, 'name');

procStreamEdit.iRunPanel = 2;
procStreamEdit.iSubjPanel = 3;
procStreamEdit.iGroupPanel = 1;
procStreamEdit.iPanel = 1;

iRunPanel   = procStreamEdit.iRunPanel;
iSubjPanel  = procStreamEdit.iSubjPanel;
iGroupPanel = procStreamEdit.iGroupPanel;

procStreamEdit.dataTree = LoadDataTree(procStreamEdit.format, '', maingui);
procStreamEdit.funcReg = [];

% Current proc stream listbox strings for the 3 panels
procStreamEdit.listPsUsage = StringsClass().empty();

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

if procStreamEdit.dataTree.IsEmpty()
    return;
end
procStreamEdit.procElem{iRunPanel} = procStreamEdit.dataTree.group(1).subjs(1).runs(1).copy;
procStreamEdit.procElem{iSubjPanel} = procStreamEdit.dataTree.group(1).subjs(1).copy;
procStreamEdit.procElem{iGroupPanel} = procStreamEdit.dataTree.group(1).copy;
switch(class(procStreamEdit.dataTree.currElem))
    case 'RunClass'
        htab = htabR;
        procStreamEdit.iPanel = iRunPanel;
    case 'SubjClass'
        htab = htabS;
        procStreamEdit.iPanel = iSubjPanel;
    case 'GroupClass'
        htab = htabG;
        procStreamEdit.iPanel = iGroupPanel;
end
set(htabgroup,'SelectedTab',htab);

% Update handles structure
LoadRegistry(handles);

% Before we exit display current proc stream by default
LoadProcStream(handles);




% -------------------------------------------------------------
function LoadRegistry(handles)
global procStreamEdit

iGroupPanel = procStreamEdit.iGroupPanel;
iSubjPanel  = procStreamEdit.iSubjPanel;
iRunPanel   = procStreamEdit.iRunPanel;
reg         = procStreamEdit.dataTree.reg;
if reg.IsEmpty()
    return;
end

funcReg(iGroupPanel) = reg.funcReg(reg.IdxGroup);
funcReg(iSubjPanel) = reg.funcReg(reg.IdxSubj);
funcReg(iRunPanel) = reg.funcReg(reg.IdxRun);
procStreamEdit.funcReg = funcReg;

funcReg = procStreamEdit.funcReg;
for iPanel=1:length(procStreamEdit.procElem)
    set(handles.listboxFuncReg(iPanel),'string',funcReg(iPanel).GetFuncNames());
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    funcname = funcReg(iPanel).GetFuncName(iFunc);
    set(handles.listboxUsageOptions(iPanel),'string',funcReg(iPanel).GetUsageNames(funcname));
    set(handles.listboxUsageOptions(iPanel), 'value',1);
    LookupHelp(iPanel, iFunc, handles);
end



% --------------------------------------------------------------------
function LoadProcStream(handles, reload)
global procStreamEdit

iGroupPanel = procStreamEdit.iGroupPanel;
iSubjPanel  = procStreamEdit.iSubjPanel;
iRunPanel   = procStreamEdit.iRunPanel;
listPsUsage = procStreamEdit.listPsUsage;
funcReg     = procStreamEdit.funcReg;

if isempty(funcReg)
    return;
end

if ~exist('reload','var')
    reload=false;
end
if reload
    procStreamEdit.procElem{iRunPanel} = procStreamEdit.dataTree.group(1).subjs(1).runs(1).copy;
    procStreamEdit.procElem{iSubjPanel} = procStreamEdit.dataTree.group(1).subjs(1).copy;
    procStreamEdit.procElem{iGroupPanel} = procStreamEdit.dataTree.group(1).copy;
end

% Create 3 strings objects for run , subject and group: this is
% what will be the current proc stream listbox strings for the 3 panels
if isempty(listPsUsage)
    listPsUsage(length(procStreamEdit.procElem)) = StringsClass();
end
for iPanel=1:length(procStreamEdit.procElem)
    listPsUsage(iPanel).Initialize();
    procStream = procStreamEdit.procElem{iPanel}.procStream;
    for iFcall=1:procStream.GetFuncCallNum()
        fname     = procStream.fcalls(iFcall).GetName();
        fcallname = funcReg(iPanel).GetUsageName(procStream.fcalls(iFcall));
        
        % Line up the procStream entries into 2 columns: func name and func call name, so it's cleares
        listPsUsage(iPanel).Insert(sprintf('%s: %s', fname, fcallname));
    end
    listPsUsage(iPanel).Tabularize();
    set(handles.listboxFuncProcStream(iPanel),'string',listPsUsage(iPanel).Get());
end
procStreamEdit.listPsUsage = listPsUsage;



% -------------------------------------------------------------
function listboxFuncReg_Callback(hObject, eventdata, handles)
global procStreamEdit
iPanel = procStreamEdit.iPanel;
funcReg = procStreamEdit.funcReg;

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
LookupHelp(iPanel, ii, handles);



% -------------------------------------------------------------
function listboxFuncProcStream_Callback(hObject, eventdata, handles)
global procStreamEdit
iPanel = procStreamEdit.iPanel;
listPsUsage = procStreamEdit.listPsUsage;

ii = get(hObject,'value');
if isempty(ii)
    return;
end
usagename = listPsUsage(iPanel).GetVal(ii);
if isempty(usagename) || ~ischar(usagename)
    return;
end
LookupHelpFuncCall(iPanel, usagename, handles);



% -------------------------------------------------------------
function listboxUsageOptions_Callback(hObject, eventdata, handles)
global procStreamEdit
iPanel = procStreamEdit.iPanel;

usagenames = get(hObject,'string');
iUsage = get(hObject,'value');
if isempty(iUsage)
    return;
end
iFunc      = get(handles.listboxFuncReg(iPanel),'value');
funcnames  = get(handles.listboxFuncReg(iPanel),'string');
usagename  = sprintf('%s: %s', funcnames{iFunc}, usagenames{iUsage});

LookupHelpFuncCall(iPanel, usagename, handles);



% -------------------------------------------------------------
function pushbuttonAddFunc_Callback(hObject, eventdata, handles)
global procStreamEdit
iPanel = procStreamEdit.iPanel;
listPsUsage = procStreamEdit.listPsUsage;
procElem = procStreamEdit.procElem;
type = procElem{iPanel}.type;

iFunc      = get(handles.listboxFuncReg(iPanel),'value');
funcnames  = get(handles.listboxFuncReg(iPanel),'string');
iUsage     = get(handles.listboxUsageOptions(iPanel),'value');
usagenames = get(handles.listboxUsageOptions(iPanel),'string');

if isempty(funcnames)
    msg{1} = sprintf('There are no %s-level registry functions to choose from. ', type);
    msg{2} = sprintf('Please add %s-level functions to registry', type);
    MessageBox([msg{:}]);
    return;
end

fcallselect = sprintf('%s: %s', funcnames{iFunc}, usagenames{iUsage});

iFcall = get(handles.listboxFuncProcStream(iPanel),'value');

if listPsUsage(iPanel).IsMember(fcallselect, ':')
    MessageBox('This usage already exist in processing stream. Each usage entry in processing stream must be unique.','OK')
    return;
end
listPsUsage(iPanel).Insert(fcallselect, iFcall, 'after');
listPsUsage(iPanel).Tabularize();
updateProcStreamListbox(handles,iPanel);
uicontrol(handles.listboxFuncProcStream(iPanel));



% -------------------------------------------------------------
function pushbuttonDeleteFunc_Callback(hObject, eventdata, handles)
global procStreamEdit
iPanel = procStreamEdit.iPanel;
listPsUsage = procStreamEdit.listPsUsage;

if isempty(listPsUsage)
    MessageBox('Processing stream is empty. Please load or create a processing stream before using Delete button.', 'OK');
    return;
end

iFcall = get(handles.listboxFuncProcStream(iPanel), 'value');
listPsUsage(iPanel).Delete(iFcall);
updateProcStreamListbox(handles,iPanel);
uicontrol(handles.listboxFuncProcStream(iPanel));



% -------------------------------------------------------------
function pushbuttonMoveUp_Callback(hObject, eventdata, handles)
global procStreamEdit
iPanel = procStreamEdit.iPanel;
listPsUsage = procStreamEdit.listPsUsage;

if isempty(listPsUsage)
    MessageBox('Processing stream is empty. Please load or create a processing stream before using Move Up button.');
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
global procStreamEdit
iPanel = procStreamEdit.iPanel;
listPsUsage = procStreamEdit.listPsUsage;

if isempty(listPsUsage)
    MessageBox('Processing stream is empty. Please load or create a processing stream before using Move Down button.');
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
global procStreamEdit
reg = procStreamEdit.dataTree.reg;
procElem = procStreamEdit.procElem;

if reg.IsEmpty()
    msg{1} = sprintf('Cannot load processing stream because no user functions are registered. ');
    msg{2} = sprintf('Please add user functions to registry before loading processing stream.');
    MessageBox([msg{:}],'OK');
    return;
end

q = MenuBox('Load current processing stream or config file?',{'Current processing stream','Config file','Cancel'});
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
        procElem{iPanel}.LoadProcStreamConfigFile([pathname,filename]);
    end
end
LoadProcStream(handles, reload);



% -------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global procStreamEdit
procElem    = procStreamEdit.procElem;
group       = procStreamEdit.dataTree.group;
listPsUsage = procStreamEdit.listPsUsage;
funcReg     = procStreamEdit.funcReg;
iGroupPanel = procStreamEdit.iGroupPanel;
iSubjPanel  = procStreamEdit.iSubjPanel;
iRunPanel   = procStreamEdit.iRunPanel;

if isempty(listPsUsage)
    MessageBox('Processing stream is empty. Please load or create a processing stream before saving it.');
    return;
end

q = MenuBox('Save to current processing stream or config file?',{'Current processing stream','Config file','Cancel'});
if q==3
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First get the user selection of proc stream function calls from the proc stream listbox 
% (listboxFuncProcStream) and load them into the procElem for all panels.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iPanel=1:length(procElem)
    % First clear the existing func call chain for this procElem
    procElem{iPanel}.procStream.ClearFcalls();
    
    % Add each listbox selection to the procElem{iPanel}.procStream list 
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
        procElem{iPanel}.procStream.Add(fcall);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now save procElem to current procStream or to  a config file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if q==1
    group.CopyFcalls(procElem{iGroupPanel});
    group.CopyFcalls(procElem{iSubjPanel});
    group.CopyFcalls(procElem{iRunPanel});
    procStreamEdit.updateParentGui('ProcStreamEditGUI');
elseif q==2
    % load cfg file
    [filename,pathname] = uiputfile( '*.cfg', 'Process Options Config File to Save To?');
    if filename == 0
        return;
    end
    for iPanel=1:length(procElem)
        procElem{iPanel}.SaveProcStreamConfigFile([pathname,filename]);
    end
end



% -------------------------------------------------
function helptxt = LookupHelp(iPanel, name, handles)
global procStreamEdit
funcReg = procStreamEdit.funcReg;

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
function helptxt = LookupHelpFuncCall(iPanel, usagename, handles)
global procStreamEdit
funcReg = procStreamEdit.funcReg;

helptxt = '';
foo = str2cell(usagename, ':');
if isempty(foo) || ~iscell(foo) || ~ischar(foo{1})
    return;
end
if length(foo)<2
    set(handles.textHelp(iPanel), 'value',1);
    set(handles.textHelp(iPanel), 'string','Function call was NOT found in Registry.');
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
global procStreamEdit
procStreamEdit.iPanel = procStreamEdit.iRunPanel;
iPanel = procStreamEdit.iPanel;

helptxt = get(handles.textHelp(iPanel),'string');
if isempty(helptxt)
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    LookupHelp(iPanel, iFunc, handles);
end


% --------------------------------------------------------------------
function uitabSubj_ButtonDownFcn(hObject, eventdata, handles)
global procStreamEdit
procStreamEdit.iPanel = procStreamEdit.iSubjPanel;
iPanel = procStreamEdit.iPanel;

helptxt = get(handles.textHelp(iPanel),'string');
if isempty(helptxt)
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    LookupHelp(iPanel, iFunc, handles);
end


% --------------------------------------------------------------------
function uitabGroup_ButtonDownFcn(hObject, eventdata, handles)
global procStreamEdit
procStreamEdit.iPanel = procStreamEdit.iGroupPanel;
iPanel = procStreamEdit.iPanel;

helptxt = get(handles.textHelp(iPanel),'string');
if isempty(helptxt)
    iFunc = get(handles.listboxFuncReg(iPanel),'value');
    LookupHelp(iPanel, iFunc, handles);
end



% --------------------------------------------------------------------
function updateProcStreamListbox(handles, iPanel)
global procStreamEdit
listPsUsage = procStreamEdit.listPsUsage;

if ~exist('iPanel','var')
    iPanel=1:length(procStreamEdit.procElem);
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
global procStreamEdit

for iPanel=1:length(procStreamEdit.listPsUsage)
    procStreamEdit.listPsUsage(iPanel).Initialize();
    updateProcStreamListbox(handles, iPanel);
end



% --------------------------------------------------------------------
function ProcStreamEditGUI_Update(handles)
global procStreamEdit



% --------------------------------------------------------------------
function pushbuttonExit_Callback(hObject, eventdata, handles)
if ishandles(handles.figure)
    delete(handles.figure);
end


% --------------------------------------------------------------------
function menuItemAddFunction_Callback(hObject, eventdata, handles)
global procStreamEdit
reg = procStreamEdit.dataTree.reg;

files = dir([reg.userfuncdir{1}, 'hmr*.m']);
filenames = cell(length(files),1);
for ii=1:length(files)
    [~,filenames{ii}] = fileparts(files(ii).name);
end

funcnames = {};
for ii=1:length(reg.funcReg)
    funcnames = [funcnames; {reg.funcReg(ii).entries.name}'];
end
k = ~ismember(filenames, funcnames);
flst = filenames(k);
idx = listdlg('PromptString','Select Function File to Add to Registry:',...
              'SelectionMode','single',...
              'ListString',flst);
if isempty(idx)
    return;
end         
err = reg.AddEntry(flst{idx});
if err
    MessageBox(sprintf('ERROR: Could not add %s. Function is not valid', flst{idx}), 'ERROR');
    return;
end
LoadRegistry(handles);
reg.Save();



% -------------------------------------------------------------------------------
function menuItemReloadFunction_Callback(hObject, eventdata, handles)
global procStreamEdit
reg = procStreamEdit.dataTree.reg;

funcnames = {};
for ii=1:length(reg.funcReg)
    funcnames = [funcnames; {reg.funcReg(ii).entries.name}'];
end
if isempty(funcnames)
    return;
end
idx = listdlg('PromptString','Select Function File to Reload to Registry:',...
                'SelectionMode','single',...
                'ListString',funcnames);
if isempty(idx)
    return;
end
err = reg.ReloadEntry(funcnames{idx});
if err
    MessageBox(sprintf('ERROR: Could not reload %s. Function no longer valid', funcnames{idx}), 'ERROR');
    return;
end
LoadRegistry(handles);
reg.Save();




% --------------------------------------------------------------------
function menuItemChangeGroup_Callback(hObject, eventdata, handles)
pathname = uigetdir(pwd, 'Select a NIRS data group folder');
if pathname==0
    return;
end
cd(pathname);
ProcStreamEditGUI();



% --------------------------------------------------------------------
function menuItemSaveGroup_Callback(hObject, eventdata, handles)
global procStreamEdit
if ~ishandles(hObject)
    return;
end
procStreamEdit.dataTree.currElem.Save();

