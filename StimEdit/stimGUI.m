function varargout = stimGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @stimGUI_OutputFcn, ...
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
function varargout = stimGUI_OutputFcn(hObject, eventdata, handles)
handles.updateptr = @stimGUI_Update;
handles.closeptr = [];
varargout{1} = handles;



% -------------------------------------------------------------------
function stimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global stimEdit
global hmr

% Choose default command line output for procStreamGUI
handles.output = hObject;
guidata(hObject, handles);

stimEdit = [];

%%%% Begin parse arguments 

stimEdit.status=-1;
stimEdit.format = '';
stimEdit.pos = [];
if ~isempty(hmr)
    stimEdit.format = hmr.format;
end

% Format argument
if isempty(stimEdit.format)
    if isempty(varargin)
        stimEdit.format = 'snirf';
    elseif ischar(varargin{1})
        stimEdit.format = varargin{1};
    end
end

% Position argument
if isempty(stimEdit.pos)
    if length(varargin)==1 && ~ischar(varargin{1})
        stimEdit.pos = varargin{1};
    elseif length(varargin)==2 && ~ischar(varargin{2})
        stimEdit.pos = varargin{2};
    end
end

%%%% End parse arguments 

% See if we can set the position
p = stimEdit.pos;
if ~isempty(p)
    set(hObject, 'position', [p(1), p(2), p(3), p(4)]);
end
stimEdit.version = get(hObject, 'name');
stimEdit.dataTree = LoadDataTree(stimEdit.format, '', hmr);
if ispc()
    setGuiFonts(hObject, 7);
else
    setGuiFonts(hObject);
end
if isempty(stimEdit.dataTree)
    stimGUI_EnableGuiObjects('off', hObject);
    return;
end
set(get(handles.axes1,'children'), 'ButtonDownFcn', @axes1_ButtonDownFcn);
zoom(hObject,'off');
stimGUI_Update(handles);
stimGUI_EnableGuiObjects('on', handles);
stimGUI_Display(handles);

stimEdit.status=0;



% --------------------------------------------------------------------
function menuItemOpen_Callback(hObject, eventdata, handles)
global stimEdit

[filename, pathname] = uigetfile({'*.nirs','*.snirf'}, 'Select a NIRS data file');
if filename==0
    return;
end
stimEdit.Load([pathname, filename]);
stimGUI_Display(handles);



% --------------------------------------------------------------------
function pushbuttonExit_Callback(hObject, eventdata, handles)
if ishandles(handles.figure)
    delete(handles.figure);
end



% --------------------------------------------------------------------
function popupmenuConditions_Callback(hObject, eventdata, handles)
conditions = get(hObject, 'string');
idx = get(hObject, 'value');
condition = conditions{idx};
stimGUI_SetUitableStimInfo(condition, handles);



%---------------------------------------------------------------------------
function editSelectTpts_Callback(hObject, eventdata, handles)
tPts_select = str2num(get(hObject,'string'));
if isempty(tPts_select)
    return;
end
EditSelectTpts(tPts_select);
stimGUI_Display(handles);
DisplayGuiMain();
figure(handles.figure);



%---------------------------------------------------------------------------
function uitableStimInfo_CellEditCallback(hObject, eventdata, handles)
global stimEdit

data = get(hObject,'data') ;
conditions =  stimEdit.dataTree.currElem.GetConditions();
icond = stimGUI_GetConditionIdxFromPopupmenu(conditions, handles);
SetStimData(icond, data);
r=eventdata.Indices(1);
c=eventdata.Indices(2);
if c==2
    return;
end
stimGUI_Display(handles);
DisplayGuiMain();
figure(handles.figure);



%---------------------------------------------------------------------------
function pushbuttonRenameCondition_Callback(hObject, eventdata, handles)
global stimEdit

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

stimEdit.dataTree.group.RenameCondition(oldname, newname{1});
if stimEdit.status ~= 0
    return;
end
stimEdit.dataTree.group.SetConditions();
set(handles.popupmenuConditions, 'string', stimEdit.dataTree.group.GetConditions());
stimGUI_Display(handles);
DisplayGuiMain();
figure(handles.figure);


%---------------------------------------------------------------------------
function axes1_ButtonDownFcn(hObject, eventdata, handles)
global stimEdit

[point1,point2] = extractButtondownPoints();
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);
p2 = max(point1,point2);
t1 = p1(1);
t2 = p2(1);
EditSelectRange(t1, t2);
stimGUI_Display(handles);
DisplayGuiMain();
figure(handles.figure);



% ------------------------------------------------
function stims_select = GetStimsFromTpts(tPts_idxs_select)
global stimEdit

% Error checking
if isempty(stimEdit.dataTree)
    return;
end
if isempty(stimEdit.dataTree.currElem)
    return;
end
if stimEdit.dataTree.currElem.procType~=3
    return;
end

% Now that we made sure legit dataTree exists, we can match up
% the selected stims to the stims in currElem
currElem = stimEdit.dataTree.currElem;
s = currElem.GetStims();
s2 = sum(abs(s(tPts_idxs_select,:)),2);
stims_select = find(s2>=1);



% ------------------------------------------------
function EditSelectRange(t1, t2)
global stimEdit
t = stimEdit.dataTree.currElem.GetTime();
if ~all(t1==t2)
    tPts_idxs_select = find(t>=t1 & t<=t2);
