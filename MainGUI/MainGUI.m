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
positionGUI(hFig, 0.20, 0.10, 0.70, 0.85)
setGuiFonts(hFig);

% Get rid of the useless "might be unsused" warnings for GUI callbacks
checkboxPlotHRF_Callback([]);
checkboxApplyProcStreamEditToAll_Callback([]);
pushbuttonCalcProcStream_Callback([]);
listboxFilesErr_Callback([]);
uipanelPlot_SelectionChangeFcn([]);
menuItemProcStreamEdit_Callback([]);
checkboxPlotProbe_Callback([]);
menuItemSaveGroup_Callback([]);
menuItemViewHRFStdErr_Callback([]);
menuItemLaunchStimGUI_Callback([]);
pushbuttonProcStreamOptionsEdit_Callback([]);
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

set(handles.listboxGroupTree, 'enable', val);
set(handles.radiobuttonProcTypeGroup, 'enable', val);
set(handles.radiobuttonProcTypeSubj, 'enable', val);
set(handles.radiobuttonProcTypeRun, 'enable', val);
set(handles.radiobuttonPlotRaw, 'enable', val);
set(handles.radiobuttonPlotOD,  'enable', val);
set(handles.radiobuttonPlotConc, 'enable', val);
set(handles.checkboxPlotHRF, 'enable', val);
set(handles.textStatus, 'enable', val);


% --------------------------------------------------------------------
function eventdata = MainGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global hmr

hmr = [];

if isempty(varargin)    
    hmr.format = 'snirf';
else
    hmr.format = varargin{1};
end
hmr.gid = 1;
hmr.sid = 2;
hmr.rid = 3;

hmr.dataTree = [];
hmr.Update = @Update;
hmr.handles = [];

% Choose default command line output for MainGUI
handles.output = hObject;
guidata(hObject, handles);

% Set the main GUI version number
[~, V] = MainGUIVersion(hObject);
hmr.version = V;
hmr.childguis = ChildGuiClass().empty();

% Disable and reset all window gui objects
MainGUI_EnableDisableGUI(handles,'off');
MainGUI_Init(handles, {'zbuffer'});

% Load date files into group tree object
hmr.dataTree  = LoadDataTree(hmr.format);
if hmr.dataTree.IsEmpty()
    return;
end
InitGuiControls(handles);

% If data set has no errors enable window gui objects
MainGUI_EnableDisableGUI(handles,'on');

% Display data from currently selected processing element
DisplayGroupTree(handles);
DisplayData(handles, hObject);

hmr.childguis(1) = ChildGuiClass('ProcStreamEditGUI');
hmr.childguis(2) = ChildGuiClass('ProcStreamOptionsGUI');
hmr.childguis(3) = ChildGuiClass('StimEditGUI');
hmr.childguis(4) = ChildGuiClass('PlotProbeGUI');

hmr.handles = handles;





% --------------------------------------------------------------------
function varargout = MainGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;



% --------------------------------------------------------------------
function [eventdata, handles] = MainGUI_DeleteFcn(hObject, eventdata, handles)
global hmr;

if ishandles(hObject)
    delete(hObject)
end
if isempty(hmr)
    return;
end
if isempty(hmr.dataTree)
    return;
end

% Delete Child GUIs before deleted the dataTree that all GUIs use.
for ii=1:length(hmr.childguis)
    hmr.childguis(ii).Close();
end
delete(hmr.dataTree);
hmr = [];
clear hmr;


