function varargout = ProcStreamOptionsGUI(varargin)
% PROCSTREAMUPTIONSGUI M-file for ProcStreamOptionsGUI.fig
%      PROCSTREAMUPTIONSGUI, by itself, creates a new PROCSTREAMUPTIONSGUI or raises the existing
%      singleton*.
%
%      H = PROCSTREAMUPTIONSGUI returns the handle to a new PROCSTREAMUPTIONSGUI or the handle to
%      the existing singleton*.
%
%      PROCSTREAMUPTIONSGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROCSTREAMUPTIONSGUI.M with the given input arguments.
%
%      PROCSTREAMUPTIONSGUI('Property','Value',...) creates a new PROCSTREAMUPTIONSGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ProcStreamOptionsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ProcStreamOptionsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ProcStreamOptionsGUI

% Last Modified by GUIDE v2.5 30-Jul-2013 16:29:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ProcStreamOptionsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ProcStreamOptionsGUI_OutputFcn, ...
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




% ----------------------------------------------------------
function ProcStreamOptionsGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for ProcStreamOptionsGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(hObject,'visible','off');  % to be turnedmade visible in ProcStreamOptionsGUI_OutputFcn

currElem = varargin{1};
currElem.handles.ProcStreamOptionsGUI = hObject;
procInput = currElem.procElem.procInput;
procFunc = procInput.procFunc;

if isempty(procFunc)
    return;
end

clf(hObject);
set(hObject, 'units','characters');
nfunc = length(procFunc);

% If not function throw up empty gui
if nfunc==0
    uicontrol(hObject, 'style','text', 'string','');
	% Need to make sure position data is saved in pixel units at end of function 
	% to as these are the units used to reposition GUI later if needed
    set(hObject, 'units','pixels');
    setappdata(hObject,'position',get(hObject, 'position'));
    return;
end

% Pre-calculate figure height
for iFunc = 1:nfunc
    funcHeight(iFunc) = 1+procFunc(iFunc).nFuncParam-1;
end
ystep = 1.8;
ysize_tot = sum(funcHeight)*ystep + nfunc*2 + 5;
xsize_fname = getFuncNameMaxStrLength(procFunc);
xsize_pname = getParamNameMaxStrLength(procFunc);
xpos_pname = xsize_fname+10;
xpos_pedit = xpos_pname+xsize_pname+10;
xpos_pbttn = xpos_pedit+15;
xsize_tot  = xpos_pbttn+15;

% Set figure size 
if length(varargin)>2 && ~isempty( varargin{2})
    pos = varargin{2};  % previous figures position
else
    pos = get(hObject, 'position');
end
set(hObject, 'position',[pos(1),pos(2),xsize_tot,ysize_tot]);
set(hObject, 'units','pixels');
set(hObject, 'color',[1 1 1]);

