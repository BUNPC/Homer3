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
function varargout = ProcStreamOptionsGUI_OutputFcn(hObject, eventdata, handles)
handles.updateptr = @ProcStreamOptionsGUI_Update;
handles.closeptr = [];
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




% ----------------------------------------------------------------------
function ParseArgs(args)
global procStreamOptions
global hmr

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

%  Syntax:
%
%     ProcStreamOptionsGUI()
%     ProcStreamOptionsGUI(format)
%     ProcStreamOptionsGUI(format, pos)
%     ProcStreamOptionsGUI(format, applyEditCurrNodeOnly)
%     ProcStreamOptionsGUI(format, applyEditCurrNodeOnly, pos)

% Arguments take precedence over parent gui parameters
if length(varargin)==0
    return;                                                  % ProcStreamOptionsGUI()
elseif length(varargin)==1
    if ischar(varargin{1})                 
        procStreamOptions.format = varargin{1};                      % ProcStreamOptionsGUI(format)
    end
elseif length(varargin)==2
    if ischar(varargin{1})
        procStreamOptions.format = varargin{1};
        if isreal(varargin{2}) & length(varargin{2})==4     
            procStreamOptions.pos = varargin{2};                    % PlotProbeGUI(format, pos)
        elseif iswholenum(varargin{2}) & length(varargin{2})==1
            procStreamOptions.applyEditCurrNodeOnly = varargin{2};               % PlotProbeGUI(format, applyEditCurrNodeOnly)
        end
    end
elseif length(varargin)==3
    procStreamOptions.format                 = varargin{1};
    procStreamOptions.applyEditCurrNodeOnly  = varargin{2};
    procStreamOptions.pos                    = varargin{3};                      % PlotProbeGUI(format, datatype, condition, pos)
end

% Now whichever of the above parameters weren't assigned values
% obtain values either from parent gui or assign default value
if isempty(hmr)
    if isempty(procStreamOptions.format)
        procStreamOptions.format = 'snirf';
    end
    if isempty(procStreamOptions.applyEditCurrNodeOnly)
        procStreamOptions.applyEditCurrNodeOnly = false;
    end
else
    procStreamOptions.format = hmr.format;
    procStreamOptions.applyEditCurrNodeOnly = hmr.guiControls.applyEditCurrNodeOnly;
end


% ----------------------------------------------------------
function ProcStreamOptionsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global procStreamOptions
global hmr

% Choose default command line output for ProcStreamOptionsGUI
handles.output = hObject;
guidata(hObject, handles);
set(hObject,'visible','off');  % to be made visible in ProcStreamOptionsGUI_OutputFcn

Initialize(handles);
ParseArgs(varargin);

% See if we can recover previous position
p = procStreamOptions.pos;
if ~isempty(p)
    set(hObject, 'position', [p(1), p(2), p(3), p(4)]);
end
procStreamOptions.version  = get(hObject, 'name');
procStreamOptions.dataTree = LoadDataTree(procStreamOptions.format, '', hmr);
if ispc()
    setGuiFonts(hObject, 7);
else
    setGuiFonts(hObject);
end
Display(handles);



% ----------------------------------------------------------
function Display(handles)
global procStreamOptions
hObject = handles.figure;

hc = get(hObject, 'children');
if ishandles(hc)
    delete(hc);
end

procInput = procStreamOptions.dataTree.currElem.procStream.input;
fcalls = procInput.fcalls;

if isempty(fcalls)
    menu('Processing stream is empty. Please check the registry to see if any user functions were loaded.', 'OK')
    return;
end

nFcall = length(fcalls);

% If no functions, throw up empty gui
if nFcall==0
    uicontrol(hObject, 'style','text', 'string','');
	% Need to make sure position data is saved in pixel units at end of function 
	% to as these are the units used to reposition GUI later if needed
    set(hObject, 'units','characters');
    return;
end

% Pre-calculate figure height
funcHeight = zeros(nFcall,1);
for iFcall = 1:nFcall
    funcHeight(iFcall) = 1+length(fcalls(iFcall).paramIn)-1;
