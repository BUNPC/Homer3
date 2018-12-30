function varargout = PlotProbeGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotProbeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotProbeGUI_OutputFcn, ...
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


% ----------------------------------------------------------------------
function PlotProbeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for PlotProbeGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);



% ----------------------------------------------------------------------
function varargout = PlotProbeGUI_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



% ----------------------------------------------------------------------
function editPlotProbeAxScl_Callback(hObject, eventdata, handles)
global hmr

plotprobe = hmr.plotprobe;

foo = str2num( get(hObject,'string') );
if length(foo)<2
    foo = plotprobe.axScl;
elseif foo(1)<=0 | foo(2)<=0
    foo = plotprobe.axScl;
end    
plotprobe.axScl = foo;
set(hObject,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );
plotProbeAndSetProperties(plotprobe);



% ----------------------------------------------------------------------
function pushbuttonPlotProbeYdec_Callback(hObject, eventdata, handles)
global hmr 
plotprobe = hmr.plotprobe;

hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(2) = plotprobe.axScl(2) - 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f',plotprobe.axScl) );
plotProbeAndSetProperties(plotprobe);


% ----------------------------------------------------------------------
function pushbuttonPlotProbeYinc_Callback(hObject, eventdata, handles)
global hmr 
plotprobe = hmr.plotprobe;

hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(2) = plotprobe.axScl(2) + 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f',plotprobe.axScl) );
plotProbeAndSetProperties(plotprobe);



% ----------------------------------------------------------------------
function pushbuttonPlotProbeXdec_Callback(hObject, eventdata, handles)
global hmr 
plotprobe = hmr.plotprobe;

hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(1) = plotprobe.axScl(1) - 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f',plotprobe.axScl) );
plotProbeAndSetProperties(plotprobe);


% ----------------------------------------------------------------------
function pushbuttonPlotProbeXinc_Callback(hObject, eventdata, handles)
global hmr 
plotprobe = hmr.plotprobe;

hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(1) = plotprobe.axScl(1) + 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f',plotprobe.axScl) );
plotProbeAndSetProperties(plotprobe);



% ----------------------------------------------------------------------
function radiobuttonShowTimeMarkers_Callback(hObject, evendata, handles)
global hmr

currElem = hmr.dataTree.currElem;
guiMain = hmr.guiMain;
plotprobe = hmr.plotprobe;

bit0 = get(hObject,'value');
plotprobe.tMarkShow = bit0;
bit1 = plotprobe.hidMeasShow;
h = plotprobe.handles.Data;

procResult  = currElem.procElem.procResult;
ch          = currElem.procElem.GetMeasList();

datatype    = guiMain.datatype;
buttonVals  = guiMain.buttonVals;


if currElem.procType==1
    condition  = guiMain.condition;
elseif currElem.procType==2
    condition = find(currElem.procElem.CondName2Group == guiMain.condition);
elseif currElem.procType==3
    condition  = find(currElem.procElem.CondName2Group == guiMain.condition);
end

if datatype == buttonVals.OD_HRF
    y = procResult.dodAvg(:, :, condition);
elseif datatype == buttonVals.CONC_HRF
    y = procResult.dcAvg(:, :, :, condition);
else
    return;
end

guiSettings = 2*bit1 + bit0;
showHiddenObjs(guiSettings,ch,y,h);


% ----------------------------------------------------------------------
function editPlotProbeTimeMarkersAmp_Callback(hObject, eventdata, handles)
global hmr
plotprobe = hmr.plotprobe;
guiMain   = hmr.guiMain;

datatype    = guiMain.datatype;
buttonVals  = guiMain.buttonVals;

plotprobe.tMarkAmp = str2num(get(hObject,'string'));
if datatype == buttonVals.CONC_HRF
    plotprobe.tMarkAmp = plotprobe.tMarkAmp/1e6;
end

plotProbeAndSetProperties(plotprobe);


% ----------------------------------------------------------------------
function editPlotProbeTimeMarkersInt_Callback(hObject, eventdata, handles)
global hmr
plotprobe = hmr.plotprobe;

tHRF     = plotprobe.tHRF;

foo = str2num( get(hObject,'string') );
if length(foo)~=1
    foo = plotprobe.tMarkInt;
