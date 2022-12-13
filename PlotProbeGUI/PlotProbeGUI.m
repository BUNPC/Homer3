function varargout = PlotProbeGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PlotProbeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PlotProbeGUI_OutputFcn, ...
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
function varargout = PlotProbeGUI_OutputFcn(~, ~, handles)
handles.updateptr = @PlotProbeGUI_Update;
handles.closeptr = @PlotProbeGUI_Close;
varargout{1} = handles;



% ----------------------------------------------------------------------
function Initialize(handles)
global plotprobe

plotprobe = [];

plotprobe.status = -1;

% These are the parameters that are assigned from external sources,
% either from GUI arguments or parent GUI. 
plotprobe.groupDirs = {};
plotprobe.format = '';
plotprobe.datatype = [];
plotprobe.condition = [];
plotprobe.pos = [];

% Rest of the parameters 
plotprobe.datatype = [];
plotprobe.datatypeVals = [];
plotprobe.name = 'plotprobe';
plotprobe.y = {};
plotprobe.yStd = {};
plotprobe.t = {};
plotprobe.ml = {};
plotprobe.SD = [];

SetGuiControls(handles)

setGuiFonts(handles.figure);


% ----------------------------------------------------------------------
function SetGuiControls(handles)
global plotprobe

plotprobe.axScl       = str2num(get(handles.editPlotProbeAxScl, 'string'));
plotprobe.tMarkInt    = str2num(get(handles.editPlotProbeTimeMarkersInt, 'string'));
plotprobe.tMarkAmp    = str2num(get(handles.editPlotProbeTimeMarkersAmp, 'string'));
plotprobe.tMarkShow   = get(handles.radiobuttonShowTimeMarkers, 'value');
plotprobe.tMarkUnits  = str2num(get(handles.textTimeMarkersAmpUnits, 'string'));



% ----------------------------------------------------------------------
function InheritParentGuiParams()
global plotprobe
global maingui

% Now whichever of the above parameters weren't assigned values
% obtain values either from parent gui or assign default value
if isempty(maingui)
    if isempty(plotprobe.groupDirs)
        plotprobe.groupDirs = filesepStandard({pwd});
    end
    if isempty(plotprobe.format)
        plotprobe.format = 'snirf';
    end
    if isempty(plotprobe.condition)
        plotprobe.condition = 1;
    end
    if isempty(plotprobe.datatypeVals)
        plotprobe.datatypeVals = struct('RAW',1, 'RAW_HRF',2, 'OD',4, 'OD_HRF',8, 'CONC',16, 'CONC_HRF',32);
    end
    if isempty(plotprobe.datatype)
        plotprobe.datatype = plotprobe.datatypeVals.CONC_HRF;
    end
else
    if isempty(plotprobe.groupDirs)
        plotprobe.groupDirs = maingui.groupDirs;
    end
    if isempty(plotprobe.format)
        plotprobe.format = maingui.format;
    end
    plotprobe.condition = maingui.condition;
    plotprobe.datatypeVals = maingui.buttonVals;
    plotprobe.datatype = maingui.datatype;
end




% ----------------------------------------------------------------------
function ParseArgs(args)
global plotprobe

if ~exist('args','var')
    return;
end

varargin = args;

%%%% These are the parameters that are assigned from external soutrces,
%%%% either from GUI arguments or parent GUI. 
%
% plotprobe.groupDirs
% plotprobe.format
% plotprobe.datatype
% plotprobe.condition
% plotprobe.pos
%

%  Syntax:
%
%     PlotProbeGUI()
%     PlotProbeGUI(groupDirs)
%     PlotProbeGUI(groupDirs, format)
%     PlotProbeGUI(groupDirs, format, pos)
%     PlotProbeGUI(groupDirs, format, datatype)
%     PlotProbeGUI(groupDirs, format, datatype, pos)
%     PlotProbeGUI(groupDirs, format, datatype, condition)
%     PlotProbeGUI(groupDirs, format, datatype, condition, pos)
%     PlotProbeGUI(datatype)
%     PlotProbeGUI(datatype, pos)
%     PlotProbeGUI(datatype, condition)
%     PlotProbeGUI(datatype, condition, pos)

