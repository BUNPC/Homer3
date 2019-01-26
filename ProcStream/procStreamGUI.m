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

% Update handles structure
func = procStreamReg2ProcFunc('run');
[fcallIn, fcall, fcallOut] = fillListboxWithRegistry(func);
set(handles.listboxFunctions(iRunPanel),'string',fcall)
set(handles.listboxFuncArgIn(iRunPanel),'string',fcallIn)
set(handles.listboxFuncArgOut(iRunPanel),'string',fcallOut)

func = procStreamReg2ProcFunc('subj');
[fcallIn, fcall, fcallOut] = fillListboxWithRegistry(func);
set(handles.listboxFunctions(iSubjPanel),'string',fcall)
set(handles.listboxFuncArgIn(iSubjPanel),'string',fcallIn)
set(handles.listboxFuncArgOut(iSubjPanel),'string',fcallOut)

func = procStreamReg2ProcFunc('group');
[fcallIn, fcall, fcallOut] = fillListboxWithRegistry(func);
set(handles.listboxFunctions(iGroupPanel),'string',fcall)
set(handles.listboxFuncArgIn(iGroupPanel),'string',fcallIn)
set(handles.listboxFuncArgOut(iGroupPanel),'string',fcallOut)

% Create tabs for run, subject, and group and move the panels to corresponding tabs. 
htabgroup = uitabgroup('parent',hObject, 'units','normalized', 'position',[.04, .04, .95, .95]);
htabR = uitab('parent',htabgroup, 'title','       Run         ', 'ButtonDownFcn',{@uitabRun_ButtonDownFcn, guidata(hObject)});
htabS = uitab('parent',htabgroup, 'title','       Subject         ', 'ButtonDownFcn',{@uitabSubj_ButtonDownFcn, guidata(hObject)});
htabG = uitab('parent',htabgroup, 'title','       Group         ', 'ButtonDownFcn',{@uitabGroup_ButtonDownFcn, guidata(hObject)});
htab = htabR;

set(handles.uipanelRun, 'parent',htabR, 'position',[0, 0, 1, 1]);
set(handles.uipanelSubj, 'parent',htabS, 'position',[0, 0, 1, 1]);
set(handles.uipanelGroup, 'parent',htabG, 'position',[0, 0, 1, 1]);

procStreamGui.dataTree = LoadDataTree(procStreamGui.format, hmr);
if ~isempty(procStreamGui.dataTree)
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
else
    procStreamGui.procElem{iRunPanel} = RunClass();
    procStreamGui.procElem{iSubjPanel} = SubjClass();
    procStreamGui.procElem{iGroupPanel} = GroupClass();
end
set(htabgroup,'SelectedTab',htab);
getHelp(handles);
setGuiFonts(hObject);



% -------------------------------------------------------------
function [fcallIn, fcall, fcallOut] = fillListboxWithRegistry(func)
for iFunc = 1:length(func)
    % parse input parameters
    p = [];
    sargin = '';
    for iP = 1:func(iFunc).nParam
        if ~func(iFunc).nParamVar
            p{iP} = func(iFunc).paramVal{iP};
        else
            p{iP}.name = func(iFunc).param{iP};
            p{iP}.val = func(iFunc).paramVal{iP};
        end
        if length(func(iFunc).argIn)==1 & iP==1
            sargin = sprintf('%sp{%d}',sargin,iP);
        else
            sargin = sprintf('%s,p{%d}',sargin,iP);
        end
    end
    
    % set up output format
    sargout = func(iFunc).argOut;
    for ii=1:length(func(iFunc).argOut)
        if sargout(ii)=='#'
            sargout(ii) = ' ';
        end
    end

    % call function
    fcall{iFunc} = sprintf( '%s      = %s%s%s);', sargout, func(iFunc).name, func(iFunc).argIn, sargin );
    fcallOut{iFunc} = sprintf( '%s', sargout);
    fcall{iFunc} = sprintf( '%s',  func(iFunc).name);
    fcallIn{iFunc} = sprintf( '%s%s)', func(iFunc).argIn, sargin );
end
    
    

% -------------------------------------------------------------
function varargout = procStreamGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% -------------------------------------------------------------
function listboxFunctions_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;

