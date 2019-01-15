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
if ispc()
    setGuiFonts(hObject, 7);
else
    setGuiFonts(hObject);
end
if ~isempty(stimGui.figPosLast)
    set(hObject, 'position',stimGui.figPosLast);
end
set(get(handles.axes1,'children'), 'ButtonDownFcn', @axes1_ButtonDownFcn);
zoom(hObject,'off');



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

% Function to rename a condition. Important to remeber that changing the
% condition involves 2 distinct well defined steps:
%   a) For the current element change the name of the specified (old) 
%      condition for ONLY for ALL the acquired data elements under the 
%      currElem, be it run, subj, or group. In this step we DO NOT TOUCH 
%      the condition names of the run, subject or group. 
%   b) Rebuild condition names and tables of all the tree nodes group, subjects 
%      and runs same as if you were loading during Homer3 startup from the 
%      acquired data.
%
newname = inputdlg({'New Condition Name'}, 'New Condition Name');
if isempty(newname)
    return;
end
if isempty(newname{1})
    return;
end

% Get the name of the condition you want to rename
conditions = get(handles.popupmenuConditions, 'string');
idx = get(handles.popupmenuConditions, 'value');
oldname = conditions{idx};

% NOTE: for now any renaming of a condition is global to avoid complexity
% in keeping the condition colors straight. Therefore we comment out the 
% following line in favor of the one after it. 

% stimGui.dataTree.currElem.procElem.RenameCondition(oldname, newname{1});
stimGui.dataTree.group.RenameCondition(oldname, newname{1});
if stimGui.dataTree.group.GetErrStatus() ~= 0
    return;
end
stimGui.dataTree.group.SetConditions();

set(handles.popupmenuConditions, 'string', stimGui.dataTree.currElem.procElem.GetConditions());

stimGui.Display();
stimGui.DisplayGuiMain();
figure(stimGui.handles.this);  % return focus to stimGUI



%---------------------------------------------------------------------------
function stimGUI_DeleteFcn(hObject, eventdata, handles)
global stimGui

stimGui.figPosLast = get(hObject, 'position');



%---------------------------------------------------------------------------
function axes1_ButtonDownFcn(hObject, eventdata, handles)
global stimGui

[point1,point2] = extractButtondownPoints();
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);
p2 = max(point1,point2);
t1 = p1(1);
t2 = p2(1);
stimGui.Buttondown(t1, t2);

