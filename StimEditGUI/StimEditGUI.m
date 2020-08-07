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
function StimEditGUI_Close()
global stimEdit
if ~isempty(stimEdit.updateParentGui)
    stimEdit.updateParentGui('StimEditGUI', 'close');
end



% -------------------------------------------------------------
function varargout = StimEditGUI_OutputFcn(hObject, eventdata, handles)
handles.updateptr = @Update;
handles.closeptr = @StimEditGUI_Close;
handles.saveptr = @Save;
varargout{1} = handles;



% -------------------------------------------------------------------
function StimEditGUI_OpeningFcn(hObject, eventdata, handles, varargin)
%
%  Syntax:
%
%     StimEditGUI()
%     StimEditGUI(groupDirs)
%     StimEditGUI(groupDirs, format)
%     StimEditGUI(groupDirs, format, pos)
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
stimEdit.groupDirs = {};
stimEdit.format = '';
stimEdit.pos = [];
stimEdit.updateParentGui = [];

cfg = ConfigFileClass();
stimEdit.config.autoSaveAcqFiles = cfg.GetValue('Auto Save Acquisition Files');

if ~isempty(maingui)
    stimEdit.groupDirs = maingui.groupDirs;
    stimEdit.format = maingui.format;
    stimEdit.updateParentGui = maingui.Update;
    
    % If parent gui exists disable these menu options which only make sense when
    % running this GUI standalone
    set(handles.menuFile,'visible','off');
    set(handles.menuItemChangeGroup,'visible','off');
    set(handles.menuItemSaveGroup,'visible','off');
end

% Group dirs argument
if isempty(stimEdit.groupDirs)
    if length(varargin)<1
        stimEdit.groupDirs = convertToStandardPath({pwd});
    elseif ischar(varargin{1})
        stimEdit.groupDirs = varargin{1};
    end
end

% Format argument
if isempty(stimEdit.format)
    if length(varargin)<2
        stimEdit.format = 'snirf';
    elseif ischar(varargin{2})
        stimEdit.format = varargin{2};
    end
end

% Position argument
if isempty(stimEdit.pos)
    if length(varargin)>=3
        stimEdit.pos = varargin{3};
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
stimEdit.dataTree = LoadDataTree(stimEdit.groupDirs, stimEdit.format, '', maingui);
if stimEdit.dataTree.IsEmpty()
    return;
end
if isempty(stimEdit.dataTree)
    EnableGuiObjects('off', hObject);
    return;
end
set(get(handles.axes1,'children'), 'ButtonDownFcn', @axes1_ButtonDownFcn);
zoom(hObject,'off');
Update(handles);
EnableGuiObjects('on', handles);
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
SetUitableStimInfo(condition, handles);


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
Display(handles);
if ~isempty(stimEdit.updateParentGui)
    stimEdit.updateParentGui('StimEditGUI');
end
figure(handles.figure);

% Reset status only should be set/reset in top-level gui functions (ie
% callbacks)
stimEdit.status=0;


%---------------------------------------------------------------------------
function uitableStimInfo_CellEditCallback(hObject, eventdata, handles)
global stimEdit

data = get(hObject,'data') ;
conditions =  stimEdit.dataTree.currElem.GetConditions();
icond = GetConditionIdxFromPopupmenu(conditions, handles);
SetStimData(icond, data);
r=eventdata.Indices(1);
c=eventdata.Indices(2);
if c==2
    return;
end
Display(handles);
if ~isempty(stimEdit.updateParentGui)
    stimEdit.updateParentGui('StimEditGUI');
end
figure(handles.figure);


%---------------------------------------------------------------------------
function pushbuttonRenameCondition_Callback(hObject, eventdata, handles)
global stimEdit

% Function to rename a condition. Important to remeber that changing the
% condition involves 2 distinct well defined steps:
%   a) For the current element change the name of the specified (old) 
%      condition for ONLY for ALL the acquired data elements under the 
%      currElem, be it run, subj, or group . In this step we DO NOT TOUCH 
%      the condition names of the run, subject or group . 
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