ii = get(hObject,'value');
set(handles.listboxFuncArgIn(iPanel),'value',ii);
set(handles.listboxFuncArgOut(iPanel),'value',ii);

foos = procStreamHelpLookupByIndex(ii, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------------------
function listboxFuncArgOut_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;

ii = get(hObject,'value');
set(handles.listboxFuncArgIn(iPanel),'value',ii);
set(handles.listboxFunctions(iPanel),'value',ii);

foos = procStreamHelpLookupByIndex(ii, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------------------
function listboxFuncArgIn_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;

ii = get(hObject,'value');
set(handles.listboxFunctions(iPanel),'value',ii);
set(handles.listboxFuncArgIn(iPanel),'value',ii);

foos = procStreamHelpLookupByIndex(ii, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------------------
function updateProcStreamList(handles,idx)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

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
global procStreamGui
iPanel = procStreamGui.iPanel;

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
global procStreamGui
iPanel = procStreamGui.iPanel;

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
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

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
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

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
procStreamGui.iReg{iPanel} = iReg;
updateProcStreamList(handles,iPS2);


% -------------------------------------------------------------
function pushbuttonDeleteFunc_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

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

procStreamGui.iReg{iPanel} = iReg;
updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonMoveUp_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

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

procStreamGui.iReg{iPanel} = iReg;
updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function pushbuttonMoveDown_Callback(hObject, eventdata, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
iReg = procStreamGui.iReg{iPanel};

iPS = get(handles.listboxPSFunc(iPanel),'value');
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
iPanel_0 = procStreamGui.iPanel;

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
    iReg = procStreamGui.iReg{iPanel};
    procElem = procStreamGui.procElem{iPanel};
    if ch==2
        fid = fopen([pathname,filename]);
        [procElem.procStream.input, ~] = procStreamParse(fid, procElem);
    end
        
    % Search for procFun functions in procStreamReg
    [err2, iReg] = procStreamErrCheck(procElem);
    if ~all(~err2)
        i=find(err2==1);
        str1 = 'Error in functions\n\n';
        for j=1:length(i)
            str2 = sprintf('%s%s', procElem.procStream.input.func(i(j)).name,'\n');
            str1 = strcat(str1,str2);
        end
        str1 = strcat(str1,'\n');
        str1 = strcat(str1,'Do you want to keep current proc stream or load another file?...');
        ch = menu(sprintf(str1), 'Fix and load this config file','Create and use default config','Cancel');
        if ch==1
            [procElem.procStream.input, err2] = procStreamFixErr(err2, procElem.procStream.input, iReg);
        end
    end
    procStreamGui.iPanel = iPanel;
    procStreamGui.iReg{iPanel} = iReg;
    updateProcStreamList(handles,1);
end

% Return iPanel to value at the beginning of this function 
procStreamGui.iPanel = iPanel_0;
if ch==2
    fclose(fid);
end



% -------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global procStreamGui
iReg        = procStreamGui.iReg;
iRunPanel   = procStreamGui.iRunPanel;
iSubjPanel  = procStreamGui.iSubjPanel;
iGroupPanel = procStreamGui.iGroupPanel;
procElem    = procStreamGui.procElem;

% Get the func at group, subject and run levels
for iPanel=1:length(procElem)
    
    % Build func database of registered functions
    funcReg = procStreamReg2ProcFunc(procElem{iPanel});
    
    % iReg indexes the proc functions in the procStream listboxes on the
    % right in the GUI
    func = funcReg(iReg{iPanel});
    
    param=[];
    for iFunc = 1:length(func)
        for iParam=1:length(func(iFunc).param)
            eval( sprintf('param.%s_%s = func(iFunc).paramVal{iParam};',...
                func(iFunc).name, func(iFunc).param{iParam}) );
        end
    end
    procElem{iPanel}.procStream.input.func = func;
    procElem{iPanel}.procStream.input.param = param;
end

ch = menu('Save to current processing stream or config file?','Current processing stream','Config file','Cancel');
if ch==3
    return;
end
if ch==1
    if isempty(procStreamGui.dataTree)
        return;
    end
    group = procStreamGui.dataTree.group;
    group.CopyProcInputFunc('group', procElem{iGroupPanel}.procStream.input);
    group.CopyProcInputFunc('subj', procElem{iSubjPanel}.procStream.input);
    group.CopyProcInputFunc('run', procElem{iRunPanel}.procStream.input);
else
    [filenm,pathnm] = uiputfile( '*.cfg','Save Config File');
    if filenm==0
        return
    end
    SaveToFile([pathnm,filenm]);
end



% -------------------------------------------------------------
function getHelp(handles)
global procStreamGui
iPanel = procStreamGui.iPanel;

iFunc = get(handles.listboxFunctions(iPanel),'value');
FFunc = get(handles.listboxFunctions(iPanel),'string');

foos = procStreamHelpLookupByIndex(iFunc, handles);
set(handles.textHelp(iPanel),'string',foos);



% -------------------------------------------------
function helpstr = procStreamHelpLookupByIndex(iFunc, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
procElem = procStreamGui.procElem{iPanel};

func = procStreamReg2ProcFunc(procElem);
helpstr = procStreamGenerateHelpStr(func(iFunc).help);



% -------------------------------------------------
function helpstr = procStreamHelpLookupByName(name, handles)
global procStreamGui
iPanel = procStreamGui.iPanel;
procElem = procStreamGui.procElem{iPanel};

helpstr = '';
func = procStreamReg2ProcFunc(procElem);
match=0;
for ii=1:length(func)
    if strcmp(name, func(ii).name)
        match=1;
        break;
    end
end
if ~match
    return;
end
helpstr = procStreamGenerateHelpStr(func(ii).help);



% ----------------------------------------------
function helpstr = procStreamGenerateHelpStr(help)

helpstr = '';
helpstr = sprintf('%s%s\n', helpstr, help.usage);
helpstr = sprintf('%s%s\n', helpstr, help.nameUI);
helpstr = sprintf('%s%s\n', helpstr, 'DESCRIPTION:');
helpstr = sprintf('%s%s\n', helpstr, help.genDescr);
helpstr = sprintf('%s%s\n', helpstr, 'INPUT:');
helpstr = sprintf('%s%s', helpstr, help.argInDescr);
for iParam=1:length(help.paramDescr)
    helpstr = sprintf('%s%s', helpstr, help.paramDescr{iParam});
end
helpstr = sprintf('%s\n', helpstr);
helpstr = sprintf('%s%s\n', helpstr, 'OUPUT:');
helpstr = sprintf('%s%s\n', helpstr, help.argOutDescr);



% --------------------------------------------------------------------
function uitabRun_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui

procStreamGui.iPanel = procStreamGui.iRunPanel;
getHelp(handles);



% --------------------------------------------------------------------
function uitabSubj_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui

procStreamGui.iPanel = procStreamGui.iSubjPanel;
getHelp(handles);



% --------------------------------------------------------------------
function uitabGroup_ButtonDownFcn(hObject, eventdata, handles)
global procStreamGui

procStreamGui.iPanel = procStreamGui.iGroupPanel;
getHelp(handles);



% --------------------------------------------------------------------
function SaveToFile(filenm)
global procStreamGui
procElem = procStreamGui.procElem;

fid = fopen(filenm,'w');
for iPanel=1:length(procElem)
    fprintf( fid, '%% %s\n', procElem{iPanel}.type );    
    func = procElem{iPanel}.procStream.input.func;
    for iFunc=1:length(func)

        fprintf( fid, '@ %s %s %s',...
            func(iFunc).name, func(iFunc).argOut, ...
            func(iFunc).argIn );
        for iParam=1:func(iFunc).nParam
            fprintf( fid,' %s', func(iFunc).param{iParam} );
            
            foos = func(iFunc).paramFormat{iParam};
            boos = sprintf( foos, func(iFunc).paramVal{iParam} );
            for ii=1:length(foos)
                if foos(ii)==' '
                    foos(ii) = '_';
                end
            end
            for ii=1:length(boos)
                if boos(ii)==' '
                    boos(ii) = '_';
                end
            end
            if ~strcmp(func(iFunc).param{iParam},'*')
                fprintf( fid,' %s %s', foos, boos );
            end
        end
        if func(iFunc).nParamVar>0
            fprintf( fid,' *');
        end
        fprintf( fid, '\n' );        
    end
    fprintf( fid, '\n' );
end
fclose(fid);