% --------------------------------------------------------------------------------------------
function DisplayGroupTree(handles)
global hmr;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize listboxGroupTree params struct
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hmr.listboxGroupTreeParams = struct('listMaps',struct('names',{{}}, 'idxs', []), ...
                                    'views', struct('ALL',1, 'SUBJS',2, 'RUNS',3), ...
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
listboxGroup = hmr.listboxGroupTreeParams.listMaps(viewSetting).names;
nFiles = length(hmr.listboxGroupTreeParams.listMaps(views.RUNS).names);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set listbox used for displaying files that did not load correctly
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
listboxFilesErr = cell(length(hmr.dataTree.filesErr),1);
nFilesErr=0;
for ii=1:length(hmr.dataTree.filesErr)
    if hmr.dataTree.filesErr(ii).isdir
        listboxFilesErr{ii} = hmr.dataTree.filesErr(ii).name;
    elseif ~isempty(hmr.dataTree.filesErr(ii).subjdir)
        listboxFilesErr{ii} = ['    ', hmr.dataTree.filesErr(ii).filename];
        nFilesErr=nFilesErr+1;
    else
        listboxFilesErr{ii} = hmr.dataTree.filesErr(ii).name;
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
global hmr

if isempty(hObject)
    return;
end
proclevel = GetProclevel(handles);
iList = get(handles.listboxGroupTree,'value');
[iGroup,iSubj,iRun] = MapList2GroupTree(iList);
switch(proclevel)
	case hmr.gid
        if iGroup==0
            iGroup=1;
        end
        hmr.dataTree.SetCurrElem(iGroup);
    case hmr.sid
        if iGroup==0
            iGroup=1;
        end
        if iSubj==0
            iSubj=1;
        end
        hmr.dataTree.SetCurrElem(iGroup, iSubj);
    case hmr.rid
        if iGroup==0
            iGroup=1;
        end
        if iSubj==0
            iSubj=1;
        end
        if iRun==0
            iRun=1;
        end
        hmr.dataTree.SetCurrElem(iGroup, iSubj, iRun);
end
[iGroup, iSubj, iRun] = hmr.dataTree.GetCurrElemIndexID();
listboxGroupTree_Callback([], [iGroup,iSubj,iRun], handles)
DisplayData(handles, hObject);



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
DisplayData(handles, hObject0);


% --------------------------------------------------------------------
function [eventdata, handles] = pushbuttonCalcProcStream_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

% Save original selection in listboxGroupTree because it'll change during auto processing 
val0 = get(handles.listboxGroupTree, 'value');

% Set the display status to pending. In order to avoid redisplaying 
% in a single callback thread in functions called from here which 
% also call DisplayData
hmr.dataTree.CalcCurrElem();

% Restore original selection listboxGroupTree
set(handles.listboxGroupTree, 'value',val0);

h = waitbar(0,'Auto-saving group processing results. Please wait ...');
hmr.dataTree.SaveCurrElem();
close(h);
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = listboxFilesErr_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end

% TBD: We may want to try fix files with errors



% --------------------------------------------------------------------
function [eventdata, handles] = uipanelPlot_SelectionChangeFcn(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

if strcmp(get(hObject, 'tag'), 'radiobuttonPlotRaw')
    set(handles.checkboxPlotHRF, 'value',0);
elseif strcmp(get(hObject, 'tag'), 'radiobuttonPlotOD') && isempty(hmr.dataTree.currElem.GetDodAvg())
    if isa(hmr.dataTree.currElem, 'RunClass')
        set(handles.checkboxPlotHRF, 'value',0);
    end
elseif strcmp(get(hObject, 'tag'), 'radiobuttonPlotConc') && isempty(hmr.dataTree.currElem.GetDcAvg())
    if isa(hmr.dataTree.currElem, 'RunClass')
        set(handles.checkboxPlotHRF, 'value',0);
    end
end
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function UpdateDatatypePanel(handles)
global hmr
datatype   = GetDatatype(handles);
if datatype == hmr.buttonVals.RAW || datatype == hmr.buttonVals.RAW_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == hmr.buttonVals.OD || datatype == hmr.buttonVals.OD_HRF
    set(handles.listboxPlotWavelength, 'visible','on');
    set(handles.listboxPlotConc, 'visible','off');
elseif datatype == hmr.buttonVals.CONC || datatype == hmr.buttonVals.CONC_HRF
    set(handles.listboxPlotWavelength, 'visible','off');
    set(handles.listboxPlotConc, 'visible','on');
end



% --------------------------------------------------------------------
function [eventdata, handles] = checkboxPlotHRF_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end
if get(hObject, 'value')==1
    if ~isempty(hmr.dataTree.currElem.GetDcAvg())
        set(handles.radiobuttonPlotConc, 'enable', 'on');
        set(handles.radiobuttonPlotConc, 'value', 1);
    elseif ~isempty(hmr.dataTree.currElem.GetDodAvg())
        set(handles.radiobuttonPlotOD, 'enable', 'on');
        set(handles.radiobuttonPlotOD, 'value', 1);
    end
end
DisplayData(handles, hObject);


% --------------------------------------------------------------------
function [eventdata, handles] = guiControls_ButtonDownFcn(hObject, eventdata, handles)

% Make sure the user clicked on the axes and not
% some other object on top of the axes
if ~strcmp(get(hObject,'type'),'axes')
    return;
end


% --------------------------------------------------------------------
function [eventdata, handles] = axesSDG_ButtonDownFcn(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end
dataTree = hmr.dataTree;
if dataTree.IsEmpty()
    return;
end

% Set channels selection 
SetAxesDataCh();

if ~isempty(hmr.plotViewOptions.ranges.X)
    axes(handles.axesData)
    xlim('auto')
end
if ~isempty(hmr.plotViewOptions.ranges.Y)
    axes(handles.axesData)
    ylim('auto')
end

% Update the data axes
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = popupmenuConditions_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = listboxPlotWavelength_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = listboxPlotConc_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemChangeGroup_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

fmt = hmr.format;

% Change directory
pathnm = uigetdir( cd, 'Pick the new directory' );
if pathnm==0
    return;
end
cd(pathnm);
hGui=get(get(hObject,'parent'),'parent');
MainGUI_DeleteFcn(hGui,[],handles);

% restart
MainGUI(fmt);



% --------------------------------------------------------------------
function menuItemExit_Callback(hObject, eventdata, handles)
if ~ishandles(hObject)
    return;
end
hGui=get(get(hObject,'parent'),'parent');
MainGUI_DeleteFcn(hGui,eventdata,handles);



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemReset_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end
dataTree = hmr.dataTree;
dataTree.currElem.Reset();
dataTree.currElem.Save();
DisplayData(handles, hObject);


% --------------------------------------------------------------------
function [eventdata, handles] = menuCopyCurrentPlot_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

currElem = hmr.dataTree.currElem;
hf = figure;
set(hf, 'color', [1 1 1]);
fields = fieldnames(hmr.buttonVals);
plotname = sprintf('%s_%s', currElem.name, fields{GetDatatype(handles)});
set(hf,'name', plotname);


% DISPLAY DATA
hmr.axesData.handles.axes = axes('position',[0.05 0.05 0.6 0.9]);

% DISPLAY SDG
hmr.axesSDG.handles.axes = axes('position',[0.65 0.05 0.3 0.9]);
axis off

% TBD: Display current element without help from dataTree



% --------------------------------------------------------------------
function [eventdata, handles] = pushbuttonProcStreamOptionsEdit_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

idx = FindChildGuiIdx('ProcStreamOptionsGUI');
if get(hObject, 'value')
    hmr.childguis(idx).Launch(hmr.applyEditCurrNodeOnly);
else
    hmr.childguis(idx).Close();
end



% -------------------------------------------------------------------
function [eventdata, handles] = menuItemLaunchStimGUI_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

idx = FindChildGuiIdx('StimEditGUI');
hmr.childguis(idx).Launch();



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemSaveGroup_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end
hmr.dataTree.currElem.Save();



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemViewHRFStdErr_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
elseif strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked', 'on')
end
DisplayData(handles, hObject);



% ---------------------------------------------------------------------------
function [eventdata, handles] = checkboxPlotProbe_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

idx = FindChildGuiIdx('PlotProbeGUI');
if get(hObject, 'value')
    hmr.childguis(idx).Launch(GetDatatype(handles), GetCondition(handles));
else
    hmr.childguis(idx).Close();
end



% --------------------------------------------------------------------
function [eventdata, handles] = menuItemProcStreamEdit_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

checked = get(hObject,'checked');
idx = FindChildGuiIdx('ProcStreamEditGUI');
if checked
    hmr.childguis(idx).Launch();
else
    hmr.childguis(idx).Close();
end


% --------------------------------------------------------------------
function [eventdata, handles] = checkboxApplyProcStreamEditToAll_Callback(hObject, eventdata, handles)
global hmr
if ~ishandles(hObject)
    return;
end

if get(hObject, 'value')
    hmr.applyEditCurrNodeOnly = false;
else
    hmr.applyEditCurrNodeOnly = true;
end
UpdateArgsChildGuis(handles);



% --------------------------------------------------------------------
function idx = FindChildGuiIdx(name)
global hmr

for ii=1:length(hmr.childguis)
    if strcmp(hmr.childguis(ii).GetName, name)
        break;
    end
end
idx = ii;


% --------------------------------------------------------------------
function UpdateArgsChildGuis(handles)
global hmr
if isempty(hmr.childguis)
    return;
end

hmr.childguis(FindChildGuiIdx('PlotProbeGUI')).UpdateArgs(GetDatatype(handles), GetCondition(handles));
hmr.childguis(FindChildGuiIdx('ProcStreamOptionsGUI')).UpdateArgs(hmr.applyEditCurrNodeOnly);


% --------------------------------------------------------------------
function UpdateChildGuis(handles)
global hmr
if isempty(hmr.childguis)
    return;
end
UpdateArgsChildGuis(handles)
for ii=1:length(hmr.childguis)
    hmr.childguis(ii).Update();
end


% ----------------------------------------------------------------------------------
function hObject = DisplayData(handles, hObject)
global hmr


% Some callbacks which call DisplayData serve double duty as called functions 
% from other callbacks which in turn call DisplayData. To avoid double or
% triple redisplaying in a single thread, exit DisplayData if hObject is
% not a handle. 
if ~exist('hObject','var')
    hObject=[];
end
if ~ishandles(hObject)
    return;
end
if isempty(handles)
    return;
end

dataTree = hmr.dataTree;
procElem = dataTree.currElem;
EnableDisableGuiPlotBttns(handles);

hAxes = hmr.axesData.handles.axes;
if ~ishandles(hAxes)
    return;
end

axes(hAxes)
cla;
legend off
set(hAxes,'ygrid','on');

linecolor  = hmr.axesData.linecolor;
linestyle  = hmr.axesData.linestyle;
datatype   = GetDatatype(handles);
condition  = GetCondition(handles);
iCh0       = hmr.axesSDG.iCh;
iWl        = GetWl(handles);
hbType     = GetHbType(handles);
sclConc    = hmr.sclConc;        % convert Conc from Molar to uMolar
showStdErr = GetShowStdErrEnabled(handles);

[iDataBlks, iCh] = procElem.GetDataBlocksIdxs(iCh0);
fprintf('Displaying channels [%s] in data blocks [%s]\n', num2str(iCh0(:)'), num2str(iDataBlks(:)'))
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
    if datatype == hmr.buttonVals.RAW
        d = procElem.GetDataMatrix(iBlk);
        t = procElem.GetTime(iBlk);
    elseif datatype == hmr.buttonVals.OD
        d = procElem.GetDod(iBlk);
        t = procElem.GetTime(iBlk);
    elseif datatype == hmr.buttonVals.CONC
        d = procElem.GetDc(iBlk);
        t = procElem.GetTime(iBlk);
    elseif datatype == hmr.buttonVals.OD_HRF
        d = procElem.GetDodAvg([], iBlk);
        t = procElem.GetTHRF(iBlk);
        if showStdErr
            dStd = procElem.GetDodAvgStd(iBlk);
        end
        nTrials = procElem.GetNtrials(iBlk);
        if isempty(condition)
            return;
        end
    elseif datatype == hmr.buttonVals.CONC_HRF
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
        if datatype == hmr.buttonVals.RAW || datatype == hmr.buttonVals.OD || datatype == hmr.buttonVals.OD_HRF
            if  datatype == hmr.buttonVals.OD_HRF
                d = d(:,:,condition);
            end
            d = procElem.reshape_y(d, ch.MeasList);
            DisplayDataRawOrOD(t, d, dStd, iWl, iChBlk, chVis, nTrials, condition, linecolors);
        elseif datatype == hmr.buttonVals.CONC || datatype == hmr.buttonVals.CONC_HRF
            if  datatype == hmr.buttonVals.CONC_HRF
                d = d(:,:,:,condition);
            end
            d = d * sclConc;
            DisplayDataConc(t, d, dStd, hbType, iChBlk, chVis, nTrials, condition, linecolors);
        end
    end
    iColor = iColor+length(iChBlk);
end

% Set Zoom on/off
if hmr.plotViewOptions.zoom == true
    h=zoom;
    set(h,'ButtonDownFilter',@myZoom_callback);
    set(h,'enable','on')
else
    zoom off;
end

% Set data window X and Y borders
if ~isempty(hmr.plotViewOptions.ranges.Y)
    ylim(hmr.plotViewOptions.ranges.Y);
else
    ylim('auto')
end
if ~isempty(hmr.plotViewOptions.ranges.X)
    xlim(hmr.plotViewOptions.ranges.X);
else
    xlim('auto')
    if ~isempty(t)
        set(hAxes, 'xlim',[t(1), t(end)]);
    end
end

DisplayAxesSDG();
DisplayExcludedTime(handles, datatype);
DisplayStim(handles);
UpdateCondPopupmenu(handles);
UpdateDatatypePanel(handles);
UpdateChildGuis(handles);




% -------------------------------------------------------------------------
function flag = myZoom_callback(obj, event_obj)
if strcmpi( get(obj,'Tag'), 'axesData')
    flag = 0;
else
    flag = 1;
end



% ----------------------------------------------------------------------------------
function DisplayStim(handles)
global hmr
dataTree = hmr.dataTree;
procElem = dataTree.currElem;

if ~strcmp(procElem.type, 'run')
    return;
end

hAxes = hmr.axesData.handles.axes;
if ~ishandles(hAxes)
    return;
end
axes(hAxes);
hold on;

datatype = GetDatatype(handles);
if datatype == hmr.buttonVals.RAW_HRF
    return;
end
if datatype == hmr.buttonVals.OD_HRF
    return;
end
if datatype == hmr.buttonVals.CONC_HRF
    return;
end

%%% Plot stim marks. This has to be done before plotting exclude time
%%% patches because stim legend doesn't work otherwise.
t          = procElem.GetTimeCombined();
s          = procElem.GetStims(t);
stimVals   = procElem.GetStimValSettings();
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
function DisplayCondLegend(hLg, idxLg)
global hmr
dataTree = hmr.dataTree;
procElem = dataTree.currElem;

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
function Update(varargin)
global hmr

% Which application called us? 
guiname = '';
if nargin>0
    guiname = varargin{1};
end

% Redisplay main GUI based on what was done in the calling app
switch(guiname)
    case 'PlotProbeGUI'
        set(hmr.handles.checkboxPlotProbe, 'value',0); 
    case 'StimEditGUI'
        DisplayData(hmr.handles, hmr.handles.axesData);  % Redisplay data axes since stims might have edited
    case 'ProcStreamOptionsGUI'
        set(hmr.handles.pushbuttonProcStreamOptionsEdit, 'value',0);  % Redisplay enable/disable toggle button 
    case 'DataTreeClass'
        if ~isempty(hmr.handles)
            iGroup = varargin{2}(1);
            iSubj = varargin{2}(2);
            iRun = varargin{2}(3);
            fprintf('Processing iGroup=%d, iSubj=%d, iRun=%d\n', iGroup, iSubj, iRun);
            listboxGroupTree_Callback([], [iGroup, iSubj, iRun], hmr.handles);
        end
end



% --------------------------------------------------------------------
function menuItemResetGroupFolder_Callback(hObject, eventdata, handles)
resetGroupFolder();



% --------------------------------------------------------------------
function pushbuttonPanLeft_Callback(hObject, eventdata, handles)
global hmr
procElem = hmr.dataTree.currElem;
iCh0     = hmr.axesSDG.iCh;
datatype = GetDatatype(handles);

iDataBlks = procElem.GetDataBlocksIdxs(iCh0);
for iBlk = iDataBlks
    % Get plot data from dataTree
    if datatype == hmr.buttonVals.RAW
        t = procElem.GetTime(iBlk);
    elseif datatype == hmr.buttonVals.OD
        t = procElem.GetTime(iBlk);
    elseif datatype == hmr.buttonVals.CONC
        t = procElem.GetTime(iBlk);
    elseif datatype == hmr.buttonVals.OD_HRF
        t = procElem.GetTHRF(iBlk);
    elseif datatype == hmr.buttonVals.CONC_HRF
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
global hmr
set(handles.checkboxFixRangeX, 'value',0);
set(handles.checkboxFixRangeY, 'value',0);
hmr.plotViewOptions.ranges.X = [];
hmr.plotViewOptions.ranges.Y = [];
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function checkboxFixRangeX_Callback(hObject, eventdata, handles)
global hmr
if get(hObject,'value')==1
    hmr.plotViewOptions.ranges.X = str2num(get(handles.editFixRangeX, 'string'));
else
    hmr.plotViewOptions.ranges.X = [];    
end
DisplayData(handles, hObject);


% --------------------------------------------------------------------
function checkboxFixRangeY_Callback(hObject, eventdata, handles)
global hmr
if get(hObject,'value')==1
    hmr.plotViewOptions.ranges.Y = str2num(get(handles.editFixRangeY, 'string'));
else
    hmr.plotViewOptions.ranges.Y = [];
end
DisplayData(handles, hObject);



% --------------------------------------------------------------------
function editFixRangeX_Callback(hObject, eventdata, handles)
checkboxFixRangeX_Callback(handles.checkboxFixRangeX, eventdata, handles);


% --------------------------------------------------------------------
function editFixRangeY_Callback(hObject, eventdata, handles)
checkboxFixRangeY_Callback(handles.checkboxFixRangeY, eventdata, handles);



% --------------------------------------------------------------------
function menuItemGroupViewSettingAll_Callback(hObject, eventdata, handles)
global hmr

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end

views = hmr.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    set(handles.listboxGroupTree, 'string', hmr.listboxGroupTreeParams.listMaps(views.ALL).names)
    hmr.listboxGroupTreeParams.viewSetting = views.ALL;    
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
    listboxGroupTree_Callback([], [1,1,1], handles)
    hmr.dataTree.SetCurrElem(1,1,1);
    DisplayData(handles, hObject);
end


% --------------------------------------------------------------------
function menuItemGroupViewSettingSubjects_Callback(hObject, eventdata, handles)
global hmr

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end

views = hmr.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    set(handles.listboxGroupTree, 'string', hmr.listboxGroupTreeParams.listMaps(views.SUBJS).names)
    hmr.listboxGroupTreeParams.viewSetting = views.SUBJS;
    set(handles.menuItemGroupViewSettingAll,'checked','off');
    set(handles.menuItemGroupViewSettingRuns,'checked','off');
    listboxGroupTree_Callback([], [1,1,1], handles)
    hmr.dataTree.SetCurrElem(1,1,1);
    DisplayData(handles, hObject);
end


% --------------------------------------------------------------------
function menuItemGroupViewSettingRuns_Callback(hObject, eventdata, handles)
global hmr

if strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked','on');
else
    return;
end

views = hmr.listboxGroupTreeParams.views;
if strcmp(get(hObject, 'checked'), 'on')
    set(handles.listboxGroupTree, 'string', hmr.listboxGroupTreeParams.listMaps(views.RUNS).names)
    hmr.listboxGroupTreeParams.viewSetting = views.RUNS;
    set(handles.menuItemGroupViewSettingAll,'checked','off');
    set(handles.menuItemGroupViewSettingSubjects,'checked','off');
    listboxGroupTree_Callback([], [1,1,1], handles)
    hmr.dataTree.SetCurrElem(1,1,1);
    DisplayData(handles, hObject);
end

