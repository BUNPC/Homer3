function varargout = stimGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @stimGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @stimGUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


%---------------------------------------------------------------------------
function getArgs(args)
global stim 

stim.currElem = [];
stim.CondNamesGroup = {};
stim.CondColTbl = [];
stim.handles.parentgui = [];

nargin = length(args);
if nargin==0
    return;
end 

if isstruct(args{1})
    stim.currElem = args{1};
    if nargin>1
        stim.CondNamesGroup = args{2};
    else
        stim.CondNamesGroup = stim.currElem.procElem.CondNames;
    end
    if nargin>2
        stim.handles.parentgui = args{3};
    end
elseif ischar(args{1})
    run = loadRun(args{1});
    if isempty(run)
        return;
    end
    stim.currElem.procElem = run;
    stim.currElem.procType = 3;
    stim.currElem.procElem.CondName2Group = ...
        MakeCondRun2Group(stim.currElem.procElem, stim.CondNamesGroup);
    stim.CondNamesGroup = stim.currElem.procElem.CondNames;
    if nargin>1
        stim.handles.parentgui = args{2};
    end
end
stim.CondColTbl = MakeCondColTbl(stim.CondNamesGroup);



%---------------------------------------------------------------------------
function stimGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global stim

% Choose default command line output for stimGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

stim.handles.this = hObject;

getArgs(varargin);
if isempty(stim.currElem) | isempty(stim.currElem.procElem)
    return;
end

currElem = stim.currElem;
aux = currElem.procElem.GetAux();

% For now handle stims only on run level
if currElem.procType ~= 3
    menu('Current selected element not a run. StimGUI handles only run at the moment.','OK');
    return;
end

if isempty(aux)
    stim.iAux = 0;
else
    set(handles.listboxAux,'string',aux.names);
    set(handles.listboxAux,'value',1);
    stim.iAux = 1;    
end

stim.LegendHdl = -1;
stim.linewidthReg = 2;
stim.linewidthHighl = 4;

stim.handles.axes = handles.axes1;
stim.handles.radiobuttonZoom = handles.radiobuttonZoom;
stim.handles.radiobuttonStim = handles.radiobuttonStim;
stim.handles.tableUserData = handles.tableUserData;
stim.handles.pushbuttonUpdate = handles.pushbuttonUpdate;
stim.handles.pushbuttonRenameCondition = handles.pushbuttonRenameCondition;
stim.handles.textTimePts = handles.textTimePts;
stim.handles.stimMarksEdit = handles.stimMarksEdit;
stim.handles.stimGUI = hObject;

% Enable GUI obbjects since we initialized gui successfully 
set(stim.handles.radiobuttonZoom, 'enable','on');
set(stim.handles.radiobuttonStim, 'enable','on');
set(stim.handles.tableUserData, 'enable','on');
set(stim.handles.pushbuttonRenameCondition, 'enable','on');
set(stim.handles.textTimePts, 'enable','on');
set(stim.handles.stimMarksEdit, 'enable','on');

if ~isempty(aux)   
    set(handles.pushbuttonApply, 'enable','off');
    set(handles.editTmin, 'enable','off');
    set(handles.editThreshold, 'enable','off');
    set(handles.listboxAux, 'string','');
    set(handles.listboxAux, 'enable','off');
    set(handles.textTmin, 'enable','off');
    set(handles.textThreshold, 'enable','off');
end

set(handles.textFileName, 'string',currElem.procElem.name);

stim.currElem = currElem;
stimGUI_DisplayData();



%---------------------------------------------------------------------------
function varargout = stimGUI_OutputFcn(hObject, eventdata, handles) 
global stim;
varargout{1} = hObject;



% -------------------------------------------------------------------
function varargout = stimGUI_DeleteFcn(hObject, eventdata, handles)
global stim;
varargout = stim.CondNamesGroup;
stim = [];
clear stim;


%---------------------------------------------------------------------------
function loadNIRS( handles, filenm )
global stim

load(filenm,'-mat')

if ~exist('aux')
    if exist('aux10')
        aux = aux10;
    else
        menu( 'There is no Aux data','okay');
        return;
    end
end

stim.currElem.procElem.s = s;
stim.currElem.procElem.SD = SD;
stim.currElem.procElem.aux = aux;
stim.currElem.procElem.t = t;

% set Aux listbox
foos = [];
for ii=1:size(aux,2)
    if isproperty(SD,'auxChannels')
        foos{end+1} = SD.auxChannels{ii};
    else
        foos{end+1} = sprintf('Aux %d',ii);
    end
end
set(handles.listboxAux,'string',foos);
set(handles.listboxAux,'value',1);
stim.iAux = 1;

stimGUI_DisplayData();



%---------------------------------------------------------------------------
function listboxAux_Callback(hObject, eventdata, handles)
global stim

stim.iAux = get(hObject,'value');
stimGUI_DisplayData(  );


%---------------------------------------------------------------------------
function pushbuttonApply_Callback(hObject, eventdata, handles)
global stim
aux = stim.currElem.procElem.aux;
t = stim.currElem.procElem.t;

