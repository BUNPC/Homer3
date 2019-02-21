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
positionGUI(hFig, 0.20, 0.10, 0.70, 0.85)
setGuiFonts(hFig);



% ---------------------------------------------------------------------
function Homer3_EnableDisableGUI(handles, val)

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
function LoadConfig()
global hmr

hmr.config = ConfigFileClass([fileparts(which('Homer3')), '/Homer3.cfg']);




% --------------------------------------------------------------------
function Homer3_OpeningFcn(hObject, eventdata, handles, varargin)
global hmr

hmr = [];

if isempty(varargin)    
    hmr.format = 'snirf';
else
    hmr.format = varargin{1};
end

% Choose default command line output for Homer3
handles.output = hObject;
guidata(hObject, handles);

% Set the Homer3_version version number
[~, V] = Homer3_version(hObject);
hmr.version = V;

LoadConfig();


% Disable and reset all window gui objects
Homer3_EnableDisableGUI(handles,'off');
Homer3_Init(handles, {'zbuffer'});

% Load date files into group tree object
hmr.dataTree  = LoadDataTree(hmr.format, hmr.config.params.ProcStreamFile);
if hmr.dataTree.IsEmpty()
    return;
end
hmr.guiControls = InitGuiControls(handles);

% If data set has no errors enable window gui objects
Homer3_EnableDisableGUI(handles,'on');

% Display data from currently selected processing element
DisplayData();
DisplayFiles(handles);

hmr.childguis(1) = ChildGuiClass('procStreamGUI');
hmr.childguis(2) = ChildGuiClass('stimGUI');
hmr.childguis(3) = ChildGuiClass('PlotProbeGUI');
hmr.childguis(4) = ChildGuiClass('ProcStreamOptionsGUI');



% --------------------------------------------------------------------
function varargout = Homer3_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;



% --------------------------------------------------------------------
function Homer3_DeleteFcn(hObject, eventdata, handles)
global hmr;

if isempty(hmr)
    return;
end

delete(hmr.dataTree);
for ii=1:length(hmr.childguis)
    hmr.childguis(ii).Close();
end
hmr = [];
clear hmr;



% --------------------------------------------------------------------------------------------
function DisplayFiles(handles)
global hmr;

files    = hmr.dataTree.files;
filesErr = hmr.dataTree.filesErr;

% Set listbox for valid .nirs files
listboxFiles = cell(length(files),1);
nFiles=0;
for ii=1:length(files)
    if files(ii).isdir
        listboxFiles{ii} = files(ii).name;
    elseif ~isempty(files(ii).subjdir)
        listboxFiles{ii} = ['    ', files(ii).filename];
        nFiles=nFiles+1;
    else
        listboxFiles{ii} = files(ii).name;
        nFiles=nFiles+1;
    end
end

% Set listbox for invalid .nirs files
listboxFiles2 = cell(length(filesErr),1);
nFilesErr=0;
for ii=1:length(filesErr)
    if filesErr(ii).isdir
        listboxFiles2{ii} = filesErr(ii).name;
    elseif ~isempty(filesErr(ii).subjdir)
        listboxFiles2{ii} = ['    ', filesErr(ii).filename];
        nFilesErr=nFilesErr+1;
    else
        listboxFiles2{ii} = filesErr(ii).name;
        nFilesErr=nFilesErr+1;
    end
end

% Set graphics objects: text and listboxes if handles exist
if ~isempty(handles)
    % Report status in the status text object
    set( handles.textStatus, 'string', { ...
        sprintf('%d files loaded successfully',nFiles), ...
        sprintf('%d files failed to load',nFilesErr) ...
        } );
    
    if ~isempty(files)
        set(handles.listboxFiles, 'value',1)
        set(handles.listboxFiles, 'string',listboxFiles)
    end
    
    if ~isempty(filesErr)
        set(handles.listboxFilesErr, 'visible','on');
        set(handles.listboxFilesErr, 'value',1);
        set(handles.listboxFilesErr, 'string',listboxFiles2)
    else
        set(handles.listboxFilesErr, 'visible','off');
        pos1 = get(handles.listboxFiles, 'position');
        pos2 = get(handles.listboxFilesErr, 'position');
        set(handles.listboxFiles, 'position', [pos1(1) pos2(2) pos1(3) .98-pos2(2)]);
    end
