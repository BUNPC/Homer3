function varargout = Homer3(varargin)

% Start initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Homer3_OpeningFcn, ...
    'gui_OutputFcn',  @Homer3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1}) && ~strcmp(varargin{end},'userargs')
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT



% ---------------------------------------------------------------------
function Homer3_Init(handles, args)

% Set the figure renderer. Some renderers aren't compatible
% with certain OSs or graphics cards. Homer3 uses the figure renderer
% when displaying patches. Allow user to set the renderer that is best
% for the host system.
%

hFig = handles.Homer3;
if ~isempty(args)
    if strcmpi(args{1},'zbuffer') || ...
            strcmpi(args{1},'painters') || ...
            strcmpi(args{1},'opengl')
        
        set(hFig,'renderer',args{1});
        set(hFig,'renderermode','manual');
        
    elseif strcmpi(args{1},'rendererauto')
        
        if isunix()
            set(hObject,'renderer','zbuffer');
        elseif ispc()
            set(hFig,'renderer','painters');
        else
            set(hFig,'renderer','zbuffer');
        end
        set(hFig,'renderermode','manual');
        
    end
end




% ---------------------------------------------------------------------
function Homer3_EnableDisableGUI(handles,val)

set(handles.listboxFiles, 'enable', val);
set(handles.radiobuttonProcTypeGroup, 'enable', val);
set(handles.radiobuttonProcTypeSubj, 'enable', val);
set(handles.radiobuttonProcTypeRun, 'enable', val);
set(handles.radiobuttonPlotRaw, 'enable', val);
set(handles.radiobuttonPlotOD,  'enable', val);
set(handles.radiobuttonPlotConc, 'enable', val);
set(handles.checkboxPlotHRF, 'enable', val);
set(handles.textStatus, 'enable', val);


% --------------------------------------------------------------------
function Homer3_OpeningFcn(hObject, eventdata, handles, varargin)
global hmr

hmr = [];

hmr.handles.this = hObject;
hmr.handles.stimGUI = [];
hmr.handles.proccessOpt = [];
hmr.handles.plotProbe = [];
hmr.files    = [];
hmr.group    = [];
hmr.currElem = [];
hmr.guiMain             = [];

% Choose default command line output for Homer3
handles.output = hObject;
guidata(hObject, handles);

% Display window name which includes version # and data set path. Do this
% regardless of whether it's an empty gui because the user pressed cancel.
% We want them to see the gui and version no matter what.
V = Homer3_version();
if str2num(V{2})==0
    set(handles.Homer3,'name', sprintf('Homer3  (v%s) - %s',[V{1}],cd) )
else
    set(handles.Homer3,'name', sprintf('Homer3  (v%s) - %s',[V{1} '.' V{2}],cd) )
end

% Disable and reset all window gui objects
Homer3_EnableDisableGUI(handles,'off');

Homer3_Init(handles, {'zbuffer'});

% Check NIRS data set for errors. If there are no valid
% nirs files don't attempt to load them.
files = GetNIRSDataSet(handles);
if isempty(files)
    return;
end

%%%% Initialize essential objects

% Load NIRS files to group
[group, files] = LoadNIRS2Group(files);

% Generate the CondNames for all members of group
group = MakeCondNamesGroup(group);


% Find and initialize the current processing element within the group
currElem = InitCurrElem(handles, @listboxFiles_Callback);

%%%% Load essential objects

% Load the currently selected processing element from the group
currElem = LoadCurrElem(currElem, group, files, 1, 1);

% Within the current element, initialize the data to display
guiMain = InitGuiMain(handles, group, currElem);

% If data set has no errors enable window gui objects
Homer3_EnableDisableGUI(handles,'on');

hmr.files    = files;
hmr.group    = group;
hmr.currElem = currElem;
hmr.guiMain  = guiMain;

% Display data from currently selected processing element
DisplayCurrElem(currElem, guiMain);

hmr.plotprobe = PlotProbe_Init(handles);



% --------------------------------------------------------------------
function varargout = Homer3_OutputFcn(hObject, eventdata, handles)
global hmr
varargout{1} = hmr.handles.this;



% --------------------------------------------------------------------
function Homer3_DeleteFcn(hObject, eventdata, handles)
global hmr;

if isempty(hmr)
    return;
end
if ~exist('eventdata','var') | isempty(eventdata)
    eventdata = [];
end
if isempty(hmr.handles)
    return;
end

if ishandle(hmr.handles.stimGUI)
    delete(hmr.handles.stimGUI);
end
if ishandle(hmr.handles.plotProbe)
    delete(hmr.handles.plotProbe);
end
if ~isempty(hmr.currElem)
    if ishandle(hmr.currElem.handles.ProcStreamOptionsGUI)
        delete(hmr.currElem.handles.ProcStreamOptionsGUI);
    end
end
if ishandle(hmr.handles.this)
    delete(hmr.handles.this);
end

hmr = [];
clear hmr;



%%%% currElem

