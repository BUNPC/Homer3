function varargout = stimGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @stimGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && ~strcmp(varargin{end},'userargs')
    if varargin{1}(1)=='.';
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
function stimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global stimGui

handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

if isempty(varargin)
    return;
end
stimGui = varargin{1};
setGuiFonts(hObject);





% -------------------------------------------------------------------
function varargout = stimGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles;


% --------------------------------------------------------------------
function menuItemOpen_Callback(hObject, eventdata, handles)
global stimGui

[filename, pathname] = uigetfile({'*.nirs','*.snirf'}, 'Select a NIRS data file');
if filename==0
    return;
end
stimGui.Load([pathname, filename]);
stimGui.Display();



% --------------------------------------------------------------------
function pushbuttonExit_Callback(hObject, eventdata, handles)
global stimGui

stimGui.Close();


% --------------------------------------------------------------------
function popupmenuConditions_Callback(hObject, eventdata, handles)
global stimGui

conditions = get(hObject, 'string');
idx = get(hObject, 'value');
condition = conditions{idx};
stimGui.SetUitableStimInfo(condition);



%---------------------------------------------------------------------------
function editSelectTpts_Callback(hObject, eventdata, handles)
global stimGui

tPts_select = str2num(get(hObject,'string'));
if isempty(tPts_select)
    return;
end
stimGui.EditSelectTpts(tPts_select);



%---------------------------------------------------------------------------
function uitableStimInfo_CellEditCallback(hObject, eventdata, handles)
global stimGui

data = get(hObject,'data') ;

icond = stimGui.GetConditionIdxFromPopupmenu();

stimGui.dataTree.currElem.procElem.SetStimTpts(icond, data(:,1));
stimGui.dataTree.currElem.procElem.SetStimDuration(icond, data(:,2));
stimGui.dataTree.currElem.procElem.SetStimValues(icond, data(:,3));
r=eventdata.Indices(1);
c=eventdata.Indices(2);
if c==2
    return;
end
stimGui.Display();
stimGui.DisplayGuiMain();
figure(stimGui.handles.this);  % return focus to stimGUI



%---------------------------------------------------------------------------
function pushbuttonRenameCondition_Callback(hObject, eventdata, handles)
global stimGui

newname = inputdlg({'New Condition Name'}, 'New Condition Name');
if isempty(newname)
    return;
end
if isempty(newname{1})
    return;
end
conditions = get(handles.popupmenuConditions, 'string');
idx = get(handles.popupmenuConditions, 'value');
oldname = conditions{idx};

stimGui.dataTree.group.RenameCondition(oldname, newname{1});

stimGui.Display();
stimGui.DisplayGuiMain();
figure(stimGui.handles.this);  % return focus to stimGUI


