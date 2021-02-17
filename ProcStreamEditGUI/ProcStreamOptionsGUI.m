function varargout = ProcStreamOptionsGUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProcStreamOptionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProcStreamOptionsGUI_OutputFcn, ...
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
function ProcStreamOptionsGUI_Update(varargin)
if nargin==0
    return;
end
handles = varargin{1};
ParseArgs(varargin);
Display(handles);



% -------------------------------------------------------------
function ProcStreamOptionsGUI_Close()
global procStreamOptions
procStreamOptions.updateParentGui('ProcStreamOptionsGUI');




% -------------------------------------------------------------
function varargout = ProcStreamOptionsGUI_OutputFcn(hObject, eventdata, handles)
handles.updateptr = @ProcStreamOptionsGUI_Update;
handles.closeptr = @ProcStreamOptionsGUI_Close;
if ~ishandles(hObject)
    handles.figure = -1;
end
varargout{1} = handles;



% ----------------------------------------------------------------------
function Initialize(handles)
global procStreamOptions

procStreamOptions = [];

procStreamOptions.status = -1;

% These are the parameters that are assigned from external sources,
% either from GUI arguments or parent GUI. 
procStreamOptions.format = '';
procStreamOptions.applyEditCurrNodeOnly = [];
procStreamOptions.pos = [];
procStreamOptions.handles = [];
setGuiFonts(handles.figure, 7);



% ----------------------------------------------------------------------
function ParseArgs(args)
global procStreamOptions
global maingui

if ~exist('args','var')
    return;
end

varargin = args;

%%%% These are the parameters that are assigned from external soutrces,
%%%% either from GUI arguments or parent GUI. 
%
% procStreamOptions.format
% procStreamOptions.applyEditCurrNodeOnly
% procStreamOptions.pos
%

% Arguments take precedence over parent gui parameters
if length(varargin)==0
    return;                                                         % ProcStreamOptionsGUI()
elseif length(varargin)==1
    procStreamOptions.groupDirs = varargin{1};                      % ProcStreamOptionsGUI(groupDirs)
elseif length(varargin)==2
    procStreamOptions.groupDirs = varargin{1};                      
    if ischar(varargin{1})                
        procStreamOptions.format = varargin{2};                     % ProcStreamOptionsGUI(groupDirs, format)
    end
elseif length(varargin)==3
    procStreamOptions.groupDirs = varargin{1};
    if ischar(varargin{2})
        procStreamOptions.format = varargin{2};
        if isreal(varargin{3}) & length(varargin{3})==4     
            procStreamOptions.pos = varargin{3};                    % PlotProbeGUI(groupDirs, format, pos)
        elseif iswholenum(varargin{3}) & length(varargin{3})==1
            procStreamOptions.applyEditCurrNodeOnly = varargin{3};  % PlotProbeGUI(groupDirs, format, applyEditCurrNodeOnly)
        end
    else
        procStreamOptions.applyEditCurrNodeOnly = varargin{2};      % PlotProbeGUI(groupDirs, applyEditCurrNodeOnly, pos)
        procStreamOptions.pos = varargin{3};
    end
elseif length(varargin)==4
    procStreamOptions.groupDirs              = varargin{1};
    procStreamOptions.format                 = varargin{2};
    procStreamOptions.applyEditCurrNodeOnly  = varargin{3};
    procStreamOptions.pos                    = varargin{4};         % PlotProbeGUI(groupDirs, format, datatype, condition, pos)
end

% Now whichever of the above parameters weren't assigned values
% obtain values either from parent gui or assign default value
if isempty(maingui)
    if isempty(procStreamOptions.format)
        procStreamOptions.format = 'snirf';
    end
    if isempty(procStreamOptions.applyEditCurrNodeOnly)
        procStreamOptions.applyEditCurrNodeOnly = false;
    end
else
    procStreamOptions.format = maingui.format;
    procStreamOptions.applyEditCurrNodeOnly = maingui.applyEditCurrNodeOnly;
end