% Arguments take precedence over parent gui parameters
if length(varargin)==1
    if iswholenum(varargin{1}) && length(varargin{1})==1
        plotprobe.datatype = varargin{1};                   % PlotProbeGUI(datatype)
    else
        plotprobe.groupDirs = varargin{1};                  % PlotProbeGUI(groupDirs)
    end
elseif length(varargin)==2
    if iswholenum(varargin{1}) && length(varargin{1})==1
        plotprobe.datatype = varargin{1};                   % PlotProbeGUI(datatype)
        if isreal(varargin{2}) && length(varargin{2})==4     
            plotprobe.pos = varargin{2};                        % PlotProbeGUI(datatype, pos)
        elseif iswholenum(varargin{2})
            plotprobe.condition = varargin{2};                  % PlotProbeGUI(datatype, condition)
        end
    else
        plotprobe.groupDirs = varargin{1};                  % PlotProbeGUI(groupDirs)
        plotprobe.format = varargin{2};
    end    
elseif length(varargin)==3
    if iswholenum(varargin{1}) && length(varargin{1})==1
        plotprobe.datatype = varargin{1};
        plotprobe.condition = varargin{2};
        plotprobe.pos = varargin{3};                        % PlotProbeGUI(datatype, condition, pos)
    elseif ischar(varargin{2})
        plotprobe.groupDirs = varargin{1};
        plotprobe.format = varargin{2};
        if isreal(varargin{3}) && length(varargin{3})==4     
            plotprobe.pos = varargin{3};                    % PlotProbeGUI(groupDirs, format, pos)
        elseif iswholenum(varargin{3}) && length(varargin{3})==1
            plotprobe.datatype = varargin{3};               % PlotProbeGUI(groupDirs, format, datatype)
        end
    end
elseif length(varargin)==4
    plotprobe.groupDirs = varargin{1};
    plotprobe.format    = varargin{2};
    plotprobe.datatype  = varargin{3};
    if isreal(varargin{4}) && length(varargin{2})==4     
        plotprobe.pos = varargin{4};                        % PlotProbeGUI(groupDirs, format, datatype, pos)
    elseif iswholenum(varargin{4})
        plotprobe.condition = varargin{4};                  % PlotProbeGUI(groupDirs, format, datatype, condition)
    end
elseif length(varargin)==5
    plotprobe.groupDirs = varargin{1};
    plotprobe.format    = varargin{2};
    plotprobe.datatype  = varargin{3};
    plotprobe.condition = varargin{4};
    plotprobe.pos       = varargin{5};                      % PlotProbeGUI(groupDirs, format, datatype, condition, pos)
end

InheritParentGuiParams()



% ----------------------------------------------------------------------
function PlotProbeGUI_OpeningFcn(hObject, ~, handles, varargin)
%
%  Syntax:
%
%     PlotProbeGUI()
%     PlotProbeGUI(groupDirs)
%     PlotProbeGUI(groupDirs, format)
%     PlotProbeGUI(groupDirs, format, pos)
%     PlotProbeGUI(groupDirs, format, datatype, pos)
%     PlotProbeGUI(groupDirs, format, datatype, condition)
%     PlotProbeGUI(groupDirs, format, datatype, condition, pos)
%     PlotProbeGUI(groupDirs, datatype, pos)
%     PlotProbeGUI(groupDirs, datatype, condition)
%     PlotProbeGUI(groupDirs, datatype, condition, pos)
%  
%  Description:
%     GUI for displaying HRF plots for all probe channels. 
%     
%     NOTE: This GUIs input parameters are passed to it either as formal arguments 
%     or through the calling parent GUIs generic global variable, 'maingui'. If it's 
%     the latter, this GUI follows the rule that it accesses the parent GUIs global 
% 	  variable ONLY at startup time, that is, in the function <GUI Name>_OpeningFcn(). 
%
%  Input:
%     format:    Which acquisition type of files to load to dataTree: e.g., nirs, snirf, etc
%     pos:       Size and position of last figure session
%     datatype:  Takes 2 integer values {8 = OD HRF, 32 = concentration HRF}. Any other values will be ignored and nothing will be pl 
%     condition: Integer index telling which condition 
%