iG = stimEdit.dataTree.GetCurrElemIndexID();
stimEdit.dataTree.groups(iG).RenameCondition(oldname, newname{1});
if stimEdit.status ~= 0
    return;
end
stimEdit.dataTree.groups(iG).SetConditions();
set(handles.popupmenuConditions, 'string', stimEdit.dataTree.groups(iG).GetConditions());
Display(handles);
if ~isempty(stimEdit.updateParentGui)
    stimEdit.updateParentGui('StimEditGUI');
end
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
Display(handles);
if ~isempty(stimEdit.updateParentGui)
    stimEdit.updateParentGui('StimEditGUI');
end
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
s = stimEdit.dataTree.currElem.GetStimStatus(t);
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

iG = stimEdit.dataTree.GetCurrElemIndexID();
CondNamesGroup = stimEdit.dataTree.groups(iG).GetConditions();
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

iG = stimEdit.dataTree.GetCurrElemIndexID();
CondNamesGroup = stimEdit.dataTree.groups(iG).GetConditions();
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

iG = stimEdit.dataTree.GetCurrElemIndexID();
stimEdit.dataTree.groups(iG).SetConditions();


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
function duration = GetStimDuration(icond) %#ok<*DEFNU>
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
stimEdit.dataTree.currElem.SetStimAmplitudes(icond, data(:,3));


% -------------------------------------------------------------------
function Save()
global stimEdit

% If nothing changes, nothing to save, so exit
if ~stimEdit.dataTree.currElem.AcquiredDataModified()
    return
end

% Check auto-save config parameter
if ~strcmpi(stimEdit.config.autoSaveAcqFiles, 'Yes')
    % Ask user if they want to save, before changing contents of acquisition file
    if stimEdit.dataTree.currElem.IsRun()
        msg = sprintf('Are you sure you want to save stimulus edits directly in the acquisition file %s?', stimEdit.dataTree.currElem.name);
    else
        msg = sprintf('Are you sure you want to save stimulus edits directly in acquisition files in %s?', stimEdit.dataTree.currElem.name);
    end
    q = MenuBox(msg, {'Yes','No','Don''t ask again'});
    if q==2
        return;
    elseif q==3
        cfg = ConfigFileClass();
        cfg.SetValue('Auto Save Acquisition Files', 'Yes');
        cfg.Save()
    end
else
    % Otherwise auto-save 
    fprintf('StimEditGUI: auto-saving ...\n')
end

% Update acquisition file with new contents
h = waitbar_improved(0, 'Saving new stim marks to %s...', stimEdit.dataTree.currElem.name);
stimEdit.dataTree.currElem.SaveAcquiredData()
waitbar_improved(1, h, 'Saving new stim marks to %s...', stimEdit.dataTree.currElem.name);
close(h)


% --------------------------------------------------------------------
function pushbuttonWriteToFile_Callback(hObject, eventdata, handles)
Save()


% -------------------------------------------------------------------
function StimEditGUI_DeleteFcn(hObject, eventdata, handles)
% pass


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


% --------------------------------------------------------------------
function Update(handles)
global stimEdit

if ~exist('handles','var') || isempty(handles)
    return;
end
if ~ishandles(handles.figure)
    return;
end
conditions =  stimEdit.dataTree.currElem.GetConditions();
filename = stimEdit.dataTree.currElem.GetName();
[~, fname, ext] = fileparts(filename);
SetTextFilename([fname, ext, ' :'], handles);

% Try to keep the same condition as old run
[icond, conditions] = GetConditionIdxFromPopupmenu(conditions, handles);
set(handles.popupmenuConditions, 'value',icond);
set(handles.popupmenuConditions, 'string',conditions);
SetUitableStimInfo(conditions{icond}, handles);
Display(handles);
figure(handles.figure);


% -----------------------------------------------------------
function EnableGuiObjects(onoff, handles)
if ~exist('handles','var') || isempty(handles)
    return;
end
if ~isstruct(handles)
    return;
end
fields = fieldnames(handles);
for ii=1:length(fields)
    sprintf('enableHandle(%s, onoff);', fields{ii});
