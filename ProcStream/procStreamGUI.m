function varargout = procStreamGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @procStreamGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @procStreamGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end



% -------------------------------------------------------------
function procStreamGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global hmr

iRunPanel = 2;
iSubjPanel = 3;
iGroupPanel = 1;

% Choose default command line output for procStreamGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

procFunc = procStreamReg2ProcFunc('run');
[fcallIn, fcall, fcallOut] = fillListboxWithRegistry(procFunc);
set(handles.listboxFunctions(iRunPanel),'string',fcall)
set(handles.listboxFuncArgIn(iRunPanel),'string',fcallIn)
set(handles.listboxFuncArgOut(iRunPanel),'string',fcallOut)

procFunc = procStreamReg2ProcFunc('Subj');
[fcallIn, fcall, fcallOut] = fillListboxWithRegistry(procFunc);
set(handles.listboxFunctions(iSubjPanel),'string',fcall)
set(handles.listboxFuncArgIn(iSubjPanel),'string',fcallIn)
set(handles.listboxFuncArgOut(iSubjPanel),'string',fcallOut)

procFunc = procStreamReg2ProcFunc('Group');
[fcallIn, fcall, fcallOut] = fillListboxWithRegistry(procFunc);
set(handles.listboxFunctions(iGroupPanel),'string',fcall)
set(handles.listboxFuncArgIn(iGroupPanel),'string',fcallIn)
set(handles.listboxFuncArgOut(iGroupPanel),'string',fcallOut)

% Create tabs for run, subject, and group and move the panels to corresponding tabs. 
htabgroup = uitabgroup('parent',hObject, 'units','normalized', 'position',[.04, .04, .95, .95]);
htabRun = uitab('parent',htabgroup, 'title','       Run         ', 'ButtonDownFcn',{@uitabRun_ButtonDownFcn, guidata(hObject)});
htabSubj = uitab('parent',htabgroup, 'title','       Subject         ', 'ButtonDownFcn',{@uitabSubj_ButtonDownFcn, guidata(hObject)});
htabGroup = uitab('parent',htabgroup, 'title','       Group         ', 'ButtonDownFcn',{@uitabGroup_ButtonDownFcn, guidata(hObject)});

set(handles.uipanelRun, 'parent',htabRun, 'position',[0, 0, 1, 1]);
set(handles.uipanelSubj, 'parent',htabSubj, 'position',[0, 0, 1, 1]);
set(handles.uipanelGroup, 'parent',htabGroup, 'position',[0, 0, 1, 1]);

htab = -1;
switch(hmr.currElem.procElem.type)
    case 'run'
        htab = htabRun;
        iPanel = iRunPanel;
    case 'subj'
        htab = htabSubj;
        iPanel = iSubjPanel;
    case 'group'
        htab = htabGroup;
        iPanel = iGroupPanel;
end
set(htabgroup,'SelectedTab',htab);

% Assign to procElem by value instead of reference - we don't 
% want to change anything in hmr.currElem in this GUI
procElem{iRunPanel} = hmr.group(1).subjs(1).runs(1).copy();
procElem{iSubjPanel} = hmr.group(1).subjs(1).copy();
procElem{iGroupPanel} = hmr.group(1).copy();

setappdata(hObject,'this',struct('iReg',{{[],[],[]}}, ...    % registry indices of the selected procStream functions (as shown in listboxPsFunc lisbox)
                                 'iRunPanel',iRunPanel, ...
                                 'iSubjPanel',iSubjPanel, ...
                                 'iGroupPanel',iGroupPanel, ...
                                 'procElem',{procElem}, ...
                                 'iPanel',iPanel));

getHelp(handles);



% -------------------------------------------------------------
function [fcallIn, fcall, fcallOut] = fillListboxWithRegistry(procFunc)