end


% --------------------------------------------------------------------
function uipanelProcessingType_SelectionChangeFcn(hObject, eventdata, handles)
global hmr

dataTree  = hmr.dataTree;

procType = get(hObject,'tag');
iFile = get(handles.listboxFiles,'value');
[iGroup,iSubj,iRun] = dataTree.MapFile2Group(iFile);
switch(procType)
    case 'radiobuttonProcTypeGroup'
        dataTree.SetCurrElem(iGroup);
    case 'radiobuttonProcTypeSubj'
        dataTree.SetCurrElem(iGroup, iSubj);
    case 'radiobuttonProcTypeRun'
        dataTree.SetCurrElem(iGroup, iSubj, iRun);
end
UpdateAxesDataCondition();
DisplayData();
UpdateChildGuis();



% --------------------------------------------------------------------
function listboxFiles_Callback(hObject, eventdata, handles)
global hmr

iFile = get(hObject,'value');
if isempty(iFile==0)
    return;
end

dataTree = hmr.dataTree;

% If evendata isn't empty then caller is trying to set currElem
if strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData')
    [iGroup,iSubj,iRun] = dataTree.MapFile2Group(iFile);
    procElem = dataTree.GetCurrElem();
    switch(procElem.type)
        case 'group'
            dataTree.SetCurrElem(iGroup);
        case 'subj'
            dataTree.SetCurrElem(iGroup, iSubj);
        case 'run'
            dataTree.SetCurrElem(iGroup, iSubj, iRun);
    end
elseif ~isempty(eventdata)
    iSubj = eventdata(1);
    iRun = eventdata(2);
    iFile = dataTree.MapGroup2File(iGroup, iSubj, iRun);
    if iFile==0
        return;
    end
    set(hObject,'value', iFile);
end

UpdateAxesDataCondition();
DisplayData();
UpdateChildGuis();


% --------------------------------------------------------------------
function pushbuttonCalcProcStream_Callback(hObject, eventdata, handles)
global hmr
dataTree = hmr.dataTree;

dataTree.CalcCurrElem();
dataTree.SaveCurrElem();
DisplayData();
UpdateChildGuis();



% --------------------------------------------------------------------
function listboxFilesErr_Callback(hObject, eventdata, handles)

% TBD: We may want to try fix files with errors



% --------------------------------------------------------------------
function uipanelPlot_SelectionChangeFcn(hObject, eventdata, handles)
global hmr

GetAxesDataType()
DisplayData();
UpdateChildGuis();

datatype   = hmr.guiControls.datatype;
buttonVals = hmr.guiControls.buttonVals;
if datatype == buttonVals.RAW || datatype == buttonVals.RAW_HRF
    set(hmr.guiControls.handles.listboxPlotWavelength, 'visible','on');
    set(hmr.guiControls.handles.listboxPlotConc, 'visible','off');
elseif datatype == buttonVals.OD || datatype == buttonVals.OD_HRF
    set(hmr.guiControls.handles.listboxPlotWavelength, 'visible','on');
    set(hmr.guiControls.handles.listboxPlotConc, 'visible','off');
elseif datatype == buttonVals.CONC || datatype == buttonVals.CONC_HRF
    set(hmr.guiControls.handles.listboxPlotWavelength, 'visible','off');
    set(hmr.guiControls.handles.listboxPlotConc, 'visible','on');
end



% --------------------------------------------------------------------
function checkboxPlotHRF_Callback(hObject, eventdata, handles)

GetAxesDataType();
DisplayData();
UpdateChildGuis();



% --------------------------------------------------------------------
function guiControls_ButtonDownFcn(hObject, eventdata, handles)

% Make sure the user clicked on the axes and not
% some other object on top of the axes
if ~strcmp(get(hObject,'type'),'axes')
    return;