end
ystep = 1.8;
ysize = 1.5;
ysize_tot = sum(funcHeight)*ystep + nFcall*2 + 5;
xsize_fname = getFuncNameMaxStrLength(fcalls)+2;
xsize_pname = getParamNameMaxStrLength(fcalls)+2;
xsize_pval  = 15;
xpos_pname  = xsize_fname+10;
xpos_pedit  = xpos_pname+xsize_pname+10;
xpos_pbttn  = xpos_pedit++xsize_pval+15;
xsize_tot   = xpos_pbttn+15;

pos = get(hObject, 'position');
set(hObject, 'color',[1 1 1]);
set(hObject, 'position',[pos(1),pos(2),xsize_tot,ysize_tot]);

% Display functions and parameters in figure
ypos = ysize_tot-5;
for iFcall = 1:nFcall
    
    % Draw function name
    xsize = length(fcalls(iFcall).name)+5;
    xsize = xsize+(5-mod(xsize,5));
    h_fname = uicontrol(hObject, 'style','text', 'units','characters', 'position',[2, ypos, xsize, ysize],...
                        'string',fcalls(iFcall).name);
    set(h_fname, 'backgroundcolor',[1 1 1], 'units','normalized');
    set(h_fname, 'horizontalalignment','left');
    set(h_fname, 'tooltipstring',fcalls(iFcall).help);
    
    % Draw pushbutton to see output results if requested in config file
    if fcalls(iFcall).argOut.str(1)=='#'
        h_bttn = uicontrol(hObject, 'style','pushbutton', 'units','characters', 'position',[xpos_pbttn, ypos, 10, ysize],...
                          'string','Results');
        eval( sprintf(' fcn = @(hObject,eventdata)ProcStreamOptionsGUI(''pushbuttonProc_Callback'',hObject,%d,guidata(hObject));',iFcall) );
        set( h_bttn, 'Callback',fcn, 'units','normalized')
    end
    
    % Draw list of parameters
    for iParam = 1:length(fcalls(iFcall).paramIn)
        % Draw parameter names
        pname = fcalls(iFcall).paramIn(iParam).name;
        h_pname=uicontrol(hObject, 'style','text', 'units','characters', 'position',[xpos_pname, ypos, xsize_pname, ysize],...
                          'string',pname);
        set(h_pname, 'backgroundcolor',[1 1 1], 'units','normalized');
        set(h_pname, 'horizontalalignment', 'left');
        set(h_pname, 'tooltipstring', fcalls(iFcall).paramIn(iParam).help);

        % Draw parameter edit boxes
        h_pedit=uicontrol(hObject,'style','edit','units','characters','position',[xpos_pedit, ypos, xsize_pval, 1.5]);
        set(h_pedit,'string',sprintf(fcalls(iFcall).paramIn(iParam).format, fcalls(iFcall).paramIn(iParam).value ) );
        set(h_pedit,'backgroundcolor',[1 1 1]);
        eval( sprintf(' fcn = @(hObject,eventdata)ProcStreamOptionsGUI(''edit_Callback'',hObject,[%d %d],guidata(hObject));',iFcall,iParam) );
        set( h_pedit, 'Callback',fcn, 'units','normalized');

        ypos = ypos - ystep;
    end
    
    % If function has no parameters, skip a step in the y direction
    if isempty(fcalls(iFcall).paramIn)
        ypos = ypos - ystep;
    end
    
    
    % Draw divider between functions and function parameter lists
    if iFcall<nFcall
        h_linebttn = uicontrol(hObject, 'style','pushbutton', 'units','characters', 'position',[0, ypos, xsize_tot, .3],...
                               'enable','off');
        set(h_linebttn, 'units','normalized');
        ypos = ypos - ystep;
    end
    
end
% Make sure the options GUI fits on screen
[b, p] = guiOutsideScreenborders(hObject);
if abs(b(4))>0 || abs(b(2))>0
    h = ysize_tot/100;
    k = 1-h;
    positionGUI(hObject, p(1), 0.12, p(3), k*h+h);
end

% Why do we save this? Matlab doesn't take into account multiple monitors 
% when deciding whether a figure is going beyond it seems that whatever position is assigned to
% the gui, if it's outside the primary monotor (ie, on a secondary monitor)
% the gui_*** functions reposition it right back to the primary monitor, 
% overriding the position settings in this function. Annoying! 
% To overcome this problem we save the position data here and then 
% reposition if back to this setting in the ProcStreamOptionsGUI_OutputFcn
% which is called function after matlab's meddling. 

