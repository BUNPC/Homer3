function varargout = MainGUI(varargin)

% Start initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MainGUI_OpeningFcn, ...
    'gui_OutputFcn',  @MainGUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT



% ---------------------------------------------------------------------
function MainGUI_Init(handles, args)

% Set the figure renderer. Some renderers aren't compatible
% with certain OSs or graphics cards. MainGUI uses the figure renderer
% when displaying patches. Allow user to set the renderer that is best
% for the host system.
%
hFig = handles.MainGUI;
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
positionGUI(hFig, 0.15, 0.05, 0.80, 0.90)
setGuiFonts(hFig);

set(handles.togglebuttonMinimizeGUI, 'tooltipstring','Minimize GUI Window')

% Set checkForUpdates checkbox based on config setting
cfg = ConfigFileClass();
handles.menuItemUpdateCheck.Checked = cfg.GetValue('Check For Updates');

% Get rid of the useless "might be unsused" warnings for GUI callbacks
checkboxPlotHRF_Callback([]);
checkboxApplyProcStreamEditToAll_Callback([]);
pushbuttonCalcProcStream_Callback([]);
listboxFilesErr_Callback([]);
uipanelPlot_SelectionChangeFcn([]);
menuItemProcStreamEditGUI_Callback([]);
menuItemPlotProbeGUI_Callback([]);
menuItemSaveGroup_Callback([]);
menuItemViewHRFStdErr_Callback([]);
menuItemStimEditGUI_Callback([]);
pushbuttonProcStreamOptionsGUI_Callback([]);
guiControls_ButtonDownFcn([]);
axesSDG_ButtonDownFcn([]);
popupmenuConditions_Callback([]);
listboxPlotWavelength_Callback([]);
listboxPlotConc_Callback([]);
menuItemChangeGroup_Callback([]);
menuItemExit_Callback([]);
menuItemReset_Callback([]);
menuCopyCurrentPlot_Callback([]);
uipanelProcessingType_SelectionChangeFcn([]);


% ---------------------------------------------------------------------
function MainGUI_EnableDisableGUI(handles, val)

% Processing element panel
set(handles.listboxGroupTree, 'enable', val);
set(handles.listboxFilesErr, 'enable', val);
set(handles.radiobuttonProcTypeGroup, 'enable', val);
set(handles.radiobuttonProcTypeSubj, 'enable', val);
set(handles.radiobuttonProcTypeRun, 'enable', val);
set(handles.textStatus, 'enable', val);

% Plot window panel
set(handles.textPanLeftRight, 'enable', val);
set(handles.pushbuttonPanLeft, 'enable', val);
set(handles.pushbuttonPanRight, 'enable', val);
set(handles.pushbuttonPanLeft, 'enable', val);
set(handles.pushbuttonResetView, 'enable', val);
set(handles.pushbuttonPanLeft, 'enable', val);
set(handles.checkboxFixRangeX, 'enable', val);
set(handles.editFixRangeX, 'enable', val);
set(handles.checkboxFixRangeY, 'enable', val);
set(handles.editFixRangeY, 'enable', val);

% Plot type selected panel
set(handles.listboxPlotConc, 'enable', val);
set(handles.radiobuttonPlotRaw, 'enable', val);
set(handles.radiobuttonPlotOD,  'enable', val);
set(handles.radiobuttonPlotConc, 'enable', val);
set(handles.popupmenuAux, 'enable', val);
set(handles.checkboxPlotAux, 'enable', val);
set(handles.popupmenuConditions, 'enable', val);
set(handles.checkboxPlotHRF, 'enable', val);

% Motion artifact panel
set(handles.checkboxShowExcludedTimeManual, 'enable', val);
set(handles.checkboxShowExcludedTimeAuto, 'enable', val);
set(handles.checkboxShowExcludedTimeAutoByChannel, 'enable', val);
set(handles.checkboxExcludeTime, 'enable', val);
set(handles.pushbuttonResetExcludedTimeCh, 'enable', val);

% Control
set(handles.pushbuttonCalcProcStream, 'enable', val);
set(handles.pushbuttonProcStreamOptionsGUI, 'enable', val);
set(handles.checkboxApplyProcStreamEditToAll, 'enable', val);

% Menu
set(handles.ToolsMenu, 'enable', val);
set(handles.ViewMenu, 'enable', val);
set(handles.menuItemSaveGroup, 'enable', val);
set(handles.menuItemExport, 'enable', val);
set(handles.menuItemReset, 'enable', val);
set(handles.menuItemResetGroupFolder, 'enable', val)



% ---------------------------------------------------------------------
function MainGUI_EnableDisablePlotEditMode(handles, val)

% Processing element panel
set(handles.listboxGroupTree, 'enable', val);
set(handles.listboxFilesErr, 'enable', val);
set(handles.radiobuttonProcTypeGroup, 'enable', val);
set(handles.radiobuttonProcTypeSubj, 'enable', val);
set(handles.radiobuttonProcTypeRun, 'enable', val);
set(handles.textStatus, 'enable', val);

% Control
set(handles.pushbuttonCalcProcStream, 'enable', val);
set(handles.pushbuttonProcStreamOptionsGUI, 'enable', val);
set(handles.checkboxApplyProcStreamEditToAll, 'enable', val);

% Menu
set(handles.ToolsMenu, 'enable', val);
set(handles.ViewMenu, 'enable', val);
set(handles.menuItemSaveGroup, 'enable', val);
set(handles.menuItemExport, 'enable', val);
set(handles.menuItemReset, 'enable', val);
set(handles.menuItemResetGroupFolder, 'enable', val)

% --------------------------------------------------------------------
function eventdata = MainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global maingui
global logger

startuptimer = tic;
maingui = [];

if isempty(varargin)
    maingui.groupDirs = convertToStandardPath({pwd});
else
    maingui.groupDirs = varargin{1};
end
if length(varargin)<2
    maingui.format = 'snirf';
else
    maingui.format = varargin{2};
end

if ~iscell(maingui.groupDirs)
    maingui.groupDirs = {maingui.groupDirs};
end
maingui.logger = InitLogger(logger, 'MainGUI');

for ii=1:length(maingui.groupDirs)
    maingui.logger.CurrTime(sprintf('MainGUI:  Will load group folder #%d - %s\n', ii, maingui.groupDirs{ii}));