global plotprobe
global maingui

% Choose default command line output for PlotProbeGUI
handles.output = hObject;
guidata(hObject, handles);

Initialize(handles);
plotprobe.updateParentGui = [];

% These local data trees are used for turning synchronized browsing with MainGUI on/off
plotprobe.locDataTree = [];
plotprobe.locDataTree2 = [];

% Parse GUI args
ParseArgs(varargin);

% See if we can recover previous position
p = plotprobe.pos;
if ~isempty(p)
    set(hObject, 'position', [p(1), p(2), p(3), p(4)]);
end
plotprobe.version  = get(hObject, 'name');
plotprobe.dataTree = LoadDataTree(plotprobe.groupDirs, plotprobe.format, '', maingui);
if plotprobe.dataTree.IsEmpty()
    return;
end
InitCurrElem(plotprobe);

if length(plotprobe.y)>1
    msg{1} = sprintf('Warning: Data in this plot probe uses different Y scales for different data blocks ');
    msg{2} = sprintf('for which a single scale has not yet been implemented. A single scale for mutiple data blocks ');
    msg{3} = sprintf('will be implemented in a future release. Note that single block data sets are ');
    msg{4} = sprintf('unaffected by this issue; i.e., all data from all channels are plotted using the same scale.');
    MessageBox([msg{:}], 'Feature Not Yet Fully Implemented');
    return;
end
 
% If parent gui exists disable these menu options which only make sense when 
% running this GUI standalone
if ~isempty(maingui)
    plotprobe.updateParentGui = maingui.Update;

    % If parent gui exists disable these menu options which only make sense when
    % running this GUI standalone
    set(handles.menuItemChangeGroup, 'enable','off');
    set(handles.menuItemSaveGroup, 'enable','off');
    set(handles.menuItemSyncBrowsing, 'enable','on');
else
    set(handles.menuItemChangeGroup, 'enable','on');
    set(handles.menuItemSaveGroup, 'enable','on');
    set(handles.menuItemSyncBrowsing, 'enable','off');
end
plotprobe.dataTypeWarning = struct('datatype','', 'selection',[0,false], 'menuboxoption','askEveryTime');

setappdata(hObject, 'figures',hObject);
setappdata(hObject, 'data',{});

SetTextFilename(handles);
DisplayData(handles, hObject);

if ~menuItemSyncBrowsing_Callback(handles.menuItemSyncBrowsing, 'get')
    menuItemSyncBrowsing_Callback(handles.menuItemSyncBrowsing, '');
end





% ----------------------------------------------------------------------
function SetWindowTitle(handles)
global plotprobe

windowtitlenew = sprintf('PlotProbeGUI:   %s', plotprobe.dataTreeHandle.currElem.GetName());
set(handles.figure, 'name', windowtitlenew)



% ----------------------------------------------------------------------
function DisplayData(handles, hObject)
global plotprobe

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

axes(handles.axes1);
set(handles.axes1, 'xlim', [0,1], 'ylim', [0,1]);

% Clear axes
cla(handles.axes1); 
axis off;

currElem  = plotprobe.dataTreeHandle.currElem;

% Load current element data from file
if currElem.IsEmpty()
    currElem.Load();
end

SetWindowTitle(handles)

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);



% ----------------------------------------------------------------------
function editPlotProbeAxScl_Callback(hObject, ~, handles)
global plotprobe

foo = str2num( get(hObject,'string') );
if length(foo)<2
    foo = plotprobe.axScl;