% Display functions and parameters in figure
ypos = ysize_tot-5;
for iFunc = 1:nfunc
    
    % Draw function name
    xsize = length(procFunc(iFunc).funcName);
    xsize = xsize+(5-mod(xsize,5));
    h_fname = uicontrol(hObject, 'style','text', 'units','characters', 'position',[2 ypos xsize 1],...
                        'string',procFunc(iFunc).funcName);
    set(h_fname,'backgroundcolor',[1 1 1], 'units','normalized');
    set(h_fname, 'horizontalalignment','left');
    set(h_fname, 'tooltipstring',procFunc(iFunc).funcHelp.genDescr);
    
    % Draw pushbutton to see output results if requested in config file
    if procFunc(iFunc).funcArgOut(1)=='#'
        h_bttn = uicontrol(hObject, 'style','pushbutton', 'units','characters', 'position',[xpos_pbttn ypos 10 1.3],...
                          'string','Results');
        eval( sprintf(' fcn = @(hObject,eventdata)ProcStreamOptionsGUI(''pushbuttonProc_Callback'',hObject,%d,guidata(hObject));',iFunc) );
        set( h_bttn, 'Callback',fcn, 'units','normalized')
    end
    
    % Draw list of parameters
    for iParam = 1:procFunc(iFunc).nFuncParam
        % Draw parameter names
        xsize = length(procFunc(iFunc).funcParam);
        xsize = xsize+(5-mod(xsize,5))+5;
        h_pname=uicontrol(hObject, 'style','text', 'units','characters', 'position',[xpos_pname ypos xsize 1],...
                          'string',procFunc(iFunc).funcParam{iParam});
        set(h_pname,'backgroundcolor',[1 1 1], 'units','normalized');
        set(h_pname, 'horizontalalignment', 'left');
        set(h_pname, 'tooltipstring', procFunc(iFunc).funcHelp.paramDescr{iParam});

        % Draw parameter edit boxes
        h_pedit=uicontrol(hObject,'style','edit','units','characters','position',[xpos_pedit ypos 10 1.5]);
        procFunc(iFunc).funcParamHandle{iParam} = h_pedit;
        set(h_pedit,'string',sprintf(procFunc(iFunc).funcParamFormat{iParam}, ...
            procFunc(iFunc).funcParamVal{iParam} ) );
        set(h_pedit,'backgroundcolor',[1 1 1]);
        eval( sprintf(' fcn = @(hObject,eventdata)ProcStreamOptionsGUI(''edit_Callback'',hObject,[%d %d],guidata(hObject));',iFunc,iParam) );
        set( h_pedit, 'Callback',fcn, 'units','normalized');

        ypos = ypos - ystep;
    end
    
    % If function has no parameters, skip a step in the y direction
    if procFunc(iFunc).nFuncParam==0
        ypos = ypos - ystep;
    end
    
    
    % Draw divider between functions and function parameter lists
    if iFunc<nfunc
        h_linebttn = uicontrol(hObject,'style','pushbutton','units','characters','position', ...
                               [0 ypos xsize_tot .3],...
                               'enable','off');
        set(h_linebttn, 'units','normalized');
        ypos = ypos - ystep;
    end
    
end

procParam0 = [];
for iFunc=1:length(procFunc)
    for iParam=1:procFunc(iFunc).nFuncParam
        eval( sprintf('procParam0.%s_%s = procInput.procFunc(iFunc).funcParamVal{iParam};',...
                      procFunc(iFunc).funcName, procFunc(iFunc).funcParam{iParam}) );
    end
end
procInput.procFunc = procFunc;
procInput.procParam = procParam0;
currElem.procInput = procInput;
hmr.currElem = currElem;

% Make sure the options GUI fits on screen
set(hObject, 'units','normalized')
p = get(hObject,'position');
if (p(2)+p(4))>.9
    set(hObject, 'position',[.10, .10, p(3), .80]);
end


% Why do we save this? Matlab doesn't take into account multiple monitors 
% when deciding whether a figure is going beyond it seems that whatever position is assigned to
% the gui, if it's outside the primary monotor (ie, on a secondary monitor)
% the gui_*** functions reposition it right back to the primary monitor, 
% overriding the position settings in this function. Annoying! 
% To overcome this problem we save the position data here and then 
% reposition if back to this setting in the ProcStreamOptionsGUI_OutputFcn
% which is called function after matlab's meddling. 

% Need to make sure position data is saved in pixel units at end of function 
% to as these are the units used to reposition GUI later if needed
set(hObject, 'units','pixels');
setappdata(hObject,'position',get(hObject, 'position'));



% ----------------------------------------------------------
function varargout = ProcStreamOptionsGUI_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = hObject;

% Restore the gui position set in ProcStreamOptionsGUI_OpeningFcn
set(hObject,'units','pixels')
pos_curr = get(hObject,'position');
pos_saved = getappdata(hObject,'position');
[posx_adjust, posy_adjust] = posAdjust(pos_curr, pos_saved);
set(hObject, 'position',[pos_saved(1)+posx_adjust, ...
                         pos_saved(2)+posy_adjust, ...
                         pos_saved(3), ...
                         pos_saved(4)]);
set(hObject,'visible','on');




% --------------------------------------------------------------------
function ProcStreamOptionsGUI_DeleteFcn(hObject, eventdata, handles)
global hmr

if isempty(hmr)
    return;
end
currElem = hmr.currElem;

currElem.handles.ProcStreamOptionsGUI = [];
hmr.currElem = currElem;



% ----------------------------------------------------------
function edit_Callback(hObject, eventdata, handles) 
global hmr

currElem = hmr.currElem;
procInput = currElem.procElem.procInput;

