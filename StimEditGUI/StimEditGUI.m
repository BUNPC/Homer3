function varargout = StimEditGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StimEditGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StimEditGUI_OutputFcn, ...
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
function varargout = StimEditGUI_OutputFcn(hObject, eventdata, handles)
handles.updateptr = @StimEditGUI_Update;
handles.closeptr = [];
varargout{1} = handles;



% -------------------------------------------------------------------
function StimEditGUI_OpeningFcn(hObject, eventdata, handles, varargin)
%
%  Syntax:
%
%     StimEditGUI()
%     StimEditGUI(format)
%     StimEditGUI(format, pos)
%  
%  Description:
%     GUI used for editing/adding/deleting stimulus conditions and related parameters. 
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
global stimEdit
global maingui

% Choose default command line output for StimEditGUI
handles.output = hObject;
guidata(hObject, handles);

stimEdit = [];

%%%% Begin parse arguments 

stimEdit.status=-1;
stimEdit.format = '';
stimEdit.pos = [];
stimEdit.updateParentGui = [];

if ~isempty(maingui)
    stimEdit.format = maingui.format;
    stimEdit.updateParentGui = maingui.Update;
    
    % If parent gui exists disable these menu options which only make sense when
    % running this GUI standalone
    set(handles.menuFile,'visible','off');
    set(handles.menuItemChangeGroup,'visible','off');
    set(handles.menuItemSaveGroup,'visible','off');
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

setGuiFonts(hObject);

%%%% End parse arguments 

% See if we can set the position
if ~isempty(stimEdit.pos)
    p = stimEdit.pos;
    set(hObject, 'units','characters', 'position', [p(1), p(2), p(3), p(4)]);
else
    set(hObject, 'units','characters');
end

stimEdit.version = get(hObject, 'name');
stimEdit.dataTree = LoadDataTree(stimEdit.format, '', maingui);
if stimEdit.dataTree.IsEmpty()
    return;
end
if isempty(stimEdit.dataTree)
    StimEditGUI_EnableGuiObjects('off', hObject);
    return;
end
set(get(handles.axes1,'children'), 'ButtonDownFcn', @axes1_ButtonDownFcn);
zoom(hObject,'off');
StimEditGUI_Update(handles);
StimEditGUI_EnableGuiObjects('on', handles);
stimEdit.status=0;



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
StimEditGUI_SetUitableStimInfo(condition, handles);



%---------------------------------------------------------------------------
function editSelectTpts_Callback(hObject, eventdata, handles)
global stimEdit
tPts_select = str2num(get(hObject,'string'));
if isempty(tPts_select)
    return;
end
EditSelectTpts(tPts_select);
if stimEdit.status==0
    return;
end
StimEditGUI_Display(handles);
stimEdit.updateParentGui('StimEditGUI');
figure(handles.figure);

% Reset status only should be set/reset in top-level gui functions (ie
% callbacks)
stimEdit.status=0;



%---------------------------------------------------------------------------
function uitableStimInfo_CellEditCallback(hObject, eventdata, handles)
global stimEdit

data = get(hObject,'data') ;
conditions =  stimEdit.dataTree.currElem.GetConditions();
icond = StimEditGUI_GetConditionIdxFromPopupmenu(conditions, handles);
SetStimData(icond, data);
r=eventdata.Indices(1);
c=eventdata.Indices(2);
if c==2
    return;
end
StimEditGUI_Display(handles);
stimEdit.updateParentGui('StimEditGUI');
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
StimEditGUI_Display(handles);
stimEdit.updateParentGui('StimEditGUI');
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
EditSelectRange(t1, t2, handles);
if stimEdit.status==0
    return;
end
StimEditGUI_Display(handles);
stimEdit.updateParentGui('StimEditGUI');
figure(handles.figure);

% Reset status
stimEdit.status=0;



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
if ~isa(stimEdit.dataTree.currElem, 'RunClass')
    return;
end

% Now that we made sure legit dataTree exists, we can match up
% the selected stims to the stims in currElem
t = stimEdit.dataTree.currElem.GetTimeCombined();
s = stimEdit.dataTree.currElem.GetStims(t);
s2 = sum(abs(s(tPts_idxs_select,:)),2);
stims_select = find(s2>=1);



% ------------------------------------------------
function h = HighlightStims(t, t_select, s, handles)
h = [];
if isempty(t)
    return
end
if isempty(t_select)
    return
end
axes(handles.axes1)
r = ylim();
hold on
for ii=1:length(s)
    h(ii) = line([t(t_select(s(ii))), t(t_select(s(ii)))], [r(1), r(2)], 'color',[0,0,0], 'linewidth',2.5);
end
hold off
drawnow



% ------------------------------------------------
function EditSelectRange(t1, t2, handles)
global stimEdit
t = stimEdit.dataTree.currElem.GetTime();
if ~all(t1==t2)
    tPts_idxs_select = find(t>=t1 & t<=t2);
else
    tVals = (t(end)-t(1))/length(t);
    tPts_idxs_select = min(find(abs(t-t1)<tVals));
end
stims_select = GetStimsFromTpts(tPts_idxs_select);
if isempty(stims_select) & ~all(t1==t2)
    MessageBox( 'Drag mouse around the stim to edit.');
    return;
