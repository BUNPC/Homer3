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

if isempty(varargin)    
    hmr.format = 'snirf';
else
    hmr.format = varargin{1};
end


hmr.handles.this = hObject;
hmr.handles.stimGUI = [];
hmr.handles.proccessOpt = [];
hmr.handles.plotProbe = [];
hmr.files    = [];
hmr.dataTree = [];
hmr.guiMain  = [];

set(hObject, 'units', 'normalized', 'position',[.25, .20, .65, .75])

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

% Get file names 
files = FindFiles(handles);

% Load date files into group tree object
dataTree = DataTreeClass(files, handles, @listboxFiles_Callback);

guiMain   = InitGuiMain(handles, dataTree);
plotprobe = PlotProbeClass(handles);

% If data set has no errors enable window gui objects
Homer3_EnableDisableGUI(handles,'on');

hmr.files     = files;
hmr.dataTree  = dataTree;
hmr.guiMain   = guiMain;
hmr.plotprobe = plotprobe;

% Display data from currently selected processing element
hmr.dataTree.DisplayCurrElem(guiMain);




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
if ~exist('eventdata','var') || isempty(eventdata)
    eventdata = [];
end
if isempty(hmr.handles)
    return;
end


delete(hmr.plotprobe);
delete(hmr.dataTree);
if ishandle(hmr.handles.stimGUI)
    delete(hmr.handles.stimGUI);
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

dataTree  = hmr.dataTree;
files     = hmr.files;
guiMain   = hmr.guiMain;
plotprobe = hmr.plotprobe;

procType = get(hObject,'tag');
switch(procType)
    case 'radiobuttonProcTypeGroup'
        dataTree.currElem.procType = 1;
    case 'radiobuttonProcTypeSubj'
        dataTree.currElem.procType = 2;
    case 'radiobuttonProcTypeRun'
        dataTree.currElem.procType = 3;
end
dataTree.LoadCurrElem(files);
guiMain = UpdateAxesDataCondition(guiMain, dataTree);
dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain); 
dataTree.UpdateCurrElemProcStreamOptionsGUI();

if ishandles(hmr.handles.stimGUI)
    dataTree.group.SetConditions();
    hmr.handles.stimGUI = launchStimGUI(hmr.handles.this, ...
                                        hmr.handles.stimGUI, ...
                                        dataTree.currElem, ...
                                        dataTree.group.CondNames);
end



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

dataTree = hmr.dataTree;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

dataTree.LoadCurrElem(files);
guiMain = UpdateAxesDataCondition(guiMain, dataTree);
if ishandles(hmr.handles.stimGUI)
    hmr.handles.stimGUI = launchStimGUI(hmr.handles.this, ...
                                        hmr.handles.stimGUI, ...
                                        currElem, ...
                                        group.GetConditions());
end
dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain); 
dataTree.UpdateCurrElemProcStreamOptionsGUI();



% --------------------------------------------------------------------
function pushbuttonCalcProcStream_Callback(hObject, eventdata, handles)
global hmr

dataTree = hmr.dataTree;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

dataTree.CalcCurrElem();
dataTree.SaveCurrElem();

dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain); 





% --------------------------------------------------------------------
function listboxFilesErr_Callback(hObject, eventdata, handles)

% TBD: We may want to try fix files with errors



%%%% guiMain

% --------------------------------------------------------------------
function uipanelPlot_SelectionChangeFcn(hObject, eventdata, handles)
global hmr

dataTree  = hmr.dataTree;
guiMain   = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataType(guiMain);
dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain);

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



% --------------------------------------------------------------------
function checkboxPlotHRF_Callback(hObject, eventdata, handles)
global hmr

dataTree  = hmr.dataTree;
guiMain   = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataType(guiMain);
dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain);

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

dataTree = hmr.dataTree;
guiMain = hmr.guiMain;

% Transfer the channels selection to guiMain
guiMain = SetAxesDataCh(guiMain, dataTree.currElem);

% Update the displays of the guiMain and axesSDG axes
dataTree.DisplayCurrElem(guiMain);

% the the modified objects
hmr.guiMain = guiMain;