elseif foo(1)<=0 || foo(2)<=0
    foo = plotprobe.axScl;
end    
plotprobe.axScl = foo;

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);

set(hObject,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );
plotProbeAndSetProperties(handles);



% ----------------------------------------------------------------------
function pushbuttonPlotProbeYdec_Callback(~, ~, handles)
global plotprobe 

hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(2) = plotprobe.axScl(2) - 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);




% ----------------------------------------------------------------------
function pushbuttonPlotProbeYinc_Callback(~, ~, handles)
global plotprobe 

hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(2) = plotprobe.axScl(2) + 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);



% ----------------------------------------------------------------------
function pushbuttonPlotProbeXdec_Callback(~, ~, handles)
global plotprobe 
hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(1) = plotprobe.axScl(1) - 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);



% ----------------------------------------------------------------------
function pushbuttonPlotProbeXinc_Callback(~, ~, handles)
global plotprobe 

hEditScl = handles.editPlotProbeAxScl;

plotprobe.axScl(1) = plotprobe.axScl(1) + 0.1;
set(hEditScl,'string', sprintf('%0.1f %0.1f', plotprobe.axScl) );

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);




% ----------------------------------------------------------------------
function radiobuttonShowTimeMarkers_Callback(hObject, ~, handles)
global plotprobe
data = getappdata(handles.figure, 'data');
plotprobe.tMarkShow = get(hObject,'value');
nDataBlks = plotprobe.dataTreeHandle.currElem.GetDataBlocksNum();
for iBlk = 1:nDataBlks
    for iSD = 1:size(data{iBlk},1)
        k = find(data{iBlk}(iSD,4:end)>0);
        if ~isempty(data{iBlk})
            if plotprobe.tMarkShow
                set(data{iBlk}(iSD,4+k-1), 'visible', 'on');
            else
                set(data{iBlk}(iSD,4+k-1), 'visible', 'off');
            end
        end
    end
end



% ----------------------------------------------------------------------
function editPlotProbeTimeMarkersAmp_Callback(hObject, ~, handles)
global plotprobe

plotprobe.tMarkAmp = str2num(get(hObject,'string'));
if plotprobe.datatype == plotprobe.datatypeVals.CONC_HRF
    plotprobe.tMarkAmp = plotprobe.tMarkAmp/1e6;
end

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);



% ----------------------------------------------------------------------
function editPlotProbeTimeMarkersInt_Callback(hObject, ~, handles)
global plotprobe

t  = plotprobe.dataTreeHandle.currElem.GetTHRF();

foo = str2num( get(hObject,'string') );
if length(foo)~=1
    foo = plotprobe.tMarkInt;
elseif ~isnumeric(foo)
    foo = plotprobe.tMarkInt;
elseif foo<2 || foo>t(end)
    foo = plotprobe.tMarkInt;
end
plotprobe.tMarkInt = foo;
set(hObject,'string', sprintf('%0.1f ',plotprobe.tMarkInt) );

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);



% ----------------------------------------------------------------------
function pushbuttonPlotProbeExport_Callback(~, ~, handles) %#ok<*DEFNU>
global plotprobe

figures = getappdata(handles.figure, 'figures');

%%%% Get the zoom level of the original plotProbe axes
figure(handles.figure);
a = get(gca,'xlim');
b = get(gca,'ylim');
set(gca, 'tag','axes1');

iNew = length(figures)+1;

%%%% Create new figure and use same zoom level and axes position 
%%%% as original 
figures(iNew) = figure('name', plotprobe.dataTreeHandle.currElem.GetName(), 'NumberTitle','off');
setappdata(handles.figure, 'figures',figures);
xlim(a);
ylim(b);
axis off
pos = getNewFigPos(handles);
if ~isempty(pos)
    set(figures(iNew), 'position',pos);
end