end


% -----------------------------------------------------------
function enableHandle(handle, onoff)
if eval( sprintf('ishandles(obj.handles.%s)', handle) )
    eval( sprintf('set(obj.handles.%s, ''enable'',onoff);', handle) );
end


% -----------------------------------------------------------
function [icond, conditions] = GetConditionIdxFromPopupmenu(conditions, handles)
conditions_menu = get(handles.popupmenuConditions, 'string');
idx = get(handles.popupmenuConditions, 'value');
if isempty(conditions_menu)
    icond = 1;
    return;
end
condition = conditions_menu{idx};
icond = find(strcmp(conditions, condition));
if isempty(icond)
    icond = 1;
end


% -----------------------------------------------------------
function SetTextFilename(name, handles)
if isempty(handles)
    return;
end

if ~ishandles(handles.textFilename)
    return;
end
n = length(name);
set(handles.textFilename, 'units','characters');
p = get(handles.textFilename, 'position');
set(handles.textFilename, 'position',[p(1), p(2), n+.50*n, p(4)]);
set(handles.textFilename, 'units','normalized');
set(handles.textFilename, 'string',name);


% -----------------------------------------------------------
function Display(handles)
global stimEdit
if isempty(stimEdit.dataTree)
    return;
end
if isempty(handles)
    return;
end
if ~ishandles(handles.axes1)
    return;
end

axes(handles.axes1)
cla(handles.axes1);
hold(handles.axes1, 'on');

% As of now this operation is undefined for non-Run nodes (i.e., Subj and Group)
% So we clear the axes and exit
if stimEdit.dataTree.currElem.iRun==0
    return;
end

% Load current element data from file
if stimEdit.dataTree.currElem.IsEmpty()
    stimEdit.dataTree.currElem.Load();
end

iG = stimEdit.dataTree.GetCurrElemIndexID();
CondNamesGroup = stimEdit.dataTree.groups(iG).GetConditions();
CondColTbl     = stimEdit.dataTree.groups(iG).CondColTbl();
t              = stimEdit.dataTree.currElem.GetTimeCombined();
s              = stimEdit.dataTree.currElem.GetStimStatus(t);
stimStatuses   = stimEdit.dataTree.currElem.GetstimStatusSettings();

% Aux preview
if get(handles.checkboxPreview, 'Value')  % If preview is enabled, plot
    iaux = handles.listboxAuxSelect.Value;
    currAux = stimEdit.dataTree.currElem.acquired.aux(iaux);
    [onsets, auxFiltered, timeFiltered] = StimEditGUI_StimFromAux(currAux,...
                                                            handles.editThresh.Value,...          % Stim threshold
                                                            handles.editLPF.Value,...             % LPF window width
                                                            handles.radiobuttonRisingEdge.Value); % rising vs falling
    % Plot selected aux signal after applying filter
    auxPlot = plot(timeFiltered + currAux.timeOffset, auxFiltered, 'k-');  % TODO is this what timeOffset is for?
    auxPlot.Color(4) = 0.5;  % Stim opacity
    % Plot stim preview
    yy = get(handles.axes1, 'ylim');
    for iOnset = 1:length(onsets)
        plot([1 1]*onsets(iOnset), yy, 'k:', 'LineWidth', 2.5, 'parent', handles.axes1);
    end
    if length(onsets) > 9999
        nmarks = '>9999';
    else
        nmarks = num2str(length(onsets));
    end
    set(handles.pushbuttonGenerate, 'String', ['Generate ', nmarks, ' stim marks']);
end