for iFunc = 1:length(procFunc)
    % parse input parameters
    p = [];
    sargin = '';
    for iP = 1:procFunc(iFunc).nFuncParam
        if ~procFunc(iFunc).nFuncParamVar
            p{iP} = procFunc(iFunc).funcParamVal{iP};
        else
            p{iP}.name = procFunc(iFunc).funcParam{iP};
            p{iP}.val = procFunc(iFunc).funcParamVal{iP};
        end
        if length(procFunc(iFunc).funcArgIn)==1 & iP==1
            sargin = sprintf('%sp{%d}',sargin,iP);
        else
            sargin = sprintf('%s,p{%d}',sargin,iP);
        end
    end
    
    % set up output format
    sargout = procFunc(iFunc).funcArgOut;
    for ii=1:length(procFunc(iFunc).funcArgOut)
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end

    % call function
    fcall{iFunc} = sprintf( '%s      = %s%s%s);', sargout, ...
        procFunc(iFunc).funcName, ...
        procFunc(iFunc).funcArgIn, sargin );
    fcallOut{iFunc} = sprintf( '%s', sargout);
    fcall{iFunc} = sprintf( '%s',  ...
        procFunc(iFunc).funcName);
    fcallIn{iFunc} = sprintf( '%s%s)',  ...
        procFunc(iFunc).funcArgIn, sargin );
end

    
    

% -------------------------------------------------------------
function varargout = procStreamGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;



% -------------------------------------------------------------
function listboxFunctions_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;

ii = get(hObject,'value');
set(handles.listboxFuncArgIn(iPanel),'value',ii);
set(handles.listboxFuncArgOut(iPanel),'value',ii);

foos = procStreamHelpLookupByIndex(ii, handles);
set(handles.textHelp(iPanel),'string',foos);




% -------------------------------------------------------------
function listboxFuncArgOut_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;

ii = get(hObject,'value');
set(handles.listboxFuncArgIn(iPanel),'value',ii);
set(handles.listboxFunctions(iPanel),'value',ii);

foos = procStreamHelpLookupByIndex(ii, handles);
set(handles.textHelp(iPanel),'string',foos);




% -------------------------------------------------------------
function listboxFuncArgIn_Callback(hObject, eventdata, handles)

this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;

ii = get(hObject,'value');
set(handles.listboxFunctions(iPanel),'value',ii);
set(handles.listboxFuncArgIn(iPanel),'value',ii);