end

maingui.gid = 1;
maingui.sid = 2;
maingui.rid = 3;

maingui.dataTree = [];
maingui.Update = @Update;
maingui.handles = [];

% Choose default command line output for MainGUI
handles.output = hObject;
guidata(hObject, handles);

% Set the main GUI version number
[~, V] = MainGUIVersion(hObject, 'exclpath');
maingui.version = V;
maingui.childguis = ChildGuiClass().empty();

% Disable and reset all window gui objects
MainGUI_EnableDisableGUI(handles,'off');
MainGUI_Init(handles, {'zbuffer'});

maingui.childguis(1) = ChildGuiClass('ProcStreamEditGUI');
maingui.childguis(2) = ChildGuiClass('ProcStreamOptionsGUI');
maingui.childguis(3) = ChildGuiClass('StimEditGUI');
maingui.childguis(4) = ChildGuiClass('PlotProbeGUI');
maingui.childguis(5) = ChildGuiClass('PvaluesDisplayGUI');

% Load date files into group tree object
maingui.dataTree  = LoadDataTree(maingui.groupDirs, maingui.format);
if maingui.dataTree.IsEmpty()
    return;
end
InitGuiControls(handles);

% Display data from currently selected processing element
DisplayGroupTree(handles);
Display(handles, hObject);

maingui.handles = handles;
maingui.handles.pValuesFig = [];

% Set path in GUI window title
s = get(hObject,'name');
title = sprintf('%s - %s', s, pwd);
set(hObject,'name', title);

maingui.logger.InitChapters()
maingui.logger.CurrTime(sprintf('MainGUI: Startup time - %0.1f seconds\n', toc(startuptimer)));

% If data set has no errors enable window gui objects
MainGUI_EnableDisableGUI(handles,'on');



% --------------------------------------------------------------------
function varargout = MainGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;



% --------------------------------------------------------------------
function [eventdata, handles] = MainGUI_DeleteFcn(hObject, eventdata, handles)
global maingui;

if ishandles(hObject)
    delete(hObject)
end
if isempty(maingui)
    return;
end
if isempty(maingui.dataTree)
    return;
end
if ~isempty(maingui.logger)
    maingui.logger.Close('MainGUI');
end

% Delete Child GUIs before deleted the dataTree that all GUIs use.
for ii=1:length(maingui.childguis)
    maingui.childguis(ii).Close();
end
delete(maingui.dataTree);
maingui = [];
clear maingui;



% --------------------------------------------------------------------------------------------
function DisplayGroupTree(handles)
global maingui;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize listboxGroupTree params struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maingui.listboxGroupTreeParams = struct('listMaps',struct('names',{{}}, 'idxs', []), ...
                                        'views', struct('GROUP',1, 'SUBJS',2, 'RUNS',3), ...
                                        'viewSetting',0);
                      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate linear lists from group tree nodes for the 3 group views
