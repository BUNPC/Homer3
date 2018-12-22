function selection = checkboxinputdlg(choices, name)

% Syntax:
%
%    selection = checkboxinputdlg(choices)
%    selection = checkboxinputdlg(choices, name)
%
% Inputs:
%    
%    choices:   Cell array of strings specifying the radio button choices
%               to select from. 
%    name:      (Optional) argument naming the dialog. The name describes 
%               what the choices are about.
% Output:
%    
%    selection: Index into choices cell array argument of the selected option
%   
% Description
%     
%    Create input dialog with radiobutton options for every member in the argument 
%    cell array choices. The dialog allows you to select one and one only option 
%    among the number of options if choices. When user clicks the 'Submit' button, 
%    checkboxinputdlg returns the index of the option selected from the choices 
%    argument. 
% 
% Examples:
% 
%    supportedFormats = {'.hdf5', '.jason', '.xml', '.html'};
%    selection = checkboxinputdlg(supportedFormats, 'Select Supported File Format')
%
% Author: Jay Dubb, jdubb@bu.edu
% Date:   Dec, 2018
%

selection = [];

global handles
handles.inprogress = true;
handles.selection = selection;

if ~exist('choices','var') || isempty(choices)
    choices = {};
end
if ~iscell(choices)
    error('Choices must be cell array of strings');
end
if ~exist('name','var') || isempty(name)
    name = '';
end

N = length(choices);
nrows = N+2;

% radio button size
xsize_bttn = 0.20;
if N>12
    ysize_bttn = 0.05;
    ysize_bttn_gap = .005;
    ypos_fig = .01;
elseif N>20
    ysize_bttn = 0.05;
    ysize_bttn_gap = .001;
    ypos_fig = .02;
elseif N<=12
    ysize_bttn = 0.08;
    ysize_bttn_gap = .01;
    ypos_fig = .20;
end
xpos_bttn  = 0.40;

xsize_fig  = 0.30;
ysize_fig  = 0.80;

ypos_offset = 0.86;
ystep = 0.01;

% Create figure and set it's size and position based on number of choices
hFig = figure('name',name, 'menu','none', 'numbertitle','off', 'DeleteFcn',{@figureDeleteFcn_Callback});
positionGUI(hFig, 0.25, ypos_fig, xsize_fig, ysize_fig);

hh(1,1) = uicontrol('parent',hFig, 'style','text', 'units','normalized', 'position',[0.10, ypos_offset, 0.80, 0.10], ...
                   'string',name, 'fontsize',11, 'fontweight','bold', 'horizontalalignment','center');
      
hh(1,2) = uicontrol('parent',hFig, 'style','edit', 'units','normalized', 'position',[0.00, ypos_offset+5*ystep, 1.00, 0.005], 'string','');

hChoice = [];
ypos_bttn = ypos_offset-5*ystep;
for ii=1:N
    hChoice(1,ii) = uicontrol('parent',hFig, 'style','radiobutton', 'units','normalized', ...
                            'position',[xpos_bttn, ypos_bttn, xsize_bttn*2, ysize_bttn], ...
                            'string',['  ', choices{ii}], ...
                            'fontsize',10, 'fontweight','bold', 'horizontalalignment','right', ...
                            'callback',{@radiobuttonFileFormat_Callback}, 'userdata',ii);
    ypos_bttn = ypos_bttn - (ysize_bttn+ysize_bttn_gap);
end

hh(1,3) = uicontrol('parent',hFig, 'style','pushbutton', 'string','Submit', 'fontsize',10, 'fontweight','bold', ...
               'units','normalized', 'position',[0.25, ypos_bttn, 0.18, 0.05], 'callback',@Save_Callback);
hh(1,4) = uicontrol('parent',hFig, 'style','pushbutton', 'string','Cancel', 'fontsize',10, 'fontweight','bold', ...
               'units','normalized', 'position',[0.55, ypos_bttn, 0.18, 0.05], 'callback',@Cancel_Callback);

moveFigObjectsDown(hFig);
adjustFigurePos(hFig);


handles.hChoice = hChoice;

while handles.inprogress
    pause(.01);
end

selection = handles.selection;






% -------------------------------------------------------------------
function radiobuttonFileFormat_Callback(hObject, eventdata)
global handles

set(handles.hChoice, 'value',0);
set(hObject, 'value',1);
handles.selection = get(hObject, 'userdata');



% -------------------------------------------------------------------
function choice = figureDeleteFcn_Callback(hObject, eventdata)
global handles

handles.inprogress = false;



% -------------------------------------------------------------------
function Save_Callback(hObject, eventdata)
delete(get(hObject, 'parent'));



% -------------------------------------------------------------------
function Cancel_Callback(hObject, eventdata)
global handles

handles.selection = [];
delete(get(hObject, 'parent'));




% -------------------------------------------------------------------
function moveFigObjectsDown(hFig)
hc = get(hFig, 'children');
set(hc, 'units','pixels');
k = find(strcmpi('submit',get(hc, 'string')));
p = get(hc(k), 'position');
z = p(2)-10;
for ii=1:length(hc)
    p = get(hc(ii), 'position');
    set(hc(ii), 'position', [p(1), p(2)-z, p(3), p(4)]);    
end

% Now that we moved all figure child objects down, crop figure itself by
% same amount as was used to move all the child objects down. . 
p = get(hFig,'position');
set(hFig,'position',[p(1), p(2), p(3), p(4)-z]);
set(hc, 'units','normalized');
drawnow;




% -------------------------------------------------------------
function adjustFigurePos(hFig)

ps = get(0,'screensize');

p = get(hFig,'position');
if p(4)>ps(4)
    positionGUI(hFig, p(1)/ps(3), 0.10, p(3)/ps(3), 0.80);
    p = get(hFig,'position');
end
if (p(2)+p(4))>ps(4)
    d = (p(2)+p(4)) - ps(4);
    d = d+.1*d;
    positionGUI(hFig, p(1)/ps(3), (p(2)-d)/ps(4), p(3)/ps(3), p(4)/ps(4));
    p = get(hFig,'position');
end