% --------------------------------------------------------------------
function popupmenuConditions_Callback(hObject, eventdata, handles)
global hmr

dataTree = hmr.dataTree;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataCondition(guiMain);

% Update the display of the guiMain axes
dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain);

% the the modified objects
hmr.guiMain = guiMain;





% --------------------------------------------------------------------
function listboxPlotWavelength_Callback(hObject, eventdata, handles)
global hmr

dataTree  = hmr.dataTree;
guiMain   = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataWl(guiMain, currElem.procElem.SD.Lambda);

% Update the displays of the guiMain and axesSDG axes
dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain);

% the the modified objects
hmr.guiMain = guiMain;





% --------------------------------------------------------------------
function listboxPlotConc_Callback(hObject, eventdata, handles)
global hmr

dataTree  = hmr.dataTree;
guiMain   = hmr.guiMain;
plotprobe = hmr.plotprobe;

% Transfer the channels selection to guiMain
guiMain = GetAxesDataHbType(guiMain);

% Update the displays of the guiMain and axesSDG axes
dataTree.DisplayCurrElem(guiMain);
dataTree.DisplayCurrElem(plotprobe, guiMain);

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

dataTree = hmr.dataTree;
guiMain  = hmr.guiMain;

dataTree.currElem.procElem.Reset();
dataTree.currElem.procElem.Save();
dataTree.currElem.procElem.DisplayGuiMain(guiMain);



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

dataTree  = hmr.dataTree;

if get(hObject, 'value')
    action = 'open';
else
    action = 'close';
end

% Reload current element selection
dataTree.currElem = OpenCurrElemProcStreamOptionsGUI(dataTree.currElem, action);

hmr.handles.proccessOpt = dataTree.currElem.handles.ProcStreamOptionsGUI;



% -------------------------------------------------------------------
function menuItemLaunchStimGUI_Callback(hObject, eventdata, handles)
global hmr

group = hmr.group;

hmr.handles.stimGUI = launchStimGUI(hmr.handles.this, ...
                                    hmr.handles.stimGUI, ...
                                    dataTree.currElem, ...
                                    dataTree.group.CondNames);



% -------------------------------------------------------------------
function hStimGUI = launchStimGUI(hObject, hStimGUI, currElem, CondNamesGroup)

if ishandles(hStimGUI)
    delete(hStimGUI);
end
hStimGUI = stimGUI(currElem, CondNamesGroup, hObject);
set(hStimGUI, 'units','normalized');
set(hStimGUI, 'position',[.01, .05, .60, .80]);


% --------------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global hmr

hmr.dataTree.currElem.procElem.Save();




% --------------------------------------------------------------------
function menuItemViewHRFStdErr_Callback(hObject, eventdata, handles)
global hmr

dataTree = hmr.dataTree;
guiMain = hmr.guiMain;

if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
elseif strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked', 'on')
end

if strcmp(get(hObject, 'checked'), 'on')
    guiMain.showStdErr = true;
elseif strcmp(get(hObject, 'checked'), 'off')
    guiMain.showStdErr = false;
end

DisplayCurrElem(dataTree.currElem, guiMain);

hmr.guiMain = guiMain;



% ---------------------------------------------------------------------------
function checkboxPlotProbe_Callback(hObject, eventdata, handles)
global hmr

dataTree  = hmr.dataTree;
guiMain   = hmr.guiMain;
plotprobe = hmr.plotprobe;

guiMain = GetAxesDataType(guiMain);
plotprobe.active = get(hObject, 'value');
dataTree.DisplayCurrElem(plotprobe, guiMain);

hmr.guiMain   = guiMain;


% --------------------------------------------------------------------
function menuItemProcStreamEdit_Callback(hObject, eventdata, handles)

procStreamGUI();


% --------------------------------------------------------------------
function checkboxApplyProcStreamEditToAll_Callback(hObject, eventdata, handles)
global hmr

if get(hObject, 'value')
    hmr.guiMain.applyEditCurrNodeOnly = false;
else
    hmr.guiMain.applyEditCurrNodeOnly = true;
end