% in listboxGroupTree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nSubjs, nRuns] = GenerateGroupDisplayLists();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine the best view for the data files 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[viewSetting, views] = SetView(handles, nSubjs, nRuns);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set listbox used for displaying valid data
% Get the GUI listboxGroupTree setting 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
listboxGroup = maingui.listboxGroupTreeParams.listMaps(viewSetting).names;
nFiles = length(maingui.listboxGroupTreeParams.listMaps(views.RUNS).names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set listbox used for displaying files that did not load correctly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
listboxFilesErr = cell(length(maingui.dataTree.filesErr),1);
nFilesErr=0;
for ii=1:length(maingui.dataTree.filesErr)
    if maingui.dataTree.filesErr(ii).isdir
        listboxFilesErr{ii} = maingui.dataTree.filesErr(ii).name;
    elseif ~isempty(maingui.dataTree.filesErr(ii).subjdir)
        listboxFilesErr{ii} = ['    ', maingui.dataTree.filesErr(ii).name];
        nFilesErr=nFilesErr+1;
    else
        listboxFilesErr{ii} = maingui.dataTree.filesErr(ii).name;
        nFilesErr=nFilesErr+1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set graphics objects: text and listboxes if handles exist
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(handles)
    % Report status in the status text object
    set( handles.textStatus, 'string', { ...
        sprintf('%d files loaded successfully',nFiles), ...
        sprintf('%d files failed to load',nFilesErr) ...
        } );
    
    if ~isempty(listboxGroup)
        set(handles.listboxGroupTree, 'value',1)
        set(handles.listboxGroupTree, 'string',listboxGroup)
    end
    
    if ~isempty(listboxFilesErr)
        set(handles.listboxFilesErr, 'visible','on');
        set(handles.listboxFilesErr, 'value',1);
        set(handles.listboxFilesErr, 'string',listboxFilesErr)
    else
        set(handles.listboxFilesErr, 'visible','off');
        pos1 = get(handles.listboxGroupTree, 'position');
        pos2 = get(handles.listboxFilesErr, 'position');
        set(handles.listboxGroupTree, 'position', [pos1(1) pos2(2) pos1(3) .98-pos2(2)]);
    end
end
listboxGroupTree_Callback([], [1,1,1], handles)



% --------------------------------------------------------------------
function eventdata = uipanelProcessingType_SelectionChangeFcn(hObject, eventdata, handles)
global maingui

if isempty(hObject)
    return;
end
proclevel = GetProclevel(handles);
iList = get(handles.listboxGroupTree,'value');
[iGroup,iSubj,iRun] = MapList2GroupTree(iList);
switch(proclevel)
	case maingui.gid
        if iGroup==0
            iGroup=1;
        end
        maingui.dataTree.SetCurrElem(iGroup);
    case maingui.sid
        if iGroup==0
            iGroup=1;
        end
        if iSubj==0
            iSubj=1;
        end
        maingui.dataTree.SetCurrElem(iGroup, iSubj);
    case maingui.rid
        if iGroup==0
            iGroup=1;
        end
        if iSubj==0
            iSubj=1;
        end
        if iRun==0
            iRun=1;
        end
        maingui.dataTree.SetCurrElem(iGroup, iSubj, iRun);
end
[iGroup, iSubj, iRun] = maingui.dataTree.GetCurrElemIndexID();
listboxGroupTree_Callback([], [iGroup,iSubj,iRun], handles)
Display(handles, hObject);



% --------------------------------------------------------------------
function listboxGroupTree_Callback(hObject0, eventdata, handles)

if isempty(hObject0)    
    hObject = handles.listboxGroupTree;
else
    hObject = hObject0;
end

iList = get(hObject,'value');
if isempty(iList==0)
    return;
end

% If evendata isn't empty then caller is trying to set currElem
if isa(eventdata, 'matlab.ui.eventdata.ActionData')
    
    % Get the [iGroup,iSubj,iRun] mapping of the clicked lisboxFiles entry
    [iGroup, iSubj, iRun] = MapList2GroupTree(iList);
    
    % Get the current processing level radio buttons setting
    proclevel = GetProclevel(handles);
        
    % Set new gui state based on current gui selections of listboxGroupTree
    % (iGroup, iSubj, iRun) and proc level radio buttons (proclevel)
    SetGuiProcLevel(handles, iGroup, iSubj, iRun, proclevel);
    
elseif ~isempty(eventdata)
    
    iGroup = eventdata(1);
    iSubj = eventdata(2);
    iRun = eventdata(3);
    iList = MapGroupTree2List(iGroup, iSubj, iRun);
    if iList==0
        return;
    end
    set(hObject,'value', iList);
    
end
Display(handles, hObject0);



% --------------------------------------------------------------------
function [eventdata, handles] = pushbuttonCalcProcStream_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end

MainGUI_EnableDisableGUI(handles,'off');

% Save original selection in listboxGroupTree because it'll change during auto processing 
val0 = get(handles.listboxGroupTree, 'value');

% Measure elapsed time of calculation
t = tic;

% Set the display status to pending. In order to avoid redisplaying 
% in a single callback thread in functions called from here which 
% also call DisplayData
try
    maingui.dataTree.CalcCurrElem();
catch ME
    MainGUI_EnableDisableGUI(handles,'on');
	rethrow(ME)

end
      
% Restore original selection listboxGroupTree
set(handles.listboxGroupTree, 'value',val0);

h = waitbar(0,'Auto-saving processing results. Please wait ...');
maingui.dataTree.Save(h);
close(h);
Display(handles, hObject);

% Report elapsed time of calculation
fprintf('Finished calculating, saving and displaying proc stream in %0.1f seconds\n', toc(t));

MainGUI_EnableDisableGUI(handles,'on');



% --------------------------------------------------------------------
function [eventdata, handles] = listboxFilesErr_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end

% TBD: We may want to try fix files with errors



% --------------------------------------------------------------------
function [eventdata, handles] = uipanelPlot_SelectionChangeFcn(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end

if strcmp(get(hObject, 'tag'), 'radiobuttonPlotRaw')
    set(handles.checkboxPlotHRF, 'value',0);
elseif strcmp(get(hObject, 'tag'), 'radiobuttonPlotOD') && isempty(maingui.dataTree.currElem.GetDodAvg())
    if isa(maingui.dataTree.currElem, 'RunClass')
        set(handles.checkboxPlotHRF, 'value',0);
    end
elseif strcmp(get(hObject, 'tag'), 'radiobuttonPlotConc') && isempty(maingui.dataTree.currElem.GetDcAvg())
    if isa(maingui.dataTree.currElem, 'RunClass')
        set(handles.checkboxPlotHRF, 'value',0);
    end
end
Display(handles, hObject);



% --------------------------------------------------------------------
function UpdateDatatypePanel(handles)
global maingui
datatype   = GetDatatype(handles);
if datatype == maingui.buttonVals.RAW || datatype == maingui.buttonVals.RAW_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == maingui.buttonVals.OD || datatype == maingui.buttonVals.OD_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == maingui.buttonVals.CONC || datatype == maingui.buttonVals.CONC_HRF
    set(handles.listboxPlotWavelength, 'visible','off');
    set(handles.listboxPlotConc, 'visible','on');
end



% --------------------------------------------------------------------
function [eventdata, handles] = checkboxPlotHRF_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end
if get(hObject, 'value')==1
    if ~isempty(maingui.dataTree.currElem.GetDcAvg())
        set(handles.radiobuttonPlotConc, 'enable', 'on');
        set(handles.radiobuttonPlotConc, 'value', 1);
    elseif ~isempty(maingui.dataTree.currElem.GetDodAvg())
        set(handles.radiobuttonPlotOD, 'enable', 'on');
        set(handles.radiobuttonPlotOD, 'value', 1);
    end
end
Display(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = guiControls_ButtonDownFcn(hObject, eventdata, handles)

% Make sure the user clicked on the axes and not
% some other object on top of the axes
if ~strcmp(get(hObject,'type'),'axes')
    return;
end


% --------------------------------------------------------------------
function [eventdata, handles] = axesSDG_ButtonDownFcn(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end
dataTree = maingui.dataTree;
if dataTree.IsEmpty()
    return;
end

% Set channels selection 
SetAxesDataCh();
   
if ~isempty(maingui.plotViewOptions.ranges.X)
    axes(handles.axesData)
    xlim('auto')
end
if ~isempty(maingui.plotViewOptions.ranges.Y)
    axes(handles.axesData)
    ylim('auto')
end

% Update the data axes
Display(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = popupmenuConditions_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
Display(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = listboxPlotWavelength_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
Display(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = listboxPlotConc_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
Display(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemChangeGroup_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end

fmt = maingui.format;

% Change directory
pathnm = uigetdir( cd, 'Pick the new directory' );
if pathnm==0
    return;
end
cd(pathnm);
hGui=get(get(hObject,'parent'),'parent');
MainGUI_DeleteFcn(hGui,[],handles);

% restart
MainGUI(pathnm, fmt, 'userargs');



% --------------------------------------------------------------------
function menuItemExit_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
hGui=get(get(hObject,'parent'),'parent');
MainGUI_DeleteFcn(hGui,eventdata,handles);



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemReset_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end
dataTree = maingui.dataTree;
dataTree.ResetCurrElem();
Display(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = menuCopyCurrentPlot_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end

currElem = maingui.dataTree.currElem;
hf = figure;
set(hf, 'color', [1 1 1]);
fields = fieldnames(maingui.buttonVals);
plotname = sprintf('%s_%s', currElem.name, fields{GetDatatype(handles)});
set(hf,'name', plotname);


% DISPLAY DATA
maingui.axesData.handles.axes = axes('position',[0.05 0.05 0.6 0.9]);

% DISPLAY SDG
maingui.axesSDG.handles.axes = axes('position',[0.65 0.05 0.3 0.9]);
axis off

% TBD: Display current element without help from dataTree



% --------------------------------------------------------------------
function [eventdata, handles] = pushbuttonProcStreamOptionsGUI_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end

idx = FindChildGuiIdx('ProcStreamOptionsGUI');
if get(hObject, 'value')
    maingui.childguis(idx).Launch(maingui.applyEditCurrNodeOnly);
else
    maingui.childguis(idx).Close();
end



% --------------------------------------------------------------------
function LaunchChildGuiFromMenu(guiname, h)
global maingui
if ~ishandles(h)
    return;
end
idx = FindChildGuiIdx(guiname);
checked = get(h,'checked');
if strcmp(checked, 'off')
    set(h, 'checked', 'on');
    maingui.childguis(idx).Launch();
elseif strcmp(checked, 'on')
    set(h, 'checked', 'off');
    maingui.childguis(idx).Close();
end



% --------------------------------------------------------------------
function menuItemPlotProbeGUI_Callback(hObject, eventdata, handles)
LaunchChildGuiFromMenu('PlotProbeGUI', hObject);



% -------------------------------------------------------------------
function [eventdata, handles] = menuItemStimEditGUI_Callback(hObject, eventdata, handles)
LaunchChildGuiFromMenu('StimEditGUI', hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemProcStreamEditGUI_Callback(hObject, eventdata, handles)
LaunchChildGuiFromMenu('ProcStreamEditGUI', hObject);



% --------------------------------------------------------------------
function menuItemDisplayPvalues_Callback(hObject, eventdata, handles)
LaunchChildGuiFromMenu('PvaluesDisplayGUI', hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemSaveGroup_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end
maingui.dataTree.currElem.Save();



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemViewHRFStdErr_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end

if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
elseif strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked', 'on')
end
Display(handles, hObject);


% --------------------------------------------------------------------
function [eventdata, handles] = checkboxApplyProcStreamEditToAll_Callback(hObject, eventdata, handles)
global maingui
if ~ishandles(hObject)
    return;
end

if get(hObject, 'value')
    maingui.applyEditCurrNodeOnly = false;
else
    maingui.applyEditCurrNodeOnly = true;
end
UpdateArgsChildGuis(handles);


% --------------------------------------------------------------------
function idx = FindChildGuiIdx(name)
global maingui

for ii=1:length(maingui.childguis)
    if strcmp(maingui.childguis(ii).GetName, name)
        break;
    end
end
idx = ii;


% --------------------------------------------------------------------
function UpdateArgsChildGuis(handles)
global maingui
if isempty(maingui.childguis)
    return;
end

maingui.childguis(FindChildGuiIdx('PlotProbeGUI')).UpdateArgs(GetDatatype(handles), GetCondition(handles));
maingui.childguis(FindChildGuiIdx('ProcStreamOptionsGUI')).UpdateArgs(maingui.applyEditCurrNodeOnly);


% --------------------------------------------------------------------
function UpdateChildGuis(handles)
global maingui
if isempty(maingui.childguis)
    return;
end
UpdateArgsChildGuis(handles)
for ii=1:length(maingui.childguis)
    maingui.childguis(ii).Update();
end



% ----------------------------------------------------------------------------------
function hObject = Display(handles, hObject)
global maingui

if ~exist('hObject','var') || isempty(hObject)
    return;
end

% Load current element data from file
if maingui.dataTree.LoadCurrElem() < 0
    MessageBox('Could not load current processing element. Acquisition files might be outdated or corrupted');
    return;
end

hObject = DisplayData(handles, hObject);
DisplayAxesSDG();

if get(handles.checkboxExcludeTime, 'value')==1
    zoom off
else
    zoom on
end




% ----------------------------------------------------------------------------------
function hObject = DisplayData(handles, hObject, hAxes)
global maingui

if nargin<3
    hAxes = maingui.axesData.handles.axes;
end
if ~ishandles(hAxes)
    return;
end

% Some callbacks which call DisplayData serve double duty as called functions 
% from other callbacks which in turn call DisplayData. To avoid double or
% triple redisplaying in a single thread, exit DisplayData if hObject is
% not a handle. 
if ~exist('hObject','var')
    hObject=[];
end
if ~ishandles(hObject) && nargin<3
    return;
end
if isempty(handles)
    return;
end

dataTree = maingui.dataTree;
procElem = dataTree.currElem;
EnableDisableGuiPlotBttns(handles);

axes(hAxes)
cla;
legend off
set(hAxes,'ygrid','on');

linecolor  = maingui.axesData.linecolor;
linestyle  = maingui.axesData.linestyle;
datatype   = GetDatatype(handles);
condition  = GetCondition(handles);
iCh0       = maingui.axesSDG.iCh;
iWl        = GetWl(handles);
hbType     = GetHbType(handles);
sclConc    = maingui.sclConc;        % convert Conc from Molar to uMolar
showStdErr = GetShowStdErrEnabled(handles);

[iDataBlks, iCh] = procElem.GetDataBlocksIdxs(iCh0);
maingui.logger.Write(sprintf('Displaying channels [%s] in data blocks [%s]\n', num2str(iCh0(:)'), num2str(iDataBlks(:)')))
iColor = 1;
for iBlk = iDataBlks

    if isempty(iCh)
        iChBlk  = [];
    else
        iChBlk  = iCh{iBlk};
    end
    
    ch      = procElem.GetMeasList(iBlk);
    chVis   = find(ch.MeasListVis(iChBlk)==1);
    d       = [];
    dStd    = [];
    t       = [];
    nTrials = [];    
    
    % Get plot data from dataTree
    if datatype == maingui.buttonVals.RAW
        d = procElem.GetDataTimeSeries('same', iBlk);
        t = procElem.GetTime(iBlk);
    elseif datatype == maingui.buttonVals.OD
        d = procElem.GetDod(iBlk);
        t = procElem.GetTime(iBlk);
    elseif datatype == maingui.buttonVals.CONC
        d = procElem.GetDc(iBlk);
        t = procElem.GetTime(iBlk);
    elseif datatype == maingui.buttonVals.OD_HRF
        d = procElem.GetDodAvg([], iBlk);
        t = procElem.GetTHRF(iBlk);
        if showStdErr
            dStd = procElem.GetDodAvgStd(iBlk);
        end
        nTrials = procElem.GetNtrials(iBlk);
        if isempty(condition)
            return;
        end
    elseif datatype == maingui.buttonVals.CONC_HRF
        d = procElem.GetDcAvg([], iBlk);
        t = procElem.GetTHRF(iBlk);
        if showStdErr
            dStd = procElem.GetDcAvgStd([], iBlk) * sclConc;
        end
        nTrials = procElem.GetNtrials(iBlk);
        if isempty(condition)
            return;
        end
    end
    
    %%% Plot data
    if ~isempty(d)
        xx = xlim();
        yy = ylim();
        if strcmpi(get(hAxes,'ylimmode'),'manual')
            flagReset = 0;
        else
            flagReset = 1;
        end
        hold on
        
        % Set the axes ranges
        if flagReset==1
            set(hAxes,'xlim',[t(1), t(end)]);
            set(hAxes,'ylimmode','auto');
        else
            xlim(xx);
            ylim(yy);
        end
        
        linecolors = linecolor(iColor:iColor+length(iChBlk)-1,:);
        
        % Plot data
        if datatype == maingui.buttonVals.RAW || datatype == maingui.buttonVals.OD || datatype == maingui.buttonVals.OD_HRF
            if  datatype == maingui.buttonVals.OD_HRF
                d = d(:,:,condition);
            end
            d = procElem.reshape_y(d, ch.MeasList);
            DisplayDataRawOrOD(t, d, dStd, iWl, iChBlk, chVis, nTrials, condition, linecolors);
        elseif datatype == maingui.buttonVals.CONC || datatype == maingui.buttonVals.CONC_HRF
            if  datatype == maingui.buttonVals.CONC_HRF
                d = d(:,:,:,condition);
            end
            d = d * sclConc;
            DisplayDataConc(t, d, dStd, hbType, iChBlk, chVis, nTrials, condition, linecolors);
        end
    end
    iColor = iColor+length(iChBlk);
end

% Set Zoom on/off
if maingui.plotViewOptions.zoom == true
    h=zoom;
    set(h,'ButtonDownFilter',@myZoom_callback);
    set(h,'enable','on')
else
    zoom off;
end

% Set data window X and Y borders
if ~isempty(maingui.plotViewOptions.ranges.Y)
    ylim(maingui.plotViewOptions.ranges.Y);
else
    ylim('auto')
end
if ~isempty(maingui.plotViewOptions.ranges.X)
    xlim(maingui.plotViewOptions.ranges.X);
else
    xlim('auto')
    if ~isempty(t)
        set(hAxes, 'xlim',[t(1), t(end)]);
    end
end

DisplayAux(handles, hAxes);
if get(handles.checkboxShowExcludedTimeManual, 'value')
    DisplayExcludedTime(handles, 'manual', hAxes);
end
if get(handles.checkboxShowExcludedTimeAuto, 'value')
    DisplayExcludedTime(handles, 'auto', hAxes);
end
if get(handles.checkboxShowExcludedTimeAutoByChannel, 'value')
    DisplayExcludedTime(handles, 'autoch', hAxes);
end
DisplayStim(handles, hAxes);
UpdateCondPopupmenu(handles);
UpdateDatatypePanel(handles);
UpdateChildGuis(handles);
% DisplayPvalues();



% -------------------------------------------------------------------------
function flag = myZoom_callback(obj, event_obj)
if strcmpi( get(obj,'Tag'), 'axesData')
    flag = 0;
else
    flag = 1;
end



% ----------------------------------------------------------------------------------
function DisplayStim(handles, hAxes)
global maingui
dataTree = maingui.dataTree;
procElem = dataTree.currElem;

if ~strcmp(procElem.type, 'run')
    return;
end

if nargin<2
    hAxes = maingui.axesData.handles.axes;
end
if ~ishandles(hAxes)
    return;
end
axes(hAxes);
hold on;

datatype = GetDatatype(handles);
if datatype == maingui.buttonVals.RAW_HRF
    return;
end
if datatype == maingui.buttonVals.OD_HRF
    return;
end
if datatype == maingui.buttonVals.CONC_HRF
    return;
end

%%% Plot stim marks. This has to be done before plotting exclude time
%%% patches because stim legend doesn't work otherwise.
t          = procElem.GetTimeCombined();
s          = procElem.GetStimStatus(t);
stimVals   = procElem.GetstimStatusSettings();
CondColTbl = procElem.CondColTbl;

% Plot included and excluded stims
yrange = GetAxesYRangeForStimPlot(hAxes);
hLg=[];
idxLg=[];
kk=1;
for iCond = 1:size(s,2)
    iS = find(s(:,iCond) ~= stimVals.none);
    for ii=1:length(iS)
        linestyle = '';
        if     s(iS(ii),iCond) == stimVals.excl_auto
            linestyle = '-.';
        elseif s(iS(ii),iCond) == stimVals.excl_manual
            linestyle = '--';
        elseif s(iS(ii),iCond) == stimVals.incl
            linestyle = '-';
        end
        hl = plot(t(iS(ii))*[1 1], yrange, linestyle);
        set(hl, 'linewidth',1.5);
        set(hl, 'color',CondColTbl(iCond,:));
    end
    
    % Get handles and indices of each stim condition
    % for legend display
    if ~isempty(iS)
        % We don't want dashed lines appearing in legend, so
        % we draw invisible solid stims over all stims to
        % trick the legend into only showing solid lines.
        hLg(kk) = plot(t(iS(1))*[1 1],yrange,'-', 'linewidth',4, 'visible','off');
        set(hLg(kk),'color',CondColTbl(iCond,:));
        idxLg(kk) = iCond;
        kk=kk+1;
    end
end
DisplayCondLegend(hLg, idxLg);
hold off
set(hAxes,'ygrid','on');
                
                
                
                
% ----------------------------------------------------------------------------------
function DisplayCondLegend(hLg, idxLg, hAxes)
global maingui
dataTree = maingui.dataTree;
procElem = dataTree.currElem;

if nargin<3
    hAxes = maingui.axesData.handles.axes;
end
if ~ishandles(hAxes)
    return;
end
axes(hAxes);
hold on;

if isempty(hLg)
    return;    
end
if isempty(idxLg)
    return;    
end
[idxLg, k] = sort(idxLg);
CondNames = procElem.CondNames;
if ishandles(hLg)
    legend(hLg(k), CondNames(idxLg));
end



% ----------------------------------------------------------------------------------
function DisplayAux(handles, hAxes)
global maingui

% Check to make sure data type is timecourse data
if GetDatatype(handles) == maingui.buttonVals.OD_HRF
    return;
end
if GetDatatype(handles) == maingui.buttonVals.CONC_HRF
    return;
end

if nargin<2
    hAxes = maingui.axesData.handles.axes;
end
if ~ishandles(hAxes)
    return;
end
axes(hAxes);
hold on;

aux = maingui.dataTree.currElem.GetAuxiliary();
t = maingui.dataTree.currElem.GetTime();

% Check if there's any aux 
if isempty(aux) || isempty(t)
    set(handles.checkboxPlotAux, 'enable','off');
    set(handles.popupmenuAux, 'enable','off');
    return;
end
if isempty(aux.names)
    set(handles.checkboxPlotAux, 'enable','off');
    set(handles.popupmenuAux, 'enable','off');
    return;
end

% Enable aux gui objects and set their values based on the aux values
onoff = get(handles.checkboxPlotAux, 'value');
if onoff==0
    return;
end
iAux = get(handles.popupmenuAux, 'value');
set(handles.checkboxPlotAux, 'enable','on');
set(handles.popupmenuAux, 'enable','on');
if iAux==0
    set(handles.popupmenuAux, 'value',1);
end
set(handles.popupmenuAux, 'string',aux.names);

hold on
data = aux.data(:,iAux)-min(aux.data(:,iAux));
r = ylim();
yrange = [r(1) - (r(2)-r(1)), r(1)];
h = plot(t, yrange(1)+(yrange(2)-yrange(1)) * (data/(max(data)-min(data))), 'k');
set(h,'linewidth',1);
hold off


% ----------------------------------------------------------------------------------
function DisplayPvalues()
global maingui

pValues = maingui.dataTree.currElem.GetPvalues();
if isempty(pValues)
    return;
end

for iBlk=1:length(pValues)
    maingui.logger.Write(sprintf('P-Values for %s, data block %d:\n', maingui.dataTree.currElem.GetName(), iBlk));
    pretty_print_matrix(pValues{iBlk});
end

% guiname = sprintf('%s P-Values', maingui.dataTree.currElem.GetName());
% 
% if ishandles(maingui.handles.pValuesFig)
%     clf(maingui.handles.pValuesFig);
% else
%     maingui.handles.pValuesFig = figure('toolbar','none', 'menubar','none', 'name',guiname, 'numbertitle','off');
% end
% ht = uitable('parent',maingui.handles.pValuesFig, 'units','normalized', 'position',[.2,.2,.5,.5]);
% set(ht, 'data', pValues{iBlk})
% 



% ----------------------------------------------------------------------------------
function Update(varargin)
global maingui

% Args: 1) Which application called us? 2) What action is being performed?
guiname = '';
action = '';
if nargin>0
    guiname = varargin{1};
end
if nargin>1
    action = varargin{2};
end

% Redisplay main GUI based on what was done in the calling app
switch(guiname)
    case 'PlotProbeGUI'
        set(maingui.handles.menuItemPlotProbeGUI, 'checked','off'); 
    case 'StimEditGUI'
        if strcmp(action, 'close')
            set(maingui.handles.menuItemStimEditGUI, 'checked','off'); 
        else
            Display(maingui.handles, maingui.handles.axesData);  % Redisplay data axes since stims might have edited
        end
    case 'ProcStreamOptionsGUI'
        set(maingui.handles.pushbuttonProcStreamOptionsGUI, 'value',0);  % Redisplay enable/disable toggle button 
    case 'ProcStreamEditGUI'
        if strcmp(action, 'close')
            set(maingui.handles.menuItemProcStreamEditGUI, 'checked','off'); 
        else
            idx = FindChildGuiIdx('ProcStreamOptionsGUI');
            maingui.childguis(idx).Update();
        end
    case 'DataTreeClass'
        if ~isempty(maingui.handles)
            iGroup = varargin{2}(1);
            iSubj = varargin{2}(2);
            iRun = varargin{2}(3);
            maingui.logger.Write(sprintf('Processing iGroup=%d, iSubj=%d, iRun=%d\n', iGroup, iSubj, iRun));
            listboxGroupTree_Callback([], [iGroup, iSubj, iRun], maingui.handles);
        end
    case 'PatchCallback'
        Display(maingui.handles, maingui.handles.axesData);  % Redisplay data axes since stims might have edited        
        
end



% --------------------------------------------------------------------
function menuItemResetGroupFolder_Callback(hObject, eventdata, handles)
resetGroupFolder();



% --------------------------------------------------------------------
function pushbuttonPanLeft_Callback(hObject, eventdata, handles)
global maingui
procElem = maingui.dataTree.currElem;
iCh0     = maingui.axesSDG.iCh;
datatype = GetDatatype(handles);

iDataBlks = procElem.GetDataBlocksIdxs(iCh0);
for iBlk = iDataBlks
    % Get plot data from dataTree
    if datatype == maingui.buttonVals.RAW
        t = procElem.GetTime(iBlk);
    elseif datatype == maingui.buttonVals.OD
        t = procElem.GetTime(iBlk);
    elseif datatype == maingui.buttonVals.CONC
        t = procElem.GetTime(iBlk);
    elseif datatype == maingui.buttonVals.OD_HRF
        t = procElem.GetTHRF(iBlk);
    elseif datatype == maingui.buttonVals.CONC_HRF
        t = procElem.GetTHRF(iBlk);
    end
end
axes(handles.axesData)
xrange = xlim();
xm = mean(xrange);
xd = xrange(2)-xrange(1);
if get(hObject,'string')=='<'
    if xrange(1)-xd/5 >= 0
        xlim( max(min(xm + [-xd xd]/2 - xd/5, t(end)),0) );
    else
        xlim( [0 xd] );
    end
elseif get(hObject,'string')=='>'
    if xrange(2)+xd/5 <= t(end)
        xlim( max(min(xm + [-xd xd]/2 + xd/5, t(end)),0) );
    else
        xlim( t(end) + [-xd 0] );
    end
end



% --------------------------------------------------------------------
function pushbuttonPanRight_Callback(hObject, eventdata, handles)
pushbuttonPanLeft_Callback(hObject, eventdata, handles)



% --------------------------------------------------------------------
function pushbuttonResetView_Callback(hObject, eventdata, handles)
global maingui
set(handles.checkboxFixRangeX, 'value',0);
set(handles.checkboxFixRangeY, 'value',0);
maingui.plotViewOptions.ranges.X = [];
maingui.plotViewOptions.ranges.Y = [];
Display(handles, hObject);





% --------------------------------------------------------------------
function checkboxFixRangeX_Callback(hObject, eventdata, handles)
global maingui
if get(hObject,'value')==1
    maingui.plotViewOptions.ranges.X = str2num(get(handles.editFixRangeX, 'string'));
else
    maingui.plotViewOptions.ranges.X = [];    
end
Display(handles, hObject);



% --------------------------------------------------------------------
function checkboxFixRangeY_Callback(hObject, eventdata, handles)
global maingui
if get(hObject,'value')==1
    maingui.plotViewOptions.ranges.Y = str2num(get(handles.editFixRangeY, 'string'));
else
    maingui.plotViewOptions.ranges.Y = [];
end
Display(handles, hObject);




% --------------------------------------------------------------------
function editFixRangeX_Callback(hObject, eventdata, handles)
checkboxFixRangeX_Callback(handles.checkboxFixRangeX, eventdata, handles);


% --------------------------------------------------------------------
function editFixRangeY_Callback(hObject, eventdata, handles)
checkboxFixRangeY_Callback(handles.checkboxFixRangeY, eventdata, handles);




% --------------------------------------------------------------------
function menuItemGroupViewSettingGroup_Callback(hObject, eventdata, handles)
global maingui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = maingui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.GROUP);    
    set(handles.listboxGroupTree, 'value',iListNew, 'string',maingui.listboxGroupTreeParams.listMaps(views.GROUP).names);

    maingui.listboxGroupTreeParams.viewSetting = views.GROUP;    
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end




% --------------------------------------------------------------------
function menuItemGroupViewSettingSubjects_Callback(hObject, eventdata, handles)
global maingui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = maingui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.SUBJS);    
    set(handles.listboxGroupTree, 'value',iListNew, 'string',maingui.listboxGroupTreeParams.listMaps(views.SUBJS).names);

    maingui.listboxGroupTreeParams.viewSetting = views.SUBJS;
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
end




% --------------------------------------------------------------------
function menuItemGroupViewSettingRuns_Callback(hObject, eventdata, handles)
global maingui

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end
views = maingui.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    iListNew = FindGroupDisplayListMatch(views.RUNS);
    set(handles.listboxGroupTree, 'value',iListNew, 'string', maingui.listboxGroupTreeParams.listMaps(views.RUNS).names);

    maingui.listboxGroupTreeParams.viewSetting = views.RUNS;
    set(handles.menuItemGroupViewSettingGroup,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
end


% --------------------------------------------------------------------
function checkboxPlotAux_Callback(hObject, eventdata, handles)
Display(handles, hObject);



% --------------------------------------------------------------------
function popupmenuAux_Callback(hObject, eventdata, handles)
Display(handles, hObject);



% --------------------------------------------------------------------
function menuItemCopyPlots_Callback(hObject, eventdata, handles)

xf = 1.5;
yf = 1.5;
hf = figure();
set(hf, 'units','characters');
p = get(hf, 'position');
set(hf,'position',[p(1), p(2), xf*p(3), yf*p(4)]);
p = guiOutsideScreenBorders(hf);
set(hf, 'position', [p(1), p(2)-5, p(3), p(4)]);

figure(hf);

% DISPLAY DATA
hAxesData = axes('units','normalized', 'position',[0.05 0.30 0.60 0.50]);
DisplayData(handles, [], hAxesData);

figure(hf);

% DISPLAY SDG
hAxesSDG = axes('units','normalized', 'position',[0.67 0.30 0.30 0.50]);
DisplayAxesSDG(hAxesSDG);



% --------------------------------------------------------------------
function checkboxExcludeTime_Callback(hObject, eventdata, handles)
global maingui

hAxesData = maingui.axesData.handles.axes;

if isempty(maingui.axesSDG.iCh)  % Don't let user exclude if axesData isn't plotting anything
    errordlg('Select a channel before manually excluding time points.', 'No channels selected');
    set(hObject, 'value', 0);
    return; 
end

if get(hObject, 'value') == 1 % If in exclude time mode
    zoom off
    set(hAxesData,'ButtonDownFcn', 'MainGUI(''ExcludeTime_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    set(get(hAxesData,'children'), 'ButtonDownFcn', 'MainGUI(''ExcludeTime_ButtonDownFcn'',gcbo,[],guidata(gcbo))');
    MainGUI_EnableDisablePlotEditMode(handles, 'off');
else
    zoom on
    MainGUI_EnableDisablePlotEditMode(handles, 'on');
end
Display(handles, hObject);



% --------------------------------------------------------------------
function checkboxShowExcludedTimeManual_Callback(hObject, eventdata, handles)

if get(hObject, 'value')==1
    set(handles.checkboxShowExcludedTimeAuto, 'value',0) 
    set(handles.checkboxShowExcludedTimeAutoByChannel, 'value',0) 
end
Display(handles, hObject);


% --------------------------------------------------------------------
function checkboxShowExcludedTimeAuto_Callback(hObject, eventdata, handles)

if get(hObject, 'value')==1
    set(handles.checkboxShowExcludedTimeManual, 'value',0) 
    set(handles.checkboxShowExcludedTimeAutoByChannel, 'value',0) 
end
Display(handles, hObject);


% --------------------------------------------------------------------
function checkboxShowExcludedTimeAutoByChannel_Callback(hObject, eventdata, handles)

if get(hObject, 'value')==1
    set(handles.checkboxShowExcludedTimeManual, 'value',0) 
    set(handles.checkboxShowExcludedTimeAuto, 'value',0) 
end
Display(handles, hObject);


% --------------------------------------------------------------------
function ExcludeTime_ButtonDownFcn(hObject, eventdata, handles)
global maingui

% Make sure the user clicked on the axes and not 
% some other object on top of the axes
if ~strcmp(get(hObject,'type'),'axes')
    return;
end

point1 = get(hObject,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
point2 = get(hObject,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);                  % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);
p2 = max(point1,point2);

iCh = maingui.axesSDG.iCh;
iDataBlks =  maingui.dataTree.currElem.GetDataBlocksIdxs(iCh);
for iBlk=1:iDataBlks
    
    % Get and set the excuded time points in tIncMan
    t = maingui.dataTree.currElem.GetTime(iBlk);
    lst = find(t>=p1(1) & t<=p2(1));
    maingui.dataTree.currElem.SetTincMan(lst, iBlk);
    
    % Reject all stims that fall within the excluded time
    maingui.dataTree.currElem.StimReject(t, iBlk);

end

% Display excluded time and rejected stims
Display(handles, hObject);



% --------------------------------------------------------------------
function ExcludeCh_ButtonDownFcn(hObject, eventdata, handles)
global maingui
disp('Exclude button down fcn');



% --------------------------------------------------------------------
function menuItemExportHRF_Callback(hObject, eventdata, handles)
global maingui

out = ExportDataGUI(maingui.dataTree.currElem.name,'.txt','HRF', 'userargs');
if isempty(out.format) && isempty(out.datatype)
    return;
end
switch(out.procElemSelect)
    case 'currentonly'
        procElemSelect = 'current';
    case 'all'
        procElemSelect = 'all';
    otherwise
end
maingui.dataTree.currElem.ExportHRF(procElemSelect);


% --------------------------------------------------------------------
function menuItemExportSubjHRFMean_Callback(hObject, eventdata, handles)
global maingui

if  ~maingui.dataTree.currElem.IsGroup()
    MessageBox('Exporting mean HRF at this time, only applies to the currently selected group. Please select a group in the Current Processing Element panel. Then rerun the export')
    return 
end

out = ExportDataGUI(maingui.dataTree.currElem.name,'.txt','Subjects HRF mean');
if isempty(out.datatype)
    return;
end
maingui.dataTree.currElem.ExportMeanHRF(out.trange);



% --------------------------------------------------------------------
function menuItemUpdateCheck_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemUpdateCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cfg = ConfigFileClass();
if (strcmp(hObject.Checked,'on'))
    hObject.Checked = 'off';
    cfg.SetValue('Check For Updates','off');
else
    hObject.Checked = 'on';
    cfg.SetValue('Check For Updates','on');
end
cfg.Save();
cfg.Close();



% --------------------------------------------------------------------
function menuItemPowerSpectrum_Callback(hObject, eventdata, handles)
% hObject    handle to menuItemPowerSpectrum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global maingui;
iCh = maingui.axesSDG.iCh;
n_channels = length(iCh);
if n_channels > 0
    iSrcDet = maingui.axesSDG.iSrcDet;
    colors = maingui.axesSDG.linecolor;
    d = maingui.dataTree.currElem.acquired.data.dataTimeSeries;
    sf = maingui.dataTree.currElem.acquired.data.time(2) - maingui.dataTree.currElem.acquired.data.time(1);
    fs = 1/sf;
    try
       close(maingui.spectrumFigureHandle);
    catch
    end
    maingui.spectrumFigureHandle = figure('NumberTitle', 'off', 'Name', 'PSD of selected channels');
    n = 3;
    m = ceil(n_channels / n);
    for i = 1:n_channels
        % 100 sec window with 50% overlap
        window = floor(100 / sf);
        overlap = window / 2;
        bins = 2048;
        [pxx,f] = pwelch(d(:,iCh(i)), window, overlap, bins, fs);
        subplot(m,n,i);
        plot(f, 10*log10(pxx), 'Color', colors(i,:));
        title([num2str(iSrcDet(i,1)), ' \rightarrow ', num2str(iSrcDet(i,2))]);
        xlim([0,fs/2]);
        xlabel(sprintf('Frequency (Hz)'));
        ylabel(sprintf('PSD (dB)\n'));
    end
else
    errordlg('Cannot calculate power spectra with no channels selected.', 'No channels selected'); 
end



% -------------------------------------------------------------------------------
function togglebuttonMinimizeGUI_Callback(hObject, eventdata, handles)
u0 = get(handles.MainGUI, 'units');
k = [1.0, 1.0, 0.8, 0.8];
p0 = get(handles.MainGUI, 'position');
if strcmp(get(hObject, 'tooltipstring'), 'Minimize GUI Window')
    set(hObject, 'tooltipstring', 'Maximize GUI Window')
    set(hObject, 'string', '+');
    p = k.*p0;

    % Shift position closer to screen edge since GUI got smaller
	p(1) = p(1) + abs(p0(3)-p(3));
	p(2) = p(2) + abs(p0(4)-p(4));
else
    set(hObject, 'tooltipstring', 'Minimize GUI Window')
    set(hObject, 'string', '--');
    p = p0./k;

    % Shift position away from screen edge since GUI got bigger
	p(1) = p(1) - abs(p0(3)-p(3));
	p(2) = p(2) - abs(p0(4)-p(4));
end
pause(.2)
set(handles.MainGUI, 'position', p);
p = guiOutsideScreenBorders(handles.MainGUI);
set(handles.MainGUI, 'units','characters', 'position',p);
set(handles.MainGUI, 'units',u0);



% -------------------------------------------------------------------------------
function pushbuttonResetExcludedTimeCh_Callback(hObject, eventdata, handles)
global maingui
if isa(maingui.dataTree.currElem, 'RunClass')
    ch = MenuBox('Are you sure you would like to re-enable all excluded channels and time points?',{'Yes','No'});
    if ch == 2
        return
    end
    maingui.dataTree.currElem.InitTincMan();
    iCh = maingui.axesSDG.iCh;
    iDataBlks =  maingui.dataTree.currElem.GetDataBlocksIdxs(iCh);
    for iBlk = 1:iDataBlks
        t = maingui.dataTree.currElem.GetTime(iBlk);
        maingui.dataTree.currElem.StimInclude(t, iBlk);
        maingui.dataTree.currElem.InitMlActMan(iBlk);
    end
    Display(handles, hObject);
else
    errordlg('Select a run to reset its excluded channels and time points.','No run selected');
end