thresh = str2num(get(handles.editThreshold,'string'));
tmin = str2num(get(handles.editTmin,'string'));

so = aux(:,stim.iAux);
lst = find(so>thresh);
if isempty(lst)
    return;
end
lst2 = find(diff(t(lst))>tmin);
lst3 = [lst(1); lst(lst2+1)];
lst4 = 1:length(lst3);

stim.what_changed=[stim.what_changed stimGUI_AddEditDelete(lst3,lst4,1)];
if ~isempty(stim.what_changed)
    set(stim.handles.pushbuttonUpdate,'enable','on');
end
stimGUI_DisplayData();



%---------------------------------------------------------------------------
function radiobuttonZoom_Callback(hObject, eventdata, handles)
stimGUI_DisplayData();


%---------------------------------------------------------------------------
function radiobuttonStim_Callback(hObject, eventdata, handles)
stimGUI_DisplayData();


%---------------------------------------------------------------------------
function tableUserData_CellEditCallback(hObject, eventdata, handles)
global stim

if(~isempty(eventdata.Indices))
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    for ii=1:length(stim.Lines)
        if ii==r
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthHighl);
        else
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthReg);
        end
    end
    stim.userdata.data(:,2:end) = get(hObject,'data');
    stim.userdata.data(:,1) = get(hObject,'userdata');
    set(stim.handles.pushbuttonUpdate,'enable','on');
    stim.what_changed{end+1} = 'userdata';
    stimGUI_DisplayData(r);
end



%---------------------------------------------------------------------------
function tableUserData_CellSelectionCallback(hObject, eventdata, handles)
global stim

if sum(ishandles(stim.Lines))<length(stim.Lines)
    return;
end

if(~isempty(eventdata.Indices))
    r=eventdata.Indices(1);
    c=eventdata.Indices(2);
    for ii=1:length(stim.Lines)
        if ii==r
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthHighl);
        else
            set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthReg);
        end
    end
end


%---------------------------------------------------------------------------
function stimGUI_ButtonDownFcn(hObject, eventdata, handles)
global stim

if sum(ishandles(stim.Lines))<length(stim.Lines)
    return;
end
for ii=1:length(stim.Lines)
    set(stim.Lines(ii).handle,'color',stim.Lines(ii).color,'linewidth',stim.linewidthReg);
end


%---------------------------------------------------------------------------
function tableUserData_CreateFcn(hObject, eventdata, handles)
global stim

hcm = uicontextmenu();
set(hObject,'uicontextmenu',hcm);
hcm_AddDelColumns = uimenu('parent',hcm,'handlevisibility','callback',...
                           'label','Add Columns','callback',@tableUserDataMenu_AddCol_Callback);
hcm_AddDelColumns = uimenu('parent',hcm,'handlevisibility','callback',...
                           'label','Delete Columns','callback',@tableUserDataMenu_DeleteCol_Callback);
hcm_NameColumns = uimenu('parent',hcm,'handlevisibility','callback','label','Name Columns',...
                         'label','Name Columns','callback',@tableUserDataMenu_NameCol_Callback);



%---------------------------------------------------------------------------
function tableUserDataMenu_AddCol_Callback(hObject, eventdata, handles)
global stim

data=stim.userdata.data;
Dt=data(:,1);
D=data(:,2:end);
nrows=size(D,1);
ncols=size(D,2);

n=inputdlg({'number of columns to add:'},'Add Column');
if(isempty(n))
    return;
end
if(isempty(n{1}))
    return;
end
n=str2num(n{1});
if(~isscalar(n) || n<1)
    return;
end

cnames=stim.userdata.cnames;
cnames=reshape(cnames,1,length(cnames));
for i=1:n
    cnames=[cnames, num2str(ncols+i)];
end
D2=repmat({''},nrows,n);
D=[D D2];

% Recalculate size of A and update 
nrows_new=size(D,1);
ncols_new=size(D,2);
cwidth=repmat({100},1,ncols_new);
ceditable=logical(ones(1,ncols_new));

tableUserData_Update(stim.handles,[Dt D],cnames,cwidth,ceditable);
set(stim.handles.pushbuttonUpdate,'enable','on');
stim.what_changed{end+1} = 'userdata_cols';



%---------------------------------------------------------------------------
function tableUserDataMenu_DeleteCol_Callback(hObject, eventdata, handles)
global stim

data=stim.userdata.data;
Dt=data(:,1);
D=data(:,2:end);
nrows=size(D,1);
ncols=size(D,2);

n=inputdlg({'column number:'},'Delete Column');
if(isempty(n))
    return;
end
if(isempty(n{1}))
    return;
end
n=str2num(n{1});
if(~isempty(find(n<1 | n>ncols)))
    return;
end

cnames=stim.userdata.cnames;
cnames=reshape(cnames,1,length(cnames));
cnames(n)=[];
D(:,n)=[];

% Recalculate size of A and update 
ncols_new=size(D,2);
cwidth=repmat({100},1,ncols_new);
ceditable=logical(ones(1,ncols_new));

