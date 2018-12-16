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

condition = get(hObject, 'value');
duration = stimGui.GetStimDuration(condition);
if isempty(duration)
    return;
end
set(handles.editStimDuration, 'string', num2str(duration));



% --------------------------------------------------------------------
function editStimDuration_Callback(hObject, eventdata, handles)
global stimGui

duration = str2num(get(hObject, 'string'));
icond = get(handles.popupmenuConditions, 'value');
stimGui.SetStimDuration(icond, duration);


%---------------------------------------------------------------------------
function editSelectTpts_Callback(hObject, eventdata, handles)
global stimGui

tPts_select = str2num(get(hObject,'string'));
if isempty(tPts_select)
    return;
end
stimGui.EditSelectTpts(tPts_select);