% Display name label and divider
hname = get(handles.textFilename);
hnameFrame = get(handles.textFilenameFrame);
hdiv = get(handles.uipanelDivider);
uicontrol('parent',figures(iNew), 'style','text', 'string',hnameFrame.String, 'units',hnameFrame.Units, 'position',hnameFrame.Position, ...
           'backgroundcolor',hnameFrame.BackgroundColor, 'fontsize',hnameFrame.FontSize, 'fontweight',hnameFrame.FontWeight);
uicontrol('parent',figures(iNew), 'style','text', 'string',hname.String, 'units',hname.Units, 'position',hname.Position, ...
           'backgroundcolor',hname.BackgroundColor, 'fontsize',hname.FontSize, 'fontweight',hname.FontWeight);
uipanel('parent',figures(iNew), 'units',hdiv.Units, 'position',hdiv.Position, 'bordertype',hdiv.BorderType);
       
% Display data
plotProbeAndSetProperties(handles, length(figures));
rePositionGuiWithinScreen(figures(iNew));



% ---------------------------------------------
function pos = getNewFigPos(handles)
pos = [];
figures = getappdata(handles.figure, 'figures');
if length(figures)<2
    return;
end

hFig = [];
for ii = 1:length(figures)-1
    if ishandles(figures(ii))
        hFig = figures(ii);
    end
end
if ~ishandles(hFig)
    return;
end

if ii==1
    kx = .4;
elseif ii>1
    kx = .04;
end

hFigDup = figures(end);
p = get(hFig,'position');
u = get(hFig,'units');
set(hFigDup, 'units',u, 'position',p);

% Find upper right corner of figure
pu = [p(1)+p(3), p(2)+p(4)];

% find center position of figure
c = [p(1)+(pu(1)-p(1))/2, p(2)+(pu(2)-p(2))/2];

% determine which direction to move new figure relative 
% to hFig based on which quadrant of the screen the center
% of hFig appears.

% Set screen units to match figure units for the purpose of calculating new
% fig position
u0 = get(0,'units');   % Save original screen units in order to restore later
set(0,'units',u);

scrsz = get(0,'screensize');
if c(1)>scrsz(3)/2
    q=-1;
else
    q=+1;
end
offsetX = q*scrsz(3)*kx;
offsetY = p(4)*.02;

% pos = [p(1)+offsetX p(2)+offsetY p(3) p(4)];
pos = [p(1)+offsetX, p(2)-offsetY, p(3), p(4)];
set(0,'units',u0);

% Set relative position with axes to be same in duplicate as in parent 
haxes = findobj2(hFig, 'tag','axes1', 'flat');
p = get(haxes,'position');
if isempty(p)
    return
end
set(gca, 'position',p, 'tag','axes1');




% -------------------------------------------------------------------
function CloseSupporting(hObject)
if ~ishandles(hObject)
    return;
end

% Check to see if any figure associated with this GUI need  to
% be closed as well
msg = sprintf('Do you want to close all supporting figures associated with PlotProbeGUI?');
firstfig = false;
figures = getappdata(hObject, 'figures');
for ii = 2:length(figures)
    if ishandle(figures(ii))
        if firstfig == false
            firstfig = true;
            q = MenuBox(msg, {'YES','NO'});
            if q==2
                break;
            end
        end
        delete(figures(ii));
    end
end
    
    
    
    
% ----------------------------------------------------------------------
function PlotProbeGUI_Close(hObject, ~, ~)
global plotprobe
if isempty(plotprobe)
    return
end
if nargin==0
    hObject = [];
end
if ~isempty(plotprobe.updateParentGui) 
	plotprobe.updateParentGui('PlotProbeGUI');
end
CloseSupporting(hObject)



% ----------------------------------------------------------------------
function PlotProbeGUI_Update(handles, varargin)
global plotprobe

if isempty(plotprobe)
    return
end
if strcmpi(get(handles.menuItemSyncBrowsing, 'checked'), 'off')
    return;
end

ParseArgs(varargin);
axes(handles.axes1);

SetWindowTitle(handles)
SetTextFilename(handles);