tableUserData_Update(stim.handles,[Dt D],cnames,cwidth,ceditable);
set(stim.handles.pushbuttonUpdate,'enable','on');
stim.what_changed{end+1} = 'userdata_cols';


%---------------------------------------------------------------------------
function tableUserDataMenu_NameCol_Callback(hObject, eventdata, handles)
global stim

data=stim.userdata.data;
D=data(:,2:end);
nrows=size(D,1);
ncols=size(D,2);

d=inputdlg({'column number:','column name'},'Name Column');
if(isempty(d))
    return;
end
if(length(d)<2)
    return;
end
if(isempty(d{1}) | isempty(d{2}))
    return;
end
n=str2num(d{1});
if(isempty(n) | n(1)>ncols | n(1)<1)
    return;
end
name=d{2};

% Assign new name to selected column
cnames=stim.userdata.cnames;
cnames(n)={name};

% Update stim and stimGUI table
tableUserData_Update(stim.handles,[],cnames,[],[],'cnames');
set(stim.handles.pushbuttonUpdate,'enable','on');
stim.what_changed{end+1} = 'userdata_cols';



%---------------------------------------------------------------------------
function stimMarksEdit_Callback(hObject, eventdata, handles)
global stim

data = str2num(get(hObject,'string'));
if(isempty(data))
    return;
end

% First get the time points 
lst=[];
for ii=1:length(data)
    lst(ii) = binaraysearchnearest(stim.currElem.procElem.t,data(ii));
end
s = sum(abs(stim.currElem.procElem.s(lst,:)),2);
lst2 = find(s>=1);

stimGUI_AddEditDelete(lst, lst2);

set(stim.handles.pushbuttonUpdate,'enable','on');

stimGUI_DisplayData();



%---------------------------------------------------------------------------
function stimMarksEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','');



%--------------------------------------------------------------------------
function menuItemOpen_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.nirs'});
if filename==0
    return;
end
relpath = getrelpath([pathname,filename]);
stimGUI(relpath);


%--------------------------------------------------------------------------
function menuItemExit_Callback(hObject, eventdata, handles)
global stim 

delete(stim.handles.this);



%--------------------------------------------------------------------------
function pushbuttonRenameCondition_Callback(hObject, eventdata, handles)
global stim

nCond = length(stim.CondNamesGroup);

% List current run's conditions
actionLst1 = [stim.currElem.procElem.CondNames {'Cancel'}];
ch1 = menu('Which current run''s condition do you want to rename?',actionLst1);
if(ch1==length(actionLst1)) || ch1==0
    return;
end
iCrun_orig_group = find(strncmp(stim.currElem.procElem.CondNames{ch1}, stim.CondNamesGroup, ...
                        length(stim.currElem.procElem.CondNames{ch1})));

%
% Don't include in the list of destination conditions (i.e., the
% conditions to which to rename) any of the current run's conditions
% Renaming to a current run's condition merely means moving all the
% stims from condition A to condition B in the current run.
% This isn't technically renaming a run's condition but moving stims
% among conditions, something that can be done via the axes or the stim
% edit box. Therefore we only offer destination conditions which
% don't exist in the run.
%
k=[]; jj=1;
for ii=1:length(stim.CondNamesGroup)
    if sum(strncmp(stim.CondNamesGroup{ii}, stim.currElem.procElem.CondNames, ...
            length(stim.CondNamesGroup{ii})))==0
        k(jj)=ii;
        jj=jj+1;
    end
end


% Display group (destination) conditions to which run can be renamed
actionLst2 = [stim.CondNamesGroup(k) {'New Condition','Cancel'}];
ch2 = menu('Name you want to assign to condition?',actionLst2);
if(ch2==length(actionLst2)) || ch2==0
    return;
end

% Set the selected run condition to the new (from the run's perspective)
% condition name.
if ch2<length(actionLst2)-1
    
    iC_new = k(ch2);
    CondNameNew = stim.CondNamesGroup(k(ch2));
    
elseif ch2==length(actionLst2)-1
    
    CondNameNew = inputdlg('New Condition Name','New Condition Name');
    if isempty(CondNameNew) || isempty(CondNameNew{1})
        return;
    end
    iC_new = nCond+1;
    stim.CondNamesGroup{iC_new} = CondNameNew{1};
    
end

stim.currElem.procElem.CondNames{ch1} = CondNameNew{1};
set(stim.handles.pushbuttonUpdate,'enable','on');
stimGUI_DisplayData();


%--------------------------------------------------------------------------
function varargout = stimGUI_CloseRequestFcn(hObject, eventdata, handles)

varargout{1} = 93834;
delete(hObject);



%--------------------------------------------------------------------------
function pushbuttonUpdate_Callback(hObject, eventdata, handles)
global stim 

s              = stim.currElem.procElem.s;
CondNames      = stim.currElem.procElem.CondNames;
CondName2Group = stim.currElem.procElem.CondName2Group;
procInput      = stim.currElem.procElem.procInput;

% Redisplay Homer3 gui display
Homer3_RemakeCond(stim);
