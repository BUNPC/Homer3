function [selection, hf] = MenuBox(msg, bttns, relativePos)
global bttnId
bttnId = [];

DEBUG=1;
DEBUG2=0;

% Parse args 
if ~exist('bttns','var') || isempty(bttns)
    bttns = {'OK'};
elseif exist('bttns','var') && ischar(bttns)
    bttns = {bttns};
end
if ~exist('relativePos','var') || isempty(relativePos)
    relativePos = 'center';
end

title = 'MENU';

bttnlenmax = 0;
for ii=1:length(bttns)
    if length(bttns{ii})>bttnlenmax
        bttnlenmax = length(bttns{ii});
    end
end

fs = 8;
fs_min = 6;

nchar     = length(msg);
nbttns    = length(bttns);
Wbttn     = bttnlenmax*(abs(fs_min-fs))+2;
Hbttn     = 3;

Wtext = 70;                       % In char units
Htext = round(nchar / Wtext)+4;

% Position/dimensions in the X direction
a    = 5;
Wfig = Wtext+0.1*Wtext;                % GUI width

% Position/dimensions in the Y direction
vertgap = 2;
Hfig    = Htext + nbttns*(Hbttn+vertgap);

% Get position of parent GUI in character units
hParent = get(groot,'CurrentFigure');
if ~isempty(hParent)
    hParent = 0;
end
set(hParent, 'units','characters');
if hParent==0
    posParent = get(hParent,'MonitorPositions');
else    
    posParent = get(hParent, 'position');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate GUI objects position/dimensions in the Y and Y 
% directions, in characters units
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hf = figure('numbertitle', 'off', 'menubar','none', 'toolbar','none', 'name',title);
set(hf, 'visible','off');
set(hf, 'units','characters');

% Determine optimal position of MenuBox relative to parent GUI
switch(lower(relativePos))
    case 'upperleft'
        posrel = [.2, .6];
    case 'centerleft'
        posrel = [.2, .3];
    case 'lowerleft'
        posrel = [.2, .1];
    case 'upperright'
        posrel = [.8, .6];
    case 'centerright'
        posrel = [.8, .3];
    case 'lowerright'
        posrel = [.8, .1];
    case 'center'
        posrel = [.3, .3];
    otherwise
        posrel = [.3, .3];
end
pX = posParent(1)+posrel(1)*posParent(3);
pY = posParent(2)+posrel(2)*posParent(4);
posBox = [pX, pY, Wfig, Hfig];

if DEBUG
    fprintf('posBox = [%0.1f, %0.1f, %0.1f, %0.1f]\n', posBox(1), posBox(2), posBox(3), posBox(4));
end 


% Set GUI position/size
set(hf, 'position', posBox);
p = get(hf, 'position');

% Display message
ht = uicontrol('parent',hf, 'style','text', 'units','characters', 'string',msg, ...
               'position',[a, p(4)-Htext-vertgap, Wtext, Htext], 'horizontalalignment','left');

% Draw button options
hb = zeros(nbttns,1); 
p  = zeros(nbttns,4);
TextPos = get(ht, 'position');
for k = 1:nbttns
    Ypfk = TextPos(2) - k*(Hbttn+vertgap/3);
    p(k,:) = [a, Ypfk, Wbttn, Hbttn];
    
    if DEBUG2
        fprintf('%d) %s:   p1 = [%0.1f, %0.1f, %0.1f, %0.1f]\n', k, bttns{k}, p(k,1), p(k,2), p(k,3), p(k,4));
    end
    
    % Draw function call divider for clarity
    hb(k) = uicontrol('parent',hf, 'style','pushbutton', 'string',bttns{k}, 'units','characters', 'position',p(k,:), ...
                      'tag',sprintf('%d', k), 'callback',@pushbuttonGroup_Callback);
end

% Need to make sure position data is saved in pixel units at end of function
% to as these are the units used to reposition GUI later if needed
setGuiFonts(hf);
p = GuiOutsideScreenBorders(hf);
set(hf, 'visible','on', 'position',p);

% Wait for user to respond before exiting
t = 0;
while isempty(bttnId) && ishandles(hf)
    t=t+1;
    pause(.1);
    if mod(t,10)==0
        % fprintf('Waiting for user responce, t = %d ticks\n', t);
    end
end

selection = bttnId;

if ishandles(hf)
    delete(hf);
else
    selection=0;
end


% -------------------------------------------------------------
function pushbuttonGroup_Callback(hObject, eventdata, handles)
global bttnId
bttnId = str2num(get(hObject, 'tag'));



% -------------------------------------------------------------
function maxlen = getMaxLineLength(msg)
maxlen = 0;
lines = str2cell(msg);
for ii=1:length(lines)
    if length(lines{ii})>maxlen
        maxlen=length(lines{ii});
    end
end