elseif ~isnumeric(foo)
    foo = plotprobe.tMarkInt;
elseif foo<5 || foo>tHRF(end)
    foo = plotprobe.tMarkInt;
end

plotprobe.tMarkInt = foo;
set(hObject,'string', sprintf('%0.1f ',plotprobe.tMarkInt) );
plotProbeAndSetProperties(plotprobe);



% ----------------------------------------------------------------------
function pushbuttonPlotProbeDuplicate_Callback(hObject, eventdata, handles)
global hmr
plotprobe = hmr.plotprobe;

%%%% Get the zoom level of the original plotProbe axes
figure(plotprobe.handles.Figure);
a = get(gca,'xlim');
b = get(gca,'ylim');

%%%% Create new figure and use same zoom level and axes position 
%%%% as original 
plotprobe.handles.FigureDup = figure();
xlim(a);
ylim(b);
pos = getNewFigPos(plotprobe.handles.FigureDup);
set(plotprobe.handles.FigureDup,'position',pos);
y        = plotprobe.y;
tHRF     = plotprobe.tHRF;
SD       = plotprobe.SD;
ch       = plotprobe.ch;
tMarkInt = plotprobe.tMarkInt;
axScl    = plotprobe.axScl;
bit0     = plotprobe.tMarkShow;
bit1     = plotprobe.hidMeasShow;
tMarkAmp = plotprobe.tMarkAmp;

hData = plotProbe( y, tHRF, SD, ch, [], axScl, tMarkInt, tMarkAmp );
showHiddenObjs( 2*bit1+bit0, ch, y, hData );

%{
if plotprobe.tMarkAmp;

    uicontrol('parent',hFig2,'style','text',...
              'units','normalized','position',[.05 .01 .2 .1],...
              'string',sprintf('Amplitude: %0.5g',tMarkAmp),...
              'backgroundcolor',[1 1 1]);
end  
%}      
      
      
% ---------------------------------------------
function pos = getNewFigPos(hFig)

p = get(hFig,'position');

% Find upper right corner of figure
pu = [p(1)+p(3), p(2)+p(4)];

% find center position of figure
c = [p(1)+(pu(1)-p(1))/2, p(2)+(pu(2)-p(2))/2];

% determine which direction to move new figure relative 
% to hFig based on which quadrant of the screen the center
% of hFig appears.
scrsz = get(0,'screensize');
if c(1)>scrsz(3)/2
    q=-1;
else
    q=+1;
end
if c(2)>scrsz(4)/2
    r=-1;
else
    r=+1;
end
offsetX = q*scrsz(3)*.1;
offsetY = r*scrsz(4)*.1;

pos = [p(1)+offsetX p(2)+offsetY p(3) p(4)];



% ----------------------------------------------------------------------
function radiobuttonShowHiddenMeas_Callback(hObject, handles)
global hmr
plotprobe = hmr.plotprobe;currElem = hmr.dataTree.currElem;
guiMain = hmr.guiMain;

bit1 = get(hObject,'value');
plotprobe.hidMeasShow = bit1;
bit0 = plotprobe.tMarkShow;

h = plotprobe.handles.Data;

procResult  = currElem.procElem.procResult;
ch          = currElem.procElem.GetMeasList();

datatype    = guiMain.datatype;
buttonVals  = guiMain.buttonVals;

if currElem.procType==1
    condition  = guiMain.condition;
elseif currElem.procType==2
    condition = find(currElem.procElem.CondName2Group == guiMain.condition);
elseif currElem.procType==3
    condition  = find(currElem.procElem.CondName2Group == guiMain.condition);
end

if datatype == buttonVals.OD_HRF
    y = procResult.dodAvg(:, :, condition);
elseif datatype == buttonVals.CONC_HRF
    y = procResult.dcAvg(:, :, :, condition);
end

guiSettings = 2*bit1 + bit0;
showHiddenObjs(guiSettings,ch,y,h);


% ----------------------------------------------------------------------
function PlotProbeGUI_DeleteFcn(hObject, eventdata, handles)
global hmr
plotprobe = hmr.plotprobe;

plotprobe.CloseGUI();