% ----------------------------------------------------------
function ProcStreamOptionsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
%
%  Syntax:
%
%  Syntax:
%
%     ProcStreamOptionsGUI()
%     ProcStreamOptionsGUI(groupDirs)
%     ProcStreamOptionsGUI(groupDirs, format)
%     ProcStreamOptionsGUI(groupDirs, format, pos)
%     ProcStreamOptionsGUI(groupDirs, format, applyEditCurrNodeOnly)
%     ProcStreamOptionsGUI(groupDirs, format, applyEditCurrNodeOnly, pos)
%     ProcStreamOptionsGUI(groupDirs, pos)
%     ProcStreamOptionsGUI(groupDirs, applyEditCurrNodeOnly)
%     ProcStreamOptionsGUI(groupDirs, applyEditCurrNodeOnly, pos)
%  
%  Description:
%     GUI used for editing the processing stream user-editable parameters. 
%     
%     NOTE: This GUIs input parameters are passed to it either as formal arguments 
%     or through the calling parent GUIs generic global variable, 'maingui'. If it's 
%     the latter, this GUI follows the rule that it accesses the parent GUIs global 
% 	  variable ONLY at startup time, that is, in the function <GUI Name>_OpeningFcn(). 
%
%  Inputs:
%     format:                 Which acquisition type of files to load to dataTree: e.g., nirs, snirf, etc
%     applyEditCurrNodeOnly:  True/false whether to apply current processing element's parameter edits to all 
%                             processing elements at that level (level's being: run, subject, or group)
%     pos:                    Size and position of last figure session
%
global procStreamOptions
global maingui

% Choose default command line output for ProcStreamOptionsGUI
handles.output = hObject;
guidata(hObject, handles);
set(hObject,'visible','off');  % to be made visible in ProcStreamOptionsGUI_OutputFcn

Initialize(handles);
ParseArgs(varargin);

procStreamOptions.err=0;

if ~isempty(maingui)
    procStreamOptions.updateParentGui = maingui.Update;

    % If parent gui exists disable these menu options which only make sense when
    % running this GUI standalone
    set(handles.menuFile,'visible','off');
    set(handles.menuItemChangeGroup,'visible','off');
    set(handles.menuItemSaveGroup,'visible','off');    
end

% See if we can recover previous position
p = procStreamOptions.pos;
if ~isempty(p)
    set(hObject, 'position', [p(1), p(2), p(3), p(4)]);
end

procStreamOptions.version  = get(hObject, 'name');
procStreamOptions.dataTree = LoadDataTree(pwd, procStreamOptions.format, '', maingui);
if procStreamOptions.dataTree.IsEmpty()
    return;
end
Display(handles);

if procStreamOptions.err<0
    delete(hObject)
end



% ----------------------------------------------------------
function s = Sigma(k, Ys, m)
if k>1
    s = sum(Ys*m(1:k-1));
else
    s = 0;
end



% ----------------------------------------------------------
function Display(handles)
global procStreamOptions

DEBUG = 0;
hObject = handles.figure;

ResetDisplay(handles);

ps = procStreamOptions.dataTree.currElem.procStream;

if isempty(ps.fcalls)
    menu('Processing stream is empty. Please check the registry to see if any user functions were loaded.', 'OK');
    procStreamOptions.err=-1;
    return;
end

fcalls = ps.fcalls;
nFcalls = length(fcalls);

% If no functions, throw up empty gui
if nFcalls==0
    uicontrol(hObject, 'style','text', 'string','');
    return;
end

% Need to make sure position data is saved in pixel units at end of function
% as these are the units used to reposition GUI later if needed
set(hObject, 'units','characters');

if DEBUG
    set(hObject, 'visible','on');
    bgc = [0.10, 0.05, 0.03];
    fgc = [0.80, 0.75, 0.95];
else
    bgc = [0.94, 0.94, 0.94];
    fgc = [0.00, 0.00, 0.00];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate GUI objects position/dimensions in the Y and Y 
% directions, in characters units
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

p = get(hObject, 'position');
fs = 1.5; 

% Position/dimensions in the X direction
[Xsf, numUsages] = ps.GetMaxCallNameLength();
Xsp              = ps.GetMaxParamNameLength();

a     = 2;
Xsf   = Xsf * fs;
Xsp   = Xsp * fs;
Xse   = 20;
Xsb   = 10;
Xp1   = Xsf + a;
Xp2   = Xp1 + a;
Xp3   = Xp2 + Xsp;
Xp4   = Xp3 + a;
Xp5   = Xp4 + Xse;
Xst   = Xsf + Xsp + Xse + Xsb + 4*a;                   % GUI width

% Position/dimensions in the Y direction
N       = nFcalls;
m       = ps.GetParamNum();
b       = 3;
Ys      = 1*fs;                                       % Height of each function call
yoffset = 2;
Yst     = yoffset + ((N+1)*b) + Sigma(N+1, Ys, m);    % GUI height

% Set GUI position/size
set(hObject, 'position', [p(1), p(2), Xst, Yst]);

% Set Exit button size and position
SetExitButtonPosSize(handles, Ys);

% Loop over all functions in proc stream and draw each one starting from the 
% top of the gui going down
h=[]; p=[];
for k = 1:nFcalls
    Ypfk = Yst - (yoffset + k*b + Sigma(k, Ys, m));
    
    if DEBUG
        fprintf('%d) %s:   p1 = [%0.1f, %0.1f, %0.1f, %0.1f]\n', k, fcalls(k).GetUsageName(), a, Ypfk, Xsf, Ys);
    end
    
    % Draw function call divider for clarity
    p(end+1,:) = [0, Ypfk+b/2, Xst, .3];
    h(end+1,:) = uicontrol(hObject, 'style','pushbutton', 'units','characters', 'position',p(end,:),...
                                    'enable','off');
    % Draw function call
    p(end+1,:) = [a, Ypfk, Xsf, Ys];
    if numUsages(k)>1
        fcallname = fcalls(k).GetUsageName();
    else
        fcallname = fcalls(k).GetName();
    end
    h(end+1,:) = uicontrol(hObject, 'style','text', 'units','characters', 'horizontalalignment','left', ...
                                    'units','characters', 'position',p(end,:), 'string',fcallname, ...
                                    'BackgroundColor',bgc, 'ForegroundColor',fgc, ...
                                    'tooltipstring',fcalls(k).GetHelp());
    
    % Draw parameter list names and corresponding edit boxes with the current values
    for j=1:fcalls(k).GetParamNum()
        Ypfkj = Yst - (yoffset + k*b + Sigma(k, Ys, m) + Ys*(j-1));
        
        if DEBUG
            fprintf('    %d) %s:   p2 = [%0.1f, %0.1f, %0.1f, %0.1f]\n', k, fcalls(k).GetParamName(j), Xp2, Ypfkj, Xsp, Ys);
        end
        
        % Draw parameter j name 
        p(end+1,:) = [Xp2, Ypfkj, Xsp, Ys];
        h(end+1,:) = uicontrol(hObject, 'style','text', 'units','characters', 'horizontalalignment','left', ...
                                        'units','characters', 'position',p(end,:), 'string',fcalls(k).GetParamName(j), ...
                                        'BackgroundColor',bgc, 'ForegroundColor',fgc, ...
                                        'tooltipstring', fcalls(k).GetParamHelp(j));

        % Draw edit box for parameter j and fill it with the corresponding value
        p(end+1,:) = [Xp4, Ypfkj, Xse, Ys];
        eval( sprintf(' fcn = @(hObject,eventdata)ProcStreamOptionsGUI(''edit_Callback'',hObject,[%d %d],guidata(hObject));',k,j) );
        h(end+1,:) = uicontrol(hObject, 'style','edit', 'horizontalalignment','left', 'units','characters', 'position',p(end,:), ...
                                        'string',fcalls(k).GetParamValStr(j), ...
                                        'value',str2num(fcalls(k).GetParamValStr(j)), ...  % Store current value
                                        'horizontalalignment','center', ...
                                        'Callback',fcn);
    end
end

% Set all GUI objects except figure to normalized units, so it can be
% resized gracefully
set(h, 'units','normalized');

% % Need to make sure position data is saved in pixel units at end of function
% % to as these are the units used to reposition GUI later if needed
% set(hObject, 'units','pixels');
setGuiFonts(hObject);
rePositionGuiWithinScreen(hObject);

figure(handles.figure);
set(handles.pushbuttonExit, 'units','normalized');


% ----------------------------------------------------------
function edit_Callback(hObject, eventdata, handles) 
global procStreamOptions

dataTree = procStreamOptions.dataTree;
iG = dataTree.GetCurrElemIndexID();

iFcall  = eventdata(1);
iParam = eventdata(2);
fcall = dataTree.currElem.procStream.fcalls(iFcall);
param = fcall.paramIn(iParam);
val = str2num(get(hObject,'string'));

% If str2num fails or user entered wrong number of params
if (~isempty(hObject.String) && isempty(val)) || (length(val) > count(param.GetFormat(), '%'))
    set(hObject, 'string', sprintf(param.GetFormat(), hObject.Value));  % Restore og value
    return;
end

% Edit the parameter
str = dataTree.currElem.procStream.EditParam(iFcall, iParam, val);
if isempty(str)
    set(hObject, 'string', sprintf(param.GetFormat(), hObject.Value));  % Restore og value
    return;
end

% Check for param errchk function associated with this fcall
errmsg = fcall.CheckParams();
if ~isempty(errmsg)
    set(hObject, 'string', sprintf(param.GetFormat(), hObject.Value));  % Restore og value
    dataTree.currElem.procStream.EditParam(iFcall, iParam, hObject.Value);  % Restore param in datatree too
    errordlg(errmsg, 'Invalid parameters', 'modal');
    return;
end

set(hObject, 'string', str);
set(hObject, 'value', str2num(str));  % Actually update the value

% Check if we should apply the param edit to all nodes of the current nodes
% level
if ~procStreamOptions.applyEditCurrNodeOnly
    if dataTree.currElem.iSubj>0 && dataTree.currElem.iRun==0
        for ii=1:length(dataTree.groups(iG).subjs)
            dataTree.groups(iG).subjs(ii).procStream.EditParam(iFcall, iParam, val);
        end
    elseif dataTree.currElem.iSubj>0 && dataTree.currElem.iRun>0
        for ii=1:length(dataTree.groups(iG).subjs)
            for jj=1:length(dataTree.groups(iG).subjs(ii).runs)
                dataTree.groups(iG).subjs(ii).runs(jj).procStream.EditParam(iFcall, iParam, val);
            end
        end
    end
end


% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)