end


% --------------------------------------------------------------------
function axesSDG_ButtonDownFcn(hObject, eventdata, handles)
global hmr

dataTree = hmr.dataTree;
if dataTree.IsEmpty()
    return;
end

% Transfer the channels selection to guiControls
SetAxesDataCh();

% Update the displays of the guiControls and axesSDG axes
DisplayData();



% --------------------------------------------------------------------
function popupmenuConditions_Callback(hObject, eventdata, handles)

GetAxesDataCondition();
DisplayData();
UpdateChildGuis();



% --------------------------------------------------------------------
function listboxPlotWavelength_Callback(hObject, eventdata, handles)

GetAxesDataWl();
DisplayData();



% --------------------------------------------------------------------
function listboxPlotConc_Callback(hObject, eventdata, handles)

GetAxesDataHbType();
DisplayData();




% --------------------------------------------------------------------
function menuChangeDirectory_Callback(hObject, eventdata, handles)
global hmr

fmt = hmr.format;

% Change directory
pathnm = uigetdir( cd, 'Pick the new directory' );
if pathnm==0
    return;
end
cd(pathnm);

hGui=get(get(hObject,'parent'),'parent');
Homer3_DeleteFcn(hGui,[],handles);

% restart
Homer3(fmt);



% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)

hGui=get(get(hObject,'parent'),'parent');
Homer3_DeleteFcn(hGui,eventdata,handles);



% --------------------------------------------------------------------
function menuItemReset_Callback(hObject, eventdata, handles)
global hmr

dataTree = hmr.dataTree;
dataTree.currElem.Reset();
dataTree.currElem.Save();
DisplayData();


% --------------------------------------------------------------------
function menuCopyCurrentPlot_Callback(hObject, eventdata, handles)
global hmr

currElem = hmr.dataTree.currElem;
hf = figure;
set(hf, 'color', [1 1 1]);
fields = fieldnames(guiControls.buttonVals);
plotname = sprintf('%s_%s', currElem.name, fields{guiControls.datatype});
set(hf,'name', plotname);


% DISPLAY DATA
guiControls.axesData.handles.axes = axes('position',[0.05 0.05 0.6 0.9]);

% DISPLAY SDG
guiControls.axesSDG.handles.axes = axes('position',[0.65 0.05 0.3 0.9]);
axis off

% TBD: Display current element without help from dataTree



% --------------------------------------------------------------------
function pushbuttonProcStreamOptionsEdit_Callback(hObject, eventdata, handles)
global hmr

idx = FindChildGuiIdx('ProcStreamOptionsGUI');
if get(hObject, 'value')
    hmr.childguis(idx).Launch(hmr.guiControls.applyEditCurrNodeOnly);
else
    hmr.childguis(idx).Close();
end



% -------------------------------------------------------------------
function menuItemLaunchStimGUI_Callback(hObject, eventdata, handles)
global hmr

idx = FindChildGuiIdx('stimGUI');
hmr.childguis(idx).Launch();



% --------------------------------------------------------------------
function pushbuttonSave_Callback(hObject, eventdata, handles)
global hmr

hmr.dataTree.currElem.Save();



% --------------------------------------------------------------------
function menuItemViewHRFStdErr_Callback(hObject, eventdata, handles)
global hmr

if strcmp(get(hObject, 'checked'), 'on')
    set(hObject, 'checked', 'off')
elseif strcmp(get(hObject, 'checked'), 'off')
    set(hObject, 'checked', 'on')
end
if strcmp(get(hObject, 'checked'), 'on')
    hmr.guiControls.showStdErr = true;
elseif strcmp(get(hObject, 'checked'), 'off')
    hmr.guiControls.showStdErr = false;
end
DisplayData();



% ---------------------------------------------------------------------------
function checkboxPlotProbe_Callback(hObject, eventdata, handles)
global hmr

idx = FindChildGuiIdx('PlotProbeGUI');
if get(hObject, 'value')
    hmr.childguis(idx).Launch(hmr.guiControls.datatype, hmr.guiControls.condition);