iFunc  = eventdata(1);
iParam = eventdata(2);
val = str2num( get(hObject,'string') ); % need to check if it is a valid string
procInput.procFunc(iFunc).funcParamVal{iParam} = val;
eval( sprintf('procInput.procParam.%s_%s = val;', ...
              procInput.procFunc(iFunc).funcName, ...
              procInput.procFunc(iFunc).funcParam{iParam}) );
set( hObject, 'string', sprintf(procInput.procFunc(iFunc).funcParamFormat{iParam}, val) );

currElem.procElem.procInput = procInput;
hmr.currElem = currElem;



% ----------------------------------------------------------
function pushbutton_Callback(hObject, eventdata, handles) 
global hmr

currElem = hmr.currElem;
procInput = currElem.procInput;
procResult = currElem.procResult;

% parse output parameters
foos = procInput.procFunc(eventdata).funcArgOut;

% remove '[', ']', and ','
for ii=1:length(foos)
    if foos(ii)=='[' | foos(ii)==']' | foos(ii)==',' | foos(ii)=='#'
        foos(ii) = ' ';
    end
end

% get parameters for Output to procResult
sargin = '';
lst = strfind(foos,' ');
lst = [0 lst length(foos)+1];
flag = 1;
for ii=1:length(lst)-1
    foo2 = foos(lst(ii)+1:lst(ii+1)-1);
    idx = strfind(foo2,'foo');
    if (isempty(idx) || idx>1) && ~isempty(foo2)
        sargin = sprintf( '%s, hmr.procResult.%s',sargin,foo2);
    elseif idx==1
        sargin = sprintf( '%s, []',sargin);
    end
end

eval( sprintf( '%s_result( %s );', procInput.procFunc(eventdata).funcName, sargin(2:end) ) );

hmr.currElem.procInput = procInput;




% -----------------------------------------------------------------
function maxnamelen = getFuncNameMaxStrLength(procFunc)

maxnamelen=0;
for iFunc =1:length(procFunc)
    if length(procFunc(iFunc).funcName) > maxnamelen
        maxnamelen = length(procFunc(iFunc).funcName);
    end
end




% -----------------------------------------------------------------
function maxnamelen = getParamNameMaxStrLength(procFunc)

maxnamelen=0;
for iFunc=1:length(procFunc)
    for iParam=1:length(procFunc(iFunc).funcParam)
        if length(procFunc(iFunc).funcParam{iParam})>maxnamelen
            maxnamelen = length(procFunc(iFunc).funcParam{iParam});
        end
    end
end




% --------------------------------------------------------------------
function menuExit_Callback(hObject, eventdata, handles)

hGui=get(get(hObject,'parent'),'parent');
close(hGui);



% --------------------------------------------------------------------
% Function to readjust window position when it's outside the borders of 
% the screen. It also takes into account multiple monitor screens. 
% This function assumes pixel units.
function [posx_adjust, posy_adjust] = posAdjust(pos_curr, pos_saved)

posx_adjust = 0;
posy_adjust = 0;

if ~all(pos_curr==pos_saved)
    mp = get(0, 'MonitorPositions');    
    screensize = [1 1 max(mp(:,3)) min(mp(:,4))];
    posx_min_offset = pos_saved(1)-screensize(1);
    posx_max_offset = (screensize(1)+screensize(3)) - (pos_saved(1)+pos_saved(3));
    posy_min_offset = pos_saved(2)-screensize(2);
    posy_max_offset = (screensize(2)+screensize(4)) - (pos_saved(2)+pos_saved(4));
    extrapixels = 10;
    
    % When adjusting window position down, important to add extra pixels of
    % adjustment to uncover the figures positioning bar which might be 10-20
    % pixels thick. Somehow on windows the positioning math fails to
    % unhide it and it's annoyingly impossible to move or kill the
    % figure window
    size_window_pos_bar = 40;

    if posx_min_offset<0
        posx_adjust = posx_adjust-(posx_min_offset+extrapixels);
    end
    if posx_max_offset<0
        posx_adjust = posx_adjust+(posx_max_offset-extrapixels);
    end
    if posy_min_offset<0
        posy_adjust = posy_adjust-(posy_min_offset+extrapixels);
    end
    if posy_max_offset<0
        posy_adjust = posy_adjust+(posy_max_offset-size_window_pos_bar);
    end
end