hGui=get(get(hObject,'parent'),'parent');
close(hGui);





% -------------------------------------------------------------------
function pushbuttonExit_Callback(hObject, eventdata, handles)
if ishandles(handles.figure)
    delete(handles.figure);
end



% -------------------------------------------------------------------
function ResetDisplay(handles)

hc = get(handles.figure, 'children');
for ii=1:length(hc)
    if ~ishandles(hc(ii))
        continue;
    end
    if strcmp(get(hc(ii), 'type'), 'uimenu')
        continue;
    end
    if hc(ii)==handles.pushbuttonExit
        continue;
    end
    delete(hc(ii));
end



% -------------------------------------------------------------------
function SetExitButtonPosSize(handles, Ys)

pf = get(handles.figure, 'position');

set(handles.pushbuttonExit, 'units','characters');
pB = get(handles.pushbuttonExit, 'position');
factor = 1;
Xp = pf(3)/2-pB(3)/2;
Yb = Ys*factor;
Ypb = pB(2)+(pB(4)-Ys*factor);
set(handles.pushbuttonExit, 'position', [Xp, Ypb, pB(3), Yb]);



% --------------------------------------------------------------------
function menuItemChangeGroup_Callback(hObject, eventdata, handles)
pathname = uigetdir(pwd, 'Select a NIRS data group folder');
if pathname==0
    return;
end
cd(pathname);
ProcStreamOptionsGUI();




% --------------------------------------------------------------------
function menuItemSaveGroup_Callback(hObject, eventdata, handles)
global procStreamOptions
if ~ishandles(hObject)
    return;
end
procStreamOptions.dataTree.currElem.Save();