else
    hmr.childguis(idx).Close();
end



% --------------------------------------------------------------------
function menuItemProcStreamEdit_Callback(hObject, eventdata, handles)
global hmr

checked = get(hObject,'checked');
idx = FindChildGuiIdx('procStreamGUI');
if checked
    hmr.childguis(idx).Launch();
else
    hmr.childguis(idx).Close();
end


% --------------------------------------------------------------------
function checkboxApplyProcStreamEditToAll_Callback(hObject, eventdata, handles)
global hmr

if get(hObject, 'value')
    hmr.guiControls.applyEditCurrNodeOnly = false;
else
    hmr.guiControls.applyEditCurrNodeOnly = true;
end
UpdateArgsChildGuis();



% --------------------------------------------------------------------
function idx = FindChildGuiIdx(name)
global hmr
idx = [];
for ii=1:length(hmr.childguis)
    if strcmp(hmr.childguis(ii).GetName, name)
        break;
    end
end
idx = ii;


% --------------------------------------------------------------------
function UpdateArgsChildGuis()
global hmr

hmr.childguis(FindChildGuiIdx('PlotProbeGUI')).UpdateArgs(hmr.guiControls.datatype, hmr.guiControls.condition);
hmr.childguis(FindChildGuiIdx('ProcStreamOptionsGUI')).UpdateArgs(hmr.guiControls.applyEditCurrNodeOnly);


% --------------------------------------------------------------------
function UpdateChildGuis()
global hmr

UpdateArgsChildGuis()
for ii=1:length(hmr.childguis)
    hmr.childguis(ii).Update();
end



% ----------------------------------------------------------------------------------
function DisplayData()
global hmr
dataTree = hmr.dataTree;
guiControls = hmr.guiControls;
procElem = dataTree.currElem;

hAxes = guiControls.axesData.handles.axes;
if ~ishandles(hAxes)
    return;
end

axes(hAxes)
cla;
legend off
set(hAxes,'ygrid','on');

linecolor  = guiControls.axesData.linecolor;
linestyle  = guiControls.axesData.linestyle;
datatype   = guiControls.datatype;
condition  = guiControls.condition;
iCh        = guiControls.ch;
iWl        = guiControls.wl;
hbType     = guiControls.hbType;
buttonVals = guiControls.buttonVals;
sclConc    = guiControls.sclConc;        % convert Conc from Molar to uMolar
showStdErr = guiControls.showStdErr;

condition = find(procElem.CondName2Group == condition);

d       = [];
dStd    = [];
t       = [];
nTrials = [];

if datatype == buttonVals.RAW
    d = procElem.GetDataMatrix();
    t = procElem.GetTime();
elseif datatype == buttonVals.OD
    d = procElem.procStream.output.dod;
    t = procElem.GetTime();
elseif datatype == buttonVals.CONC
    d = procElem.procStream.output.dc;
    t = procElem.GetTime();
elseif datatype == buttonVals.OD_HRF
    d = procElem.procStream.output.dodAvg;
    t = procElem.procStream.output.tHRF;
    if showStdErr
        dStd = procElem.procStream.output.dodAvgStd;
    end
    nTrials = procElem.procStream.output.nTrials;
    if isempty(condition)
        return;
    end
elseif datatype == buttonVals.CONC_HRF
    d = procElem.procStream.output.dcAvg;
    t = procElem.procStream.output.tHRF;
    if showStdErr
        dStd = procElem.procStream.output.dcAvgStd * sclConc;
    end
    nTrials = procElem.procStream.output.nTrials;
    if isempty(condition)
        return;
    end