% --------------------------------------------------------------------
function uipanelProcessingType_SelectionChangeFcn(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
group    = hmr.group;
files    = hmr.files;
guiMain  = hmr.guiMain;
plotprobe = hmr.plotprobe;

procTypeTag = get(hObject,'tag');
switch(procTypeTag)
    case 'radiobuttonProcTypeGroup'
        currElem.procType = 1;
    case 'radiobuttonProcTypeSubj'
        currElem.procType = 2;
    case 'radiobuttonProcTypeRun'
        currElem.procType = 3;
end
currElem = LoadCurrElem(currElem, group, files);
guiMain = UpdateAxesDataCondition(guiMain, group, currElem);
DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

currElem = UpdateCurrElemProcStreamOptionsGUI(currElem);
if ishandles(hmr.handles.stimGUI)
    group = MakeCondNamesGroup(group);
    hmr.handles.stimGUI = launchStimGUI(hmr.handles.this, ...
        hmr.handles.stimGUI, ...
        currElem, ...
        group.CondNames);
end
hmr.currElem = currElem;
hmr.plotprobe = plotprobe;



% --------------------------------------------------------------------
function listboxFiles_Callback(hObject, eventdata, handles)
global hmr

files = hmr.files;

% If evendata isn't empty then caller is trying to set currElem
if strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData')
    ;
elseif ~isempty(eventdata)
    iSubj = eventdata(1);
    iRun = eventdata(2);
    iFile = MapGroup2File(files, iSubj, iRun);
    if iFile==0
        return;
    end
    set(hObject,'value', iFile);
end

idx = get(hObject,'value');
if isempty(idx==0)
    return;
end

group = hmr.group;
currElem = hmr.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

currElem = LoadCurrElem(currElem, group, files);
guiMain = UpdateAxesDataCondition(guiMain, group, currElem);
if ishandles(hmr.handles.stimGUI)
    group = MakeCondNamesGroup(group);
    hmr.handles.stimGUI = launchStimGUI(hmr.handles.this, ...
        hmr.handles.stimGUI, ...
        currElem, ...
        group.CondNames);
end
DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

currElem = UpdateCurrElemProcStreamOptionsGUI(currElem);

hmr.currElem = currElem;
hmr.group = group;
hmr.plotprobe = plotprobe;



% --------------------------------------------------------------------
function pushbuttonCalcProcStream_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
files    = hmr.files;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

iSubj = currElem.iSubj;
iRun  = currElem.iRun;

currElem = CalcCurrElem(currElem);

group    = hmr.group;

% Reload curren element selection
currElem = LoadCurrElem(currElem, group, files, iSubj, iRun);

DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

hmr.currElem = currElem;
hmr.group = group;
hmr.plotprobe = plotprobe;





% --------------------------------------------------------------------
function listboxFilesErr_Callback(hObject, eventdata, handles)

% TBD: We may want to try fix files with errors



%%%% guiMain

% --------------------------------------------------------------------
function uipanelPlot_SelectionChangeFcn(hObject, eventdata, handles)
global hmr

guiMain = hmr.guiMain;
currElem = hmr.currElem;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataType(guiMain);
DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

datatype   = guiMain.datatype;
buttonVals = guiMain.buttonVals;
if datatype == buttonVals.RAW || datatype == buttonVals.RAW_HRF || datatype == buttonVals.RAW_HRF_PLOT_PROBE
    
    set(guiMain.handles.listboxPlotWavelength, 'visible','on');
    set(guiMain.handles.listboxPlotConc, 'visible','off');
    
elseif datatype == buttonVals.OD || datatype == buttonVals.OD_HRF || datatype == buttonVals.OD_HRF_PLOT_PROBE
    
    set(guiMain.handles.listboxPlotWavelength, 'visible','on');
    set(guiMain.handles.listboxPlotConc, 'visible','off');
    
elseif datatype == buttonVals.CONC || datatype == buttonVals.CONC_HRF || datatype == buttonVals.CONC_HRF_PLOT_PROBE
    
    set(guiMain.handles.listboxPlotWavelength, 'visible','off');
    set(guiMain.handles.listboxPlotConc, 'visible','on');
    
end

hmr.guiMain = guiMain;
hmr.plotprobe = plotprobe;



% --------------------------------------------------------------------
function checkboxPlotHRF_Callback(hObject, eventdata, handles)
global hmr

guiMain = hmr.guiMain;
currElem = hmr.currElem;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataType(guiMain);
if get(hObject,'value')==1
    currElem = LoadCurrElem(currElem, hmr.group, hmr.files);
end
DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

hmr.guiMain = guiMain;
hmr.plotprobe = plotprobe;



% --------------------------------------------------------------------
function guiMain_ButtonDownFcn(hObject, eventdata, handles)

% Make sure the user clicked on the axes and not
% some other object on top of the axes
if ~strcmp(get(hObject,'type'),'axes')
    return;
end





% --------------------------------------------------------------------
function axesSDG_ButtonDownFcn(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;

% Transfer the channels selection to guiMain
guiMain = SetAxesDataCh(guiMain, currElem);

% Update the displays of the guiMain and axesSDG axes
DisplayCurrElem(currElem, guiMain);

% the the modified objects
hmr.currElem = currElem;
hmr.guiMain = guiMain;




% --------------------------------------------------------------------
function popupmenuConditions_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataCondition(guiMain);

% Update the display of the guiMain axes
DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

% the the modified objects
hmr.guiMain = guiMain;
hmr.plotprobe = plotprobe;





% --------------------------------------------------------------------
function listboxPlotWavelength_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataWl(guiMain, currElem.procElem.SD.Lambda);

% Update the displays of the guiMain and axesSDG axes
DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

% the the modified objects
hmr.guiMain = guiMain;
hmr.plotprobe = plotprobe;





% --------------------------------------------------------------------
function listboxPlotConc_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

% Transfer the channels selection to guiMain
guiMain = GetAxesDataHbType(guiMain);

% Update the displays of the guiMain and axesSDG axes
DisplayCurrElem(currElem, guiMain);
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

% the the modified objects
hmr.guiMain = guiMain;
hmr.plotprobe = plotprobe;




% --------------------------------------------------------------------
function menuChangeDirectory_Callback(hObject, eventdata, handles)
global hmr
guiMain = hmr.guiMain;

% Change directory
pathnm = uigetdir( cd, 'Pick the new directory' );
if pathnm==0
    return;
end
cd(pathnm);

hGui=get(get(hObject,'parent'),'parent');
Homer3_DeleteFcn(hGui,[],handles);
% checkboxPlotProbe_Callback(handles.checkboxPlotProbe, 0, handles);

% restart
clear hmr
Homer3();




% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)

hGui=get(get(hObject,'parent'),'parent');
Homer3_DeleteFcn(hGui,eventdata,handles);



% --------------------------------------------------------------------
function menuItemReset_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
files    = hmr.files;
guiMain = hmr.guiMain;
group    = hmr.group;

currElem = ResetCurrElem(currElem);
group = SaveCurrElem(currElem, group);

group = LoadNIRS2Group(files);

% Generate the CondNames for all members of group
group = MakeCondNamesGroup(group);

% Load the currently selected processing element from the group
currElem = LoadCurrElem(currElem, group, files);

% Display data from currently selected processing element
DisplayCurrElem(currElem, guiMain);

hmr.group = group;
hmr.currElem = currElem;


% --------------------------------------------------------------------
function menuCopyCurrentPlot_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;

[hf, plotname] = CopyDisplayCurrElem(currElem, guiMain);
%{
if strcmp(get(handles.menuAutosavePlotFigsToFile,'checked'),'on')
    filename = [plotname '.jpg'];
    print(hf,'-djpeg99',filename);
end
%}



% --------------------------------------------------------------------
function pushbuttonProcStreamOptionsEdit_Callback(hObject, eventdata, handles)
global hmr

files = hmr.files;
group = hmr.group;
currElem = hmr.currElem;

% Reload curren element selection
currElem = LoadCurrElem(currElem, group, files);
currElem = OpenCurrElemProcStreamOptionsGUI(currElem,'close');

hmr.handles.proccessOpt = currElem.handles.ProcStreamOptionsGUI;
hmr.currElem = currElem;



% -------------------------------------------------------------------
function menuItemLaunchStimGUI_Callback(hObject, eventdata, handles)
global hmr

group = hmr.group;
currElem = hmr.currElem;

hmr.handles.stimGUI = launchStimGUI(hmr.handles.this, ...
    hmr.handles.stimGUI, ...
    currElem, ...
    group.CondNames);



% -------------------------------------------------------------------
function hStimGUI = launchStimGUI(hObject, hStimGUI, currElem, CondNamesGroup)

if ishandles(hStimGUI)
    delete(hStimGUI);
end
hStimGUI = stimGUI(currElem, CondNamesGroup, hObject);

u0 = get(hObject, 'units');
set(hObject, 'units','normalized');
p0 = get(hObject, 'position');

set(hStimGUI, 'units','normalized');
p1 = get(hStimGUI, 'position');
if p0(1)>.5
    p1(1)=.01;
elseif ((.99-p1(3)) - p0(1)) < .1
    p1(1)=.01;
else
    p1(1)=.99-p1(3);
end
set(hStimGUI, 'position',p1);
set(hObject, 'units',u0);


% --------------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global hmr

saveGroup(hmr.group, 'saveruns');


% --------------------------------------------------------------------
function menuItemViewHRFStdErr_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;

if strcmp(get(hObject, 'checked'), 'on');
    set(hObject, 'checked', 'off')
elseif strcmp(get(hObject, 'checked'), 'off');
    set(hObject, 'checked', 'on')
end

if strcmp(get(hObject, 'checked'), 'on');
    guiMain.showStdErr = true;
elseif strcmp(get(hObject, 'checked'), 'off');
    guiMain.showStdErr = false;
end

DisplayCurrElem(currElem, guiMain);

hmr.guiMain = guiMain;



% ---------------------------------------------------------------------------
function checkboxPlotProbe_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataType(guiMain);
plotprobe.active = get(hObject, 'value');
plotprobe = DisplayPlotProbe(plotprobe, currElem, guiMain);

hmr.plotprobe = plotprobe;
hmr.guiMain   = guiMain;