[lstR,lstC] = find(abs(s) ~= stimStatuses.none);
[lstR,k] = sort(lstR);
lstC = lstC(k);
nStim = length(lstR);
yy = get(handles.axes1, 'ylim');
Lines = InitStimLines(length(lstR));
idxLg=[];
hLg=[];
kk=1;
for ii=1:nStim
    if(s(lstR(ii),lstC(ii))==stimStatuses.incl)
        linestyle = '-';
    elseif(s(lstR(ii),lstC(ii))==stimStatuses.excl_manual)
        linestyle = '--';
    elseif(s(lstR(ii),lstC(ii))==stimStatuses.excl_auto)
        linestyle = '-.';
    else
        linestyle = '-';
    end
    Lines(ii).handle = plot([1 1]*t(lstR(ii)), yy, linestyle, 'parent',handles.axes1);
    
    iCond = lstC(ii);
    Lines(ii).color = CondColTbl(iCond,1:3);
    try
        set(Lines(ii).handle,'color',Lines(ii).color);
    catch
        fprintf('ERROR!!!!\n');
    end
    set(Lines(ii).handle, 'linewidth',Lines(ii).widthReg);
    
    % Check which conditions are represented in S for the conditions
    % legend display.
    if ~ismember(iCond, idxLg)
        hLg(kk) = plot([1 1]*t(1), yy,'-', 'color',Lines(ii).color, 'linewidth',4, 'visible','off', 'parent',handles.axes1);
        idxLg(kk) = iCond;
        kk=kk+1;
    end
end

% Update legend
set(0,'DefaultLegendAutoUpdate','off')  % Required to keep aux signals from appearing
[idxLg,k] = sort(idxLg);
if ~isempty(hLg)
    hLg = legend(hLg(k), CondNamesGroup(idxLg));
end
set(handles.axes1,'xlim', [t(1), t(end)]);

% Update conditions popupmenu
set(handles.popupmenuConditions, 'string', sort(stimEdit.dataTree.currElem.GetConditions()));
conditions = get(handles.popupmenuConditions, 'string');
idx = get(handles.popupmenuConditions, 'value');
condition = conditions{idx};
SetUitableStimInfo(condition, handles);


% -----------------------------------------------------------
function Lines = InitStimLines(n)
if ~exist('n','var')
    n = 0;
end
Lines = repmat( struct('handle',[], 'color',[], 'widthReg',2, 'widthHighl',4), n,1);


% -----------------------------------------------------------
function SetUitableStimInfo(condition, handles)
global stimEdit

if ~exist('condition','var')
    return;
end
conditions =  stimEdit.dataTree.currElem.GetConditions();
if isempty(conditions)
    return;
end
icond = find(strcmp(conditions, condition));
if isempty(icond)
    return;
end
[tpts, duration, amps] = stimEdit.dataTree.currElem.GetStimData(icond);
states = stimEdit.dataTree.currElem.GetStimStatusCond(icond);
if isempty(tpts)
    set(handles.uitableStimInfo, 'data',[]);
    return;
end
[~,idx] = sort(tpts);
data = zeros(length(tpts),4);
data(:,1) = tpts(idx);
data(:,2) = duration(idx);
data(:,3) = amps(idx);
data(:,4) = states(idx, 2)
set(handles.uitableStimInfo, 'data',data);


% --------------------------------------------------------------------
function [onsets, aux_filt, time_filt] = StimEditGUI_StimFromAux(currElemAux, thresh, lpf_len, rising_edge)
T = currElemAux.time(2) - currElemAux.time(1);  % Aux sample period
moving_avg_filter = ones(lpf_len,1) / lpf_len;
auxMax = max(currElemAux.dataTimeSeries);
auxMin = min(currElemAux.dataTimeSeries);
% Apply filter
if lpf_len > 0
   aux_filt = filter(moving_avg_filter, 1, currElemAux.dataTimeSeries);
   time_filt = currElemAux.time - T*(lpf_len/2);  % Remove group delay induced by LPF
   aux_filt(aux_filt > auxMax) = auxMax;
   aux_filt(aux_filt < auxMin) = auxMin;
else
   aux_filt = currElemAux.dataTimeSeries;
   time_filt = currElemAux.time;