end
ch      = procElem.GetMeasList();

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
        set(hAxes,'xlim',[floor(min(t)) ceil(max(t))]);
        set(hAxes,'ylimmode','auto');
    else
        xlim(xx);
        ylim(yy);
    end
    chLst = find(ch.MeasListVis(iCh)==1);
    
    % Plot data
    if datatype == buttonVals.RAW || datatype == buttonVals.OD
        if  datatype == buttonVals.OD_HRF
            d = d(:,:,condition);
        end
        d = procElem.reshape_y(d, ch.MeasList);
        DisplayDataRawOrOD(t, d, dStd, iWl, iCh, chLst, nTrials, condition, linecolor, linestyle);
    elseif datatype == buttonVals.CONC || datatype == buttonVals.CONC_HRF
        if  datatype == buttonVals.CONC_HRF
            d = d(:,:,:,condition);
        end
        d = d * sclConc;
        DisplayDataConc(t, d, dStd, hbType, iCh, chLst, nTrials, condition, linecolor, linestyle);
    end
end
DisplayAxesSDG();
DisplayStim();



% ----------------------------------------------------------------------------------
function DisplayStim()
global hmr
dataTree = hmr.dataTree;
guiControls = hmr.guiControls;
procElem = dataTree.currElem;

if ~strcmp(procElem.type, 'run')
    return;
end

hAxes = guiControls.axesData.handles.axes;
if ~ishandles(hAxes)
    return;
end
axes(hAxes);
hold on;

buttonVals = guiControls.buttonVals;

if guiControls.datatype == buttonVals.RAW_HRF
    return;
end
if guiControls.datatype == buttonVals.OD_HRF
    return;
end
if guiControls.datatype == buttonVals.CONC_HRF
    return;
end

procResult = procElem.procStream.output;

%%% Plot stim marks. This has to be done before plotting exclude time
%%% patches because stim legend doesn't work otherwise.
if ~isempty(procElem.GetStims())
    t = procElem.acquired.GetTime();
    s = procElem.acquired.GetStims();
    
    % Plot included and excluded stims
    yrange = GetAxesYRangeForStimPlot(hAxes);
    hLg=[];
    idxLg=[];
    kk=1;
    CondColTbl = procElem.CondColTbl;
    for iS = 1:size(s,2)
        iCond = procElem.CondName2Group(iS);
        
        lstS          = find(s(:,iS)==1 | s(:,iS)==-1);
        lstExclS_Auto = [];
        lstExclS_Man  = find(s(:,iS)==-1);
        if isproperty(procResult,'s') && ~isempty(procResult.s)
            lstExclS_Auto = find(s(:,iS)==1 & sum(procResult.s,2)<=-1);
        end
        
        for iS2=1:length(lstS)
            if ~isempty(find(lstS(iS2) == lstExclS_Auto))
                hl = plot(t(lstS(iS2))*[1 1],yrange,'-.');
                set(hl,'linewidth',1);
                set(hl,'color',CondColTbl(iCond,:));
            elseif ~isempty(find(lstS(iS2) == lstExclS_Man))
                hl = plot(t(lstS(iS2))*[1 1],yrange,'--');
                set(hl,'linewidth',1);
                set(hl,'color',CondColTbl(iCond,:));
            else
                hl = plot(t(lstS(iS2))*[1 1],yrange,'-');
                set(hl,'linewidth',1);
                set(hl,'color',CondColTbl(iCond,:));
            end
        end
        
        % Get handles and indices of each stim condition
        % for legend display
        if ~isempty(lstS)
            % We don't want dashed lines appearing in legend, so
            % we draw invisible solid stims over all stims to
            % trick the legend into only showing solid lines.
            hLg(kk) = plot(t(lstS(iS2))*[1 1],yrange,'-', 'linewidth',4, 'visible','off');
            set(hLg(kk),'color',CondColTbl(iCond,:));
            idxLg(kk) = iCond;
            kk=kk+1;
        end
    end
    DisplayCondLegend(hLg, idxLg);
end
hold off
set(hAxes,'ygrid','on');
                
                
                
% ----------------------------------------------------------------------------------
function DisplayCondLegend(hLg, idxLg)
global hmr
dataTree = hmr.dataTree;
procElem = dataTree.currElem;

[idxLg, k] = sort(idxLg);
CondNamesAll = procElem.CondNamesAll;
if ishandles(hLg)
    legend(hLg(k), CondNamesAll(idxLg));
end