% Load current element data from file
if plotprobe.dataTreeHandle.currElem.IsEmpty()
    plotprobe.dataTreeHandle.currElem.Load();
end

% Clear axes of previous data, before redisplaying it
ClearAxesData(handles);
plotProbeAndSetProperties(handles);
figure(handles.figure)



% ----------------------------------------------------------------------
function ClearAxesData(handles, iFig)
data = getappdata(handles.figure, 'data');
if ~exist('iFig','var') || isempty(iFig)
    iFig=1;
end
if isempty(data)
    return
end
if ishandles(data{iFig})
    delete(data{iFig});
    data{iFig} = [];
end
setappdata(handles.figure, 'data',data);



% --------------------------------------------------------------------
function menuItemChangeGroup_Callback(~, ~, ~)
pathname = uigetdir(pwd, 'Select a NIRS data group folder');
if pathname==0
    return;
end
cd(pathname);
PlotProbeGUI();



% --------------------------------------------------------------------
function pushbuttonExit_Callback(~, ~, handles)
if ishandles(handles.figure)
    delete(handles.figure);
end



% -----------------------------------------------------------
function SetTextFilename(handles)
global plotprobe

filename = plotprobe.dataTreeHandle.currElem.GetName();
CondNames = plotprobe.dataTreeHandle.currElem.GetConditions();
if plotprobe.condition>length(CondNames)
    ch = MenuBox('Selected condition does not exist. Please choose from available conditions',[CondNames, 'Cancel']);
    if ch==length(CondNames)+1
        return;
    end
    plotprobe.condition = ch;
end

[~, treeNodeName] = fileparts(filename);
if isempty(handles)
    return;
end

if ~ishandles(handles.textFilename)
    return;
end

% Set name of current processing element and the length of the text box
% framing it
if ~isempty(CondNames)
    if plotprobe.datatype == plotprobe.datatypeVals.CONC_HRF || ...
       plotprobe.datatype == plotprobe.datatypeVals.OD_HRF
        name = sprintf('   %s,    condition: ''%s''', treeNodeName, CondNames{plotprobe.condition});
    else
        name = sprintf('   %s,    condition:  N/A', treeNodeName);
    end
else
    name = sprintf('   %s,    condition:  N/A', treeNodeName);
end
n = length(name) + 0.5*length(name);
set(handles.textFilename, 'units','characters');
p1 = get(handles.textFilename, 'position');
set(handles.textFilename, 'position',[p1(1), p1(2), n, p1(4)], 'string',name);
p1 = get(handles.textFilename, 'position');

% Set the border frame size and position to be relative to text box holding the name 
set(handles.textFilenameFrame, 'units','characters');
p2 = get(handles.textFilenameFrame, 'position');
set(handles.textFilenameFrame, 'position',[p2(1), p2(2), p1(3)+(2.5*abs(p1(1)-p2(1))), p2(4)]);

% Return to normalized units for textbox
set(handles.textFilename, 'units','normalized');
set(handles.textFilenameFrame, 'units','normalized');




% --------------------------------------------------------------------
function b = menuItemSyncBrowsing_Callback(hObject, eventdata, handles)
global plotprobe

if nargin==1
    eventdata = '';
    handles = [];
elseif nargin==2
    handles = [];
end

b = 0;
if ischar(eventdata) && strcmpi(eventdata, 'get')
    b = strcmpi(get(hObject, 'checked'), 'on');
    return
end

if strcmpi(get(hObject, 'checked'), 'off')
    set(hObject, 'checked', 'on')
    SyncBrowsing(plotprobe, 'on');
    if ~isempty(handles)
        PlotProbeGUI_Update(handles);
    end
else
    set(hObject, 'checked', 'off')
    SyncBrowsing(plotprobe, 'off');
end



% --------------------------------------------------------------------
function radiobuttonShowStd_Callback(~, ~, handles)
ClearAxesData(handles);
plotProbeAndSetProperties(handles);