setappdata(hObject,'position',get(hObject, 'position'));
setGuiFonts(hObject);



% ----------------------------------------------------------
function edit_Callback(hObject, eventdata, handles) 
global procStreamOptions

dataTree = procStreamOptions.dataTree;

iFcall  = eventdata(1);
iParam = eventdata(2);
val = str2num( get(hObject,'string') ); % need to check if it is a valid string

str = dataTree.currElem.procStream.EditParam(iFcall, iParam, val);
set( hObject, 'string', str);

% Check if we should apply the param edit to all nodes of the current nodes
% level
if ~procStreamOptions.applyEditCurrNodeOnly
    if dataTree.currElem.iRun==0
        for ii=1:length(dataTree.group.subjs)
            dataTree.group.subjs(ii).procStream.EditParam(iFcall, iParam, val);
        end
    elseif dataTree.currElem.iRun>0
        for ii=1:length(dataTree.group.subjs)
            for jj=1:length(dataTree.group.subjs(ii).runs)
                dataTree.group.subjs(ii).runs(jj).procStream.EditParam(iFcall, iParam, val);
            end
        end
    end
end


% ----------------------------------------------------------
function pushbuttonProc_Callback(hObject, eventdata, handles) 
global procStreamOptions

dataTree = procStreamOptions.dataTree;
procInput = dataTree.currElem.procStream.input;
procResult = dataTree.currElem.procStream.output;

% parse output parameters
sargout = procInput.fcalls(eventdata).argOut.str;

% remove '[', ']', and ','
for ii=1:length(sargout)
    if sargout(ii)=='[' | sargout(ii)==']' | sargout(ii)==',' | sargout(ii)=='#'
        sargout(ii) = ' ';
    end
end
sargout_arr = str2cell(sargout, ' ');

% get parameters for Output to procResult
sargin = '';
for ii=1:length(sargout_arr)
    if isempty(sargin)
        if isproperty(procResult, sargout_arr{ii})
            sargin = sprintf('procResult.%s', sargout_arr{ii});
        elseif isproperty(procResult.misc, sargout_arr{ii})
            sargin = sprintf('procResult.misc.%s', sargout_arr{ii});
        end
    else
        if isproperty(procResult, sargout_arr{ii})
            sargin = sprintf('%s, procResult.%s', sargin, sargout_arr{ii});
        elseif isproperty(procResult.misc, sargout_arr{ii})
            sargin = sprintf('%s, procResult.misc.%s', sargin, sargout_arr{ii});
        end
    end
end

eval( sprintf( '%s_result( %s );', procInput.fcalls(eventdata).name, sargin ) );

procStreamOptions.dataTree.currElem.procStream.input = procInput.copy;



% -----------------------------------------------------------------
function maxnamelen = getFuncNameMaxStrLength(fcalls)

maxnamelen=0;
for iFcall =1:length(fcalls)
    if length(fcalls(iFcall).name) > maxnamelen
        maxnamelen = length(fcalls(iFcall).name)+1;
    end
end


% -----------------------------------------------------------------
function maxnamelen = getParamNameMaxStrLength(fcalls)

maxnamelen=0;
for iFcall=1:length(fcalls)
    for iParam=1:length(fcalls(iFcall).paramIn)
        if length(fcalls(iFcall).paramIn(iParam).name)>maxnamelen
            maxnamelen = length(fcalls(iFcall).paramIn(iParam).name)+1;
        end
    end
end




% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)

hGui=get(get(hObject,'parent'),'parent');
close(hGui);



% -------------------------------------------------------------------
function [b, p] = guiOutsideScreenborders(hObject)

b = [0, 0, 0, 0];
units_orig = get(hObject,'units');
set(hObject,'units','normalized');
p = get(hObject,'position');
if p(1)+p(3)>=1 || p(1)<0
    if p(1)+p(3)>=1
        b(1)=(p(1)+p(3))-1;
    else
        b(1)=0-p(1);
    end
end
if p(2)+p(4)>=1 || p(2)<0
    if p(2)+p(4)>=1
        b(2)=(p(2)+p(4))-1;
    else
        b(2)=0-p(2);
    end
end
if p(3)>=1
    b(3)=p(3)-1;
end
if p(4)>=1
    b(4)=p(4)-1;
end
set(hObject,'units',units_orig);