end
onsets = [];
last = currElemAux.dataTimeSeries(1);
% Naive search for threshold crossings
for i = (lpf_len + 1):length(time_filt)  % Exclude LPF artifact
    next = aux_filt(i);
    if rising_edge
        if ((last <= thresh) && (next > thresh))
           onsets = [onsets, time_filt(i) + currElemAux.timeOffset];  %#ok<*AGROW>
        end
    else
        if ((last >= thresh) && (next < thresh))
            onsets = [onsets, time_filt(i) + currElemAux.timeOffset];
        end
    end
    last = aux_filt(i);
end

% --------------------------------------------------------------------
function editThresh_Callback(hObject, eventdata, handles)
val = str2double(hObject.String);
if isnan(val)
   set(hObject ,'String', hObject.Value);
else
    hObject.Value = val;
end
Display(handles);


% --------------------------------------------------------------------
function pushbuttonGenerate_Callback(hObject, eventdata, handles)
global stimEdit; 
iaux = handles.listboxAuxSelect.Value;
currAux = stimEdit.dataTree.currElem.acquired.aux(iaux);
[onsets, ~, ~] = StimEditGUI_StimFromAux(currAux,...
                                         handles.editThresh.Value,...          % Stim threshold
                                         handles.editLPF.Value,...             % LPF window width
                                         handles.radiobuttonRisingEdge.Value); % rising vs falling
% Add stim to dataTree element
conditions =  stimEdit.dataTree.currElem.GetConditions();
cond = char(handles.listboxAuxSelect.String(iaux));
icond = find(strcmp(conditions, cond));
for i = 1:length(onsets)
    stimEdit.dataTree.currElem.AddStims(onsets(i), cond);
end
iG = stimEdit.dataTree.GetCurrElemIndexID();
stimEdit.dataTree.groups(iG).SetConditions();
stimEdit.dataTree.currElem.SetStimDuration(icond, handles.editDuration.Value);
stimEdit.dataTree.currElem.SetStimAmplitudes(icond, handles.editAmplitude.Value);
if ~isempty(stimEdit.updateParentGui)
    stimEdit.updateParentGui('StimEditGUI', 'close');
end
Display(handles);
    

% --------------------------------------------------------------------
function listboxAuxSelect_Callback(hObject, eventdata, handles)
Display(handles);


% --------------------------------------------------------------------
function listboxAuxSelect_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
try
    % Try to populate listbox with aux channels
    global stimEdit
    aux = stimEdit.dataTree.currElem.acquired.aux;
    names = cell(1, length(aux));
    for i = 1:length(aux)
        names{i} = aux(i).name;
    end
    set(hObject, 'string', names);
    set(stimEdit.handles.editCondition, 'String', names{1});
catch
    return
end


% --------------------------------------------------------------------
function editThresh_CreateFcn(hObject, eventdata, handles)
set(hObject ,'String', '0.0');


% --------------------------------------------------------------------
function checkboxPreview_Callback(hObject, eventdata, handles)
Display(handles);


% --------------------------------------------------------------------
function radiobuttonFallingEdge_Callback(hObject, eventdata, handles)
Display(handles);


% --------------------------------------------------------------------
function radiobuttonRisingEdge_Callback(hObject, eventdata, handles)
Display(handles);


% --------------------------------------------------------------------
function editLPF_Callback(hObject, eventdata, handles)
val = abs(floor(str2num(hObject.String))); %#ok<ST2NM>
if isnan(val)
   set(hObject ,'String', hObject.Value);
else
    hObject.Value = val;
    set(hObject ,'String', val);
end
Display(handles);


% --------------------------------------------------------------------
function editLPF_CreateFcn(hObject, eventdata, handles)
hObject.Value = floor(str2double(hObject.String));


% --------------------------------------------------------------------
function editDuration_Callback(hObject, eventdata, handles)
val = str2double(hObject.String);
if isnan(val)
   set(hObject ,'String', hObject.Value);
else
    hObject.Value = val;
end


function editAmplitude_Callback(hObject, eventdata, handles)
val = str2double(hObject.String);
if isnan(val)
   set(hObject ,'String', hObject.Value);
else
    hObject.Value = val;
end


% --------------------------------------------------------------------
function editDuration_CreateFcn(hObject, eventdata, handles)
val = str2double(hObject.String);

