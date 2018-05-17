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
global iReg
iReg = [];

% Choose default command line output for procStreamGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

procFunc = procStreamReg2ProcFunc('run');
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
set(handles.listboxFunctions,'string',fcall)
set(handles.listboxFuncArgIn,'string',fcallIn)
set(handles.listboxFuncArgOut,'string',fcallOut)

    
    

% -------------------------------------------------------------
function varargout = procStreamGUI_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;



% -------------------------------------------------------------
function listboxFunctions_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxFuncArgIn,'value',ii);
set(handles.listboxFuncArgOut,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function listboxFuncArgOut_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxFuncArgIn,'value',ii);
set(handles.listboxFunctions,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);




% -------------------------------------------------------------
function listboxFuncArgIn_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxFunctions,'value',ii);
set(handles.listboxFuncArgOut,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function pushbuttonAddFunc_Callback(hObject, eventdata, handles)
global iReg

iFunc = get(handles.listboxFunctions,'value');
iPS = get(handles.listboxPSFunc,'value');

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

updateProcStreamList(handles,iPS2);




% -------------------------------------------------------------
function pushbuttonDeleteFunc_Callback(hObject, eventdata, handles)
global iReg

n = length(iReg);
if n<1
    return
end

iPS = get(handles.listboxPSFunc,'value');

if n>1
    iRegTmp = iReg;
    iRegTmp(iPS) = [];
    iPS2 = max(iPS-1,1);
else
    iRegTmp = [];
    iPS2 = 1;
end
iReg = iRegTmp;

updateProcStreamList(handles,iPS2);




% -------------------------------------------------------------
function pushbuttonMoveUp_Callback(hObject, eventdata, handles)
global iReg

iPS = get(handles.listboxPSFunc,'value');

if iPS == 1
    return
end

FArgOut = get(handles.listboxFuncArgOut,'string');
FArgIn = get(handles.listboxFuncArgIn,'string');
FFunc = get(handles.listboxFunctions,'string');

iRegTmp = iReg;
iRegTmp([iPS-1 iPS]) = iReg([iPS iPS-1]);
iPS2 = max(iPS-1,1);
iReg = iRegTmp;

updateProcStreamList(handles,iPS2);


% -------------------------------------------------------------
function pushbuttonMoveDown_Callback(hObject, eventdata, handles)
global iReg

iPS = get(handles.listboxPSFunc,'value');
n = length(iReg);

if iPS == n
    return
end

iRegTmp = iReg;
iRegTmp([iPS iPS+1]) = iReg([iPS+1 iPS]);
iPS2 = iPS+1;
iReg = iRegTmp;

updateProcStreamList(handles,iPS2);



% -------------------------------------------------------------
function updateProcStreamList(handles,idx)
global iReg

n = length(iReg);
FArgOut = get(handles.listboxFuncArgOut,'string');
FArgIn = get(handles.listboxFuncArgIn,'string');
FFunc = get(handles.listboxFunctions,'string');


foos = [];
for ii = 1:n
    foos{ii} = FArgOut{iReg(ii)};
end
set(handles.listboxPSArgOut,'string',foos)
set(handles.listboxPSArgOut,'value',idx)

foos = [];
for ii = 1:n
    foos{ii} = FArgIn{iReg(ii)};
end
set(handles.listboxPSArgIn,'string',foos)
set(handles.listboxPSArgIn,'value',idx)

foos = [];
for ii = 1:n
    foos{ii} = FFunc{iReg(ii)};
end
set(handles.listboxPSFunc,'string',foos)
set(handles.listboxPSFunc,'value',idx)




% -------------------------------------------------------------
function listboxPSFunc_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxPSArgIn,'value',ii);
set(handles.listboxPSArgOut,'value',ii);

FFunc = get(handles.listboxPSFunc,'string');
foos = procStreamHelpLookupByName(FFunc{ii});
set(handles.textHelp,'string',foos);




% -------------------------------------------------------------
function listboxPSArgOut_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxPSArgIn,'value',ii);
set(handles.listboxPSFunc,'value',ii);

foos = procStreamHelpLookupByIndex(ii);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function listboxPSArgIn_Callback(hObject, eventdata, handles)
ii = get(hObject,'value');
set(handles.listboxPSFunc,'value',ii);
set(handles.listboxPSArgOut,'value',ii);

FFunc = get(handles.listboxPSFunc,'string');
foos = procStreamHelpLookupByName(FFunc{ii});
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global iReg
global hmr

procElem = hmr.currElem.procElem;
group = hmr.group;

% Build func database of registered functions
procFuncReg = procStreamReg2ProcFunc(procElem);
procFunc = procFuncReg(iReg);

ch = menu('Save to current processing stream or config file?','Current processing stream','Config file');
if ch==1
    procParam=[];
    for iFunc = 1:length(procFunc)
        for iParam=1:length(procFunc(iFunc).funcParam)
                eval( sprintf('procParam.%s_%s = procFunc(iFunc).funcParamVal{iParam};',...
                              procFunc(iFunc).funcName, procFunc(iFunc).funcParam{iParam}) );
        end
    end
    procElem.procInput.procFunc = procFunc;
    procElem.procInput.procParam = procParam;    
    group = CopyProcInput(group, procElem);
else
    [filenm,pathnm] = uiputfile( '*.cfg','Save Config File');
    if filenm==0
        return
    end
    procStreamSave([pathnm filenm],procFunc);
end

hmr.group = group;


% -------------------------------------------------------------
function pushbuttonHelp_Callback(hObject, eventdata, handles)
iFunc = get(handles.listboxFunctions,'value');
FFunc = get(handles.listboxFunctions,'string');

foos = procStreamHelpLookupByIndex(iFunc);
set(handles.textHelp,'string',foos);



% -------------------------------------------------------------
function pushbuttonLoad_Callback(hObject, eventdata, handles)
global iReg
global hmr

procElem = hmr.currElem.procElem;

ch = menu('Load current processing stream or config file?','Current processing stream','Config file','Cancel');
if ch==3
    return;
end

if ch==2
    [filename,pathname] = uigetfile( '*.cfg', 'Process Options Config File');
    if filename == 0
        return;
    end

    % load cfg file
    fid = fopen([pathname filename],'r');
    [procElem.procInput, ~] = procStreamParse(fid, procElem);
    fclose(fid);
end

% Search for procFun functions in procStreamReg
[err2, iReg] = procStreamErrCheck(procElem);
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

updateProcStreamList(handles,1);




% -------------------------------------------------
function helpstr = procStreamHelpLookupByIndex(iFunc)
global hmr;

procElem = hmr.currElem.procElem;

procFunc = procStreamReg2ProcFunc(procElem);
helpstr = procStreamGenerateHelpStr(procFunc(iFunc).funcHelp);



% -------------------------------------------------
function helpstr = procStreamHelpLookupByName(funcName)

global hmr;

procElem = hmr.currElem.procElem;

helpstr = '';

procFunc = procStreamReg2ProcFunc(procElem);
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