end

% Highlight stims user wants to edit
h = HighlightStims(t, tPts_idxs_select, stims_select, handles);
AddEditDelete(tPts_idxs_select, stims_select);
if ~isempty(h)
    delete(h);
end


% ------------------------------------------------
function EditSelectTpts(tPts_select)
global stimEdit
t = stimEdit.dataTree.currElem.GetTime();
if isempty(t)
    MessageBox('Current processing element has no time course data for stim editing. In MainGUI, change current processing element to Run to edit stim marks.');
    return;
end
tPts_idxs_select = [];
for ii=1:length(tPts_select)
    tPts_idxs_select(ii) = binaraysearchnearest(t, tPts_select(ii));
end
stims_select = GetStimsFromTpts(tPts_idxs_select);
if length(tPts_idxs_select) == length(stims_select)
    AddEditDelete(tPts_idxs_select, stims_select);
elseif isempty(stims_select)
    AddEditDelete(tPts_idxs_select);
else
    k = ismember(1:length(tPts_idxs_select), stims_select);
    menu_choice = AddEditDelete(tPts_idxs_select(k==0));
    AddEditDelete(tPts_idxs_select(k==1), 1:length(stims_select), 'non-interactive', menu_choice);
end
if stimEdit.status==0
    return;
end



% ------------------------------------------------
function [menu_choice, nActions] = GetUserMenuSelection(tPts_idxs_select, iS_lst)
global stimEdit

if ~exist('tPts_idxs_select','var') || isempty(tPts_idxs_select)
    return;
end
if ~exist('iS_lst','var') || isempty(iS_lst)
    iS_lst = [];
end
                    
CondNamesGroup = stimEdit.dataTree.group.GetConditions();
tc             = stimEdit.dataTree.currElem.GetTime();

% Create menu actions list
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

% Get user's responce to menu question
menu_choice = MenuBox(menuTitleStr, actionLst);



% ------------------------------------------------
function menu_choice = AddEditDelete(tPts_idxs_select, iS_lst, mode, menu_choice)
% Usage:
%
%     AddEditDelete(tPts_select, iS_lst)
%
% Inputs:
%
%     tPts  - time range selected in stim.currElem.t
%     iS_lst - indices in tPts of existing stims
global stimEdit

if ~exist('tPts_idxs_select','var') || isempty(tPts_idxs_select)
    return;
end
if ~exist('iS_lst','var') || isempty(iS_lst)
    iS_lst = [];
end
if ~exist('mode','var') || isempty(mode)
    mode = 'interactive';
end
                    
CondNamesGroup = stimEdit.dataTree.group.GetConditions();
tc             = stimEdit.dataTree.currElem.GetTime();
nCond          = length(CondNamesGroup);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get user menu selection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmpi(mode, 'interactive')
     [menu_choice, nActions] = GetUserMenuSelection(tPts_idxs_select, iS_lst);
elseif ~exist('menu_choice','var') || isempty(menu_choice)
    return;
else
    nActions = length(CondNamesGroup)+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cancel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if menu_choice==nActions || menu_choice==0
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if isempty(iS_lst)
    
    % If stim added to new condition update group conditions
    if menu_choice==nCond+1
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
        CondName = CondNamesGroup{menu_choice};
    end
    
    %%%% Add new stim to currElem's condition
    stimEdit.dataTree.currElem.AddStims(tc(tPts_idxs_select), CondName);
    stimEdit.status = 1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Existing stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
else
    
    %%%% Delete stim
    if menu_choice==nActions-1 & nActions==nCond+4

        % Delete stim entry from userdata first
        % because it depends on stim.currElem.s
        stimEdit.dataTree.currElem.DeleteStims(tc(tPts_idxs_select));

    %%%% Toggle active/inactive stim
    elseif menu_choice==nActions-2 & nActions==nCond+4

        stimEdit.dataTree.currElem.ToggleStims(tc(tPts_idxs_select));
    
    %%%% Edit stim
    elseif menu_choice<=nCond+1
        
        % Assign new condition to edited stim
        if menu_choice==nCond+1
            CondNameNew = inputdlg('','New Condition name');
            if isempty(CondNameNew)
                return;
            end
            CondName = CondNameNew{1};
        else
            CondName = CondNamesGroup{menu_choice};
        end
        stimEdit.dataTree.currElem.MoveStims(tc(tPts_idxs_select), CondName);
        
    end
    stimEdit.status = 1;
    
end
stimEdit.dataTree.group.SetConditions();



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
function StimEditGUI_DeleteFcn(hObject, eventdata, handles)
edit ProcStreamOptionsGUI.m



% --------------------------------------------------------------------
function menuItemChangeGroup_Callback(hObject, eventdata, handles)
pathname = uigetdir(pwd, 'Select a NIRS data group folder');
if pathname==0
    return;
end
cd(pathname);
StimEditGUI();



% --------------------------------------------------------------------
function menuItemSaveGroup_Callback(hObject, eventdata, handles)
global stimEdit
if ~ishandles(hObject)
    return;
end
stimEdit.dataTree.currElem.Save();