else
    tVals = (t(end)-t(1))/length(t);
    tPts_idxs_select = min(find(abs(t-t1)<tVals));
end
stims_select = GetStimsFromTpts(tPts_idxs_select);
if isempty(stims_select) & ~(t1==t2)
    menu( 'Drag a box around the stim to edit.','Okay');
    return;
end

AddEditDelete(tPts_idxs_select, stims_select);
if stimEdit.status==0
    return;
end

% Reset status
stimEdit.status=0;



% ------------------------------------------------
function EditSelectTpts(tPts_select)
global stimEdit
t = stimEdit.dataTree.currElem.GetTime();
tPts_idxs_select = [];
for ii=1:length(tPts_select)
    tPts_idxs_select(ii) = binaraysearchnearest(t, tPts_select(ii));
end
stims_select = GetStimsFromTpts(tPts_idxs_select);
AddEditDelete(tPts_idxs_select, stims_select);
if stimEdit.status==0
    return;
end

% Reset status
stimEdit.status=0;



% ------------------------------------------------
function DisplayGuiMain(stimEdit)
global hmr



% ------------------------------------------------
function AddEditDelete(tPts_idxs_select, iS_lst)
% Usage:
%
%     AddEditDelete(tPts_select, iS_lst)
%
% Inputs:
%
%     tPts  - time range selected in stim.currElem.t
%     iS_lst - indices in tPts of existing stims
global stimEdit

if isempty(tPts_idxs_select)
    return;
end
                    
dataTree       = stimEdit.dataTree;
currElem       = dataTree.currElem;
group          = dataTree.group;
CondNamesGroup = group.GetConditions();
tc             = currElem.GetTime();
nCond          = length(CondNamesGroup);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create menu actions list
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
actionLst = CondNamesGroup;
actionLst{end+1} = 'New condition';
if ~isempty(iS_lst)
    actionLst{end+1} = 'Toggle active on/off';
    actionLst{end+1} = 'Delete';
    menuTitleStr = sprintf('Edit/Delete stim mark(s) at t=%0.1f-%0.1f to...', ...
                           tc(tPts_idxs_select(iS_lst(1))), ...
                           tc(tPts_idxs_select(iS_lst(end))));
else
    menuTitleStr = sprintf('Add stim mark at t=%0.1f...', tc(tPts_idxs_select(1)));
end
actionLst{end+1} = 'Cancel';
nActions = length(actionLst);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get user's responce to menu question
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ch = menu(menuTitleStr, actionLst);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cancel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ch==nActions || ch==0
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(iS_lst)
    
    % If stim added to new condition update group conditions
    if ch==nCond+1
        CondNameNew = inputdlg('','New Condition name');
        if isempty(CondNameNew)
            return;
        end
        while ismember(CondNameNew{1}, CondNamesGroup)
            CondNameNew = inputdlg('Condition already exists. Choose another name.','New Condition name');
            if isempty(CondNameNew)
                return;
            end
        end
        CondName = CondNameNew{1};
    else
        CondName = CondNamesGroup{ch};
    end
    
    %%%% Add new stim to currElem's condition
    currElem.AddStims(tc(tPts_idxs_select), CondName);
    stimEdit.status = 1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Existing stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    
    %%%% Delete stim
    if ch==nActions-1 & nActions==nCond+4

        % Delete stim entry from userdata first
        % because it depends on stim.currElem.s
        currElem.DeleteStims(tc(tPts_idxs_select));

    %%%% Toggle active/inactive stim
    elseif ch==nActions-2 & nActions==nCond+4

        ;
    
    %%%% Edit stim
    elseif ch<=nCond+1
        
        % Assign new condition to edited stim
        if ch==nCond+1
            CondNameNew = inputdlg('','New Condition name');
            if isempty(CondNameNew)
                return;
            end
            CondName = CondNameNew{1};
        else
            CondName = CondNamesGroup{ch};
        end
        currElem.MoveStims(tc(tPts_idxs_select), CondName);
        
    end
    stimEdit.status = 1;
    
end
group.SetConditions();



% ------------------------------------------------
function SetStimDuration(icond, duration)
global stimEdit
if isempty(stimEdit)
    return;
end
if isempty(stimEdit.dataTree)
    return;
end
if isempty(stimEdit.dataTree.currElem)
    return;
end
stimEdit.dataTree.currElem.SetStimDuration(icond, duration);



% ------------------------------------------------
function duration = GetStimDuration(icond)
global stimEdit
if isempty(stimEdit)
    return;
end
if isempty(stimEdit.dataTree)
    return;
end
if isempty(stimEdit.dataTree.currElem)
    return;
end
duration = stimEdit.dataTree.currElem.GetStimDuration(icond);


% -------------------------------------------------------------------
function [tpts, duration, vals] = GetStimData(icond)
global stimEdit
[tpts, duration, vals] = stimEdit.dataTree.currElem.GetStimData(icond);


% -------------------------------------------------------------------
function SetStimData(icond, data)
global stimEdit
stimEdit.dataTree.currElem.SetStimTpts(icond, data(:,1));
stimEdit.dataTree.currElem.SetStimDuration(icond, data(:,2));
stimEdit.dataTree.currElem.SetStimValues(icond, data(:,3));


% -------------------------------------------------------------------
function stimGUI_DeleteFcn(hObject, eventdata, handles)
