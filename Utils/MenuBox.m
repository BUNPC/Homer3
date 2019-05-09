function [selection, hf] = MenuBox(msg, varargin)
global bttnId
bttnId = [];

DEBUG=1;

if isempty(varargin)
    bttns = {'OK'};
elseif ischar(varargin{1})
    bttns = varargin;
elseif length(varargin)==1 && iscell(varargin{1})
    bttns = cell(length(varargin{1}),1);
    for ii=1:length(varargin{1})
        bttns{ii} = varargin{1}{ii};
    end
else
    return;
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
Wbttn     = bttnlenmax*(abs(fs_min-fs));
Hbttn     = 3;

Wtext = floor(nchar/80) + mod(nchar,80)*(fs-fs_min);
Htext = round(nchar / Wtext)+4;

% Position/dimensions in the X direction
a    = 5;
Wfig = Wtext+0.1*Wtext;                % GUI width

% Position/dimensions in the Y direction
vertgap = 2;
Hfig    = Htext + nbttns*(Hbttn+vertgap);

% Get position of parent GUI in character units
hParent = gcf;
set(hParent, 'units','characters');
posParent = get(hParent, 'position');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculate GUI objects position/dimensions in the Y and Y 
% directions, in characters units
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hf = figure('numbertitle', 'off', 'menubar','none', 'toolbar','none', 'name',title);
set(hf, 'visible','off');
set(hf, 'units','characters');

% Determine optimal position of MenuBox relative to parent GUI
pX = posParent(1)+0.8*posParent(3);
pY = posParent(2)+0.3*posParent(4);
posBox = [pX, pY, Wfig, Hfig];

% Set GUI position/size
set(hf, 'position', posBox);
p = get(hf, 'position');

% Display message
ht = uicontrol('parent',hf, 'style','text', 'units','characters', 'string',msg, 'position',[a, p(4)-Htext-vertgap, Wtext, Htext]);

% Draw button options
hb = zeros(nbttns,1); 
p  = zeros(nbttns,4);
TextPos = get(ht, 'position');
for k = 1:nbttns
    Ypfk = TextPos(2) - k*(Hbttn+vertgap/3);
    p(k,:) = [a, Ypfk, Wbttn, Hbttn];
    
    if DEBUG
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

