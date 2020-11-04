function [selection, hf] = MenuBox(msg, bttns, relativePos, textLineWidth)
global bttnId
bttnId = [];

DEBUG=0;
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
if ~exist('textLineWidth','var') || isempty(textLineWidth)
    textLineWidth = 70;
end

title = 'MENU';

bttnstrlenmax = 0;
for ii=1:length(bttns)
    if length(bttns{ii})>bttnstrlenmax
        bttnstrlenmax = length(bttns{ii});
    end
end
bttnstrlenmin = 7;

nchar     = length(msg);
nbttns    = length(bttns);
if bttnstrlenmax<bttnstrlenmin
    Wbttn = 2.1*bttnstrlenmin;
else
    Wbttn = 2.1*bttnstrlenmax;
end
Hbttn = 2.7;

if Wbttn < textLineWidth
    Wtext = textLineWidth;                       % In char units
else
    Wtext = 1.1 * Wbttn;
end
Htext = round(nchar / Wtext)+4;

% Position/dimensions in the X direction
a    = 5;
Wfig = Wtext+0.1*Wtext;                % GUI width

% Position/dimensions in the Y direction
vertgap = 1.2;
Hfig    = (Htext+vertgap+1) + nbttns*(Hbttn+vertgap) + vertgap*1.5;

% Get position of parent GUI in character units
hParent = get(groot,'CurrentFigure');
if isempty(hParent)
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
[pX, pY] = positionRelative(hf, posParent, relativePos);
posBox = [pX, pY, Wfig, Hfig];

if DEBUG
    fprintf('posBox = [%0.1f, %0.1f, %0.1f, %0.1f]\n', posBox(1), posBox(2), posBox(3), posBox(4));
end 


% Set GUI position/size
set(hf, 'position', posBox);
p = get(hf, 'position');

% Display message
if DEBUG2
    fprintf('message position:   [%0.1f, %0.1f, %0.1f, %0.1f]\n', a, p(4)-Htext-vertgap, Wtext, Htext);
    ht = uicontrol('parent',hf, 'style','text', 'units','characters', 'string',msg, ...
                   'position',[a, p(4)-(Htext+vertgap+1), Wtext, Htext], 'horizontalalignment','left', ...
                   'backgroundcolor',[.2,.2,.2], 'foregroundcolor',[.9,.9,.9]);
else
    ht = uicontrol('parent',hf, 'style','text', 'units','characters', 'string',msg, ...
                   'position',[a, p(4)-(Htext+vertgap+1), Wtext, Htext], 'horizontalalignment','left');
end

% Draw button options
hb = zeros(nbttns,1); 
p  = zeros(nbttns,4);
TextPos = get(ht, 'position');
for k = 1:nbttns
    Ypfk = TextPos(2) - k*(Hbttn+vertgap);
    p(k,:) = [2*a, Ypfk, Wbttn, Hbttn];
    
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
rePositionGuiWithinScreen(hf);

% Change units back to characters
set(hf, 'visible','on', 'units','characters');

% Wait for user to respond before exiting
t = 0;
while isempty(bttnId) && ishandles(hf)
    t=t+1;
    pause(.2);
    if mod(t,30)==0
        fprintf('Waiting for user responce, t = %d ticks\n', t);
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


% -------------------------------------------------------------
function [pX, pY] = positionRelative(hf, posParent, relativePos)
lr = .5;
ul = 0;
posFig = get(hf, 'position');

leftSide = posParent(1);
rightSide = posParent(1)+posParent(3);
lowerSide = posParent(2);
upperSide = posParent(2)+posParent(4);

pX = rightSide - .5*posParent(3);
pY = lowerSide + .25*posParent(4);
switch(lower(relativePos))
    case 'upperleft'
        pX = leftSide  - lr*posFig(3);
        pY = upperSide - ul*posFig(4);
    case 'centerleft'
        pX = leftSide  - lr*posFig(3);
        pY = lowerSide + ul*posFig(4);
    case 'lowerleft'
        pX = leftSide  - lr*posFig(3);
        pY = lowerSide + ul*posFig(4);
    case 'upperright'
        pX = rightSide  - lr*posFig(3);
        pY = upperSide - ul*posFig(4);
    case 'centerright'
        pX = rightSide  - lr*posFig(3);
        pY = lowerSide + ul*posFig(4);
    case 'lowerright'
        pX = rightSide  - lr*posFig(3);
        pY = lowerSide + ul*posFig(4);
end