foos = procStreamHelpLookupByIndex(ii, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------------------
function updateProcStreamList(handles,idx)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;
iReg = this.iReg{iPanel};

n = length(iReg);
FArgOut = get(handles.listboxFuncArgOut(iPanel),'string');
FArgIn = get(handles.listboxFuncArgIn(iPanel),'string');
FFunc = get(handles.listboxFunctions(iPanel),'string');


foos = [];
for ii = 1:n
    foos{ii} = FArgOut{iReg(ii)};
end
set(handles.listboxPSArgOut(iPanel),'string',foos)
set(handles.listboxPSArgOut(iPanel),'value',idx)

foos = [];
for ii = 1:n
    foos{ii} = FArgIn{iReg(ii)};
end
set(handles.listboxPSArgIn(iPanel),'string',foos)
set(handles.listboxPSArgIn(iPanel),'value',idx)

foos = [];
for ii = 1:n
    foos{ii} = FFunc{iReg(ii)};
end
set(handles.listboxPSFunc(iPanel),'string',foos)
set(handles.listboxPSFunc(iPanel),'value',idx)




% -------------------------------------------------------------
function listboxPSFunc_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;

ii = get(hObject,'value');
if isempty(ii)
    return;
end

set(handles.listboxPSArgIn(iPanel),'value',ii);
set(handles.listboxPSArgOut(iPanel),'value',ii);

FFunc = get(handles.listboxPSFunc(iPanel),'string');
foos = procStreamHelpLookupByName(FFunc{ii}, handles);
set(handles.textHelp(iPanel),'string',foos);




% -------------------------------------------------------------
function listboxPSArgOut_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;

ii = get(hObject,'value');
if isempty(ii)
    return;
end

set(handles.listboxPSArgIn(iPanel),'value',ii);
set(handles.listboxPSFunc(iPanel),'value',ii);

FFunc = get(handles.listboxPSFunc(iPanel),'string');
foos = procStreamHelpLookupByName(FFunc{ii}, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------------------
function listboxPSArgIn_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;

ii = get(hObject,'value');
if isempty(ii)
    return;
end

set(handles.listboxPSArgOut(iPanel),'value',ii);
set(handles.listboxPSFunc(iPanel),'value',ii);

FFunc = get(handles.listboxPSFunc(iPanel),'string');
foos = procStreamHelpLookupByName(FFunc{ii}, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------------------
function pushbuttonAddFunc_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;
iReg = this.iReg{iPanel};

iFunc = get(handles.listboxFunctions(iPanel),'value');
iPS = get(handles.listboxPSFunc(iPanel),'value');

n = length(iReg);
if n>0
    iRegTmp(1:iPS) = iReg(1:iPS);
    iRegTmp(iPS+1) = iFunc;
    iRegTmp((iPS+2):(n+1)) = iReg((iPS+1):n);
    iPS2 = iPS+1;
else
    iRegTmp(1) = iFunc;
    iPS2 = 1;
end
iReg = iRegTmp;

this.iReg{iPanel} = iReg;
setappdata(handles.figure1, 'this', this);

updateProcStreamList(handles,iPS2);


% -------------------------------------------------------------
function pushbuttonDeleteFunc_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;
iReg = this.iReg{iPanel};

n = length(iReg);
if n<1
    return
end

iPS = get(handles.listboxPSFunc(iPanel),'value');

if n>1
    iRegTmp = iReg;
    iRegTmp(iPS) = [];
    iPS2 = max(iPS-1,1);
else
    iRegTmp = [];
    iPS2 = 1;
end
iReg = iRegTmp;

this.iReg{iPanel} = iReg;
setappdata(handles.figure1, 'this', this);

updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonMoveUp_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;
iReg = this.iReg{iPanel};

iPS = get(handles.listboxPSFunc(iPanel),'value');

if iPS == 1
    return
end

FArgOut = get(handles.listboxFuncArgOut(iPanel),'string');
FArgIn = get(handles.listboxFuncArgIn(iPanel),'string');
FFunc = get(handles.listboxFunctions(iPanel),'string');

iRegTmp = iReg;
iRegTmp([iPS-1 iPS]) = iReg([iPS iPS-1]);
iPS2 = max(iPS-1,1);
iReg = iRegTmp;

this.iReg{iPanel} = iReg;
setappdata(handles.figure1, 'this', this);

updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonMoveDown_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;
iReg = this.iReg{iPanel};

iPS = get(handles.listboxPSFunc(iPanel),'value');
n = length(iReg);

if iPS == n
    return
end

iRegTmp = iReg;
iRegTmp([iPS iPS+1]) = iReg([iPS+1 iPS]);
iPS2 = iPS+1;
iReg = iRegTmp;

this.iReg{iPanel} = iReg;
setappdata(handles.figure1, 'this', this);

updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonLoad_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iPanel_0 = this.iPanel;

ch = menu('Load current processing stream or config file?','Current processing stream','Config file','Cancel');
if ch==3
    return;
end

if ch==2
    % load cfg file
    [filename,pathname] = uigetfile( '*.cfg', 'Process Options Config File');
    if filename == 0
        return;
    end    
end


for iPanel=1:3

    iReg = this.iReg{iPanel};
    procElem = this.procElem{iPanel};
    
    if ch==2
        fid = fopen([pathname,filename]);
        [procElem.procInput, ~] = procStreamParse(fid, procElem);
    end
    
    % Search for procFun functions in procStreamReg
    [err2, iReg] = procStreamErrCheck(procElem.type, procElem.procInput);
    if ~all(~err2)
        i=find(err2==1);
        str1 = 'Error in functions\n\n';
        for j=1:length(i)
            str2 = sprintf('%s%s', procElem.procInput.procFunc(i(j)).funcName,'\n');
            str1 = strcat(str1,str2);
        end
        str1 = strcat(str1,'\n');
        str1 = strcat(str1,'Do you want to keep current proc stream or load another file?...');
        ch = menu(sprintf(str1), 'Fix and load this config file','Create and use default config','Cancel');
        if ch==1
            [procElem.procInput, err2] = procStreamFixErr(err2, procElem.procInput, iReg);
        end
    end
    
    this.iPanel = iPanel;
    this.iReg{iPanel} = iReg;
    setappdata(handles.figure1, 'this', this);
    
    updateProcStreamList(handles,1);
    
end

% Return iPanel to value at the beginning of this function 
this.iPanel = iPanel_0;
setappdata(handles.figure1, 'this', this);


if ch==2
    fclose(fid);
end



% -------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
this = getappdata(handles.figure1, 'this');
iReg = this.iReg;
iRunPanel = this.iRunPanel;
iSubjPanel = this.iSubjPanel;
iGroupPanel = this.iGroupPanel;
procElem = this.procElem;


% Get the procFunc at group, subject and run levels
for iPanel=1:length(procElem)
    
    % Build func database of registered functions
    procFuncReg = procStreamReg2ProcFunc(procElem{iPanel}.type);
    
    % iReg indexes the proc functions in the procStream listboxes on the
    % right in the GUI
    procFunc = procFuncReg(iReg{iPanel});
    
    procParam=[];
    for iFunc = 1:length(procFunc)
        for iParam=1:length(procFunc(iFunc).funcParam)
            eval( sprintf('procParam.%s_%s = procFunc(iFunc).funcParamVal{iParam};',...
                procFunc(iFunc).funcName, procFunc(iFunc).funcParam{iParam}) );
        end
    end
    procElem{iPanel}.procInput.procFunc = procFunc;
    procElem{iPanel}.procInput.procParam = procParam;
    
end

ch = menu('Save to current processing stream or config file?','Current processing stream','Config file','Cancel');
if ch==3
    return;
end

if ch==1
    global hmr

    group = hmr.group;
    
    group.CopyProcInput(procElem{iRunPanel}.type, procElem{iRunPanel}.procInput);
    group.CopyProcInput(procElem{iSubjPanel}.type, procElem{iSubjPanel}.procInput);
    group.CopyProcInput(procElem{iGroupPanel}.type, procElem{iGroupPanel}.procInput);
    
else
    [filenm,pathnm] = uiputfile( '*.cfg','Save Config File');
    if filenm==0
        return
    end
    procStreamSave([pathnm,filenm], procElem);
end



% -------------------------------------------------------------
function getHelp(handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;

iFunc = get(handles.listboxFunctions(iPanel),'value');
FFunc = get(handles.listboxFunctions(iPanel),'string');

foos = procStreamHelpLookupByIndex(iFunc, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------
function helpstr = procStreamHelpLookupByIndex(iFunc, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;
procElem = this.procElem{iPanel};

procFunc = procStreamReg2ProcFunc(procElem.type);
helpstr = procStreamGenerateHelpStr(procFunc(iFunc).funcHelp);



% -------------------------------------------------
function helpstr = procStreamHelpLookupByName(funcName, handles)
this = getappdata(handles.figure1, 'this');
iPanel = this.iPanel;
procElem = this.procElem{iPanel};

helpstr = '';

procFunc = procStreamReg2ProcFunc(procElem.type);
match=0;
for ii=1:length(procFunc)
    if strcmp(funcName, procFunc(ii).funcName)
        match=1;
        break;
    end
end

if ~match
    return;
end

helpstr = procStreamGenerateHelpStr(procFunc(ii).funcHelp);



% ----------------------------------------------
function helpstr = procStreamGenerateHelpStr(funcHelp)

helpstr = '';

helpstr = sprintf('%s%s\n', helpstr, funcHelp.usage);
helpstr = sprintf('%s%s\n', helpstr, funcHelp.funcNameUI);
helpstr = sprintf('%s%s\n', helpstr, 'DESCRIPTION:');
helpstr = sprintf('%s%s\n', helpstr, funcHelp.genDescr);
helpstr = sprintf('%s%s\n', helpstr, 'INPUT:');
helpstr = sprintf('%s%s', helpstr, funcHelp.argInDescr);
for iParam=1:length(funcHelp.paramDescr)
    helpstr = sprintf('%s%s', helpstr, funcHelp.paramDescr{iParam});
end
helpstr = sprintf('%s\n', helpstr);
helpstr = sprintf('%s%s\n', helpstr, 'OUPUT:');
helpstr = sprintf('%s%s\n', helpstr, funcHelp.argOutDescr);



% --------------------------------------------------------------------
function uitabRun_ButtonDownFcn(hObject, eventdata, handles)

this = getappdata(handles.figure1, 'this');
this.iPanel = this.iRunPanel;
setappdata(handles.figure1, 'this',this);
getHelp(handles);



% --------------------------------------------------------------------
function uitabSubj_ButtonDownFcn(hObject, eventdata, handles)

this = getappdata(handles.figure1, 'this');
this.iPanel = this.iSubjPanel;
setappdata(handles.figure1, 'this',this);
getHelp(handles);



% --------------------------------------------------------------------
function uitabGroup_ButtonDownFcn(hObject, eventdata, handles)

this = getappdata(handles.figure1, 'this');
this.iPanel = this.iGroupPanel;
setappdata(handles.figure1, 'this',this);
getHelp(handles);
