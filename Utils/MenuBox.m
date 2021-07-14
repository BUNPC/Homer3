function selection = MenuBox(msg, bttns, relativePos, textLineWidth, options)

%
% SYNTAX:
%
%   selection = MenuBox(msg, bttns)
%   selection = MenuBox(msg, bttns, relativePos)
%   selection = MenuBox(msg, bttns, relativePos, textLineWidth)
%   selection = MenuBox(msg, bttns, relativePos, textLineWidth, options)
%
% EXAMPLES:
%
%   q = MenuBox('Please select option',{'option1','option2','option3'});
%   q = MenuBox('Please select option',{'option1','option2','option3'}, 'lowerleft');
%   q = MenuBox('Please select option',{'option1','option2','option3'}, 'upperright',80);
%   q = MenuBox('Please select option',{'option1','option2','option3'},[],[],'dontAskAgain');
%   q = MenuBox('Please select option',{'option1','option2','option3'},'centerright',[],'dontAskAgainOptions');
%   q = MenuBox('Please select option',{'option1','option2','option3'},[],75,'dontAskAgain');
%

global bttnIds
bttnIds = 0;

DEBUG=0;
DEBUG2=0;

% Parse args
if iscell(msg)
    msg = [msg{:}];
end
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
if ~exist('options','var')
    options = '';
end

title = 'MENU';

bttnstrlenmax = 0;
for ii=1:length(bttns)
    if length(bttns{ii})>bttnstrlenmax
        bttnstrlenmax = length(bttns{ii});
    end
end
bttnstrlenmin = 7;

% Syntax for special call of MenuBox to ONLY get back the selection of
% "ask/don't ask" checkbox strings, then exit function
checkboxes  = getCheckboxes(options);
if isempty(msg)
    selection = checkboxes;
    return;
end

nchar        = length(msg);
ncheckboxes  = length(checkboxes);
nbttns       = length(bttns)+ncheckboxes;
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
    
    if k > (nbttns-ncheckboxes)
        val = GetCheckboxValue(k, nbttns, ncheckboxes, options);
        hb(k) = uicontrol('parent',hf, 'style','checkbox', 'string',checkboxes{k-(nbttns-ncheckboxes)}, 'units','characters', ...
            'position',[p(k,1), p(k,2), 2*length(checkboxes{k-(nbttns-ncheckboxes)}), p(k,4)], 'value',val, ...
            'tag',sprintf('%d', k-(nbttns-ncheckboxes)), 'callback',{@checkboxDontAskOptions_Callback, hf});
        
        checkboxDontAskOptions_Callback(hb(k), [], hf);
    else
        hb(k) = uicontrol('parent',hf, 'style','pushbutton', 'string',bttns{k}, 'units','characters', 'position',p(k,:), ...
            'tag',sprintf('%d', k), 'callback',@pushbuttonGroup_Callback);
    end
end

% Need to make sure position data is saved in pixel units at end of function
% to as these are the units used to reposition GUI later if needed
setGuiFonts(hf);
p = guiOutsideScreenBorders(hf);

% Change units temporarily to normalized to apply the repositiong because
% guiOutsideScreenBorders uses normalized units
set(hf, 'visible','on', 'units','normalized', 'position',p);

% Change units back to characters
set(hf, 'units','characters');

% Wait for user to respond before exiting
t = 0;
while bttnIds(1)==0 && ishandles(hf)
    t=t+1;
    pause(.2);
    if mod(t,30)==0
        fprintf('Waiting for user responce, t = %d ticks\n', t);
    end
end

% Call this callback in case default is preselected in the code, that way
% we make sure that if one of the checkboxes is preselected not by user
% action but by code, that we detect that.
checkboxDontAskOptions_Callback([], [], hf)

% Assign button selctions to function output
selection = bttnIds;

if ishandles(hf)
    delete(hf);
else
    selection=0;
end



% -------------------------------------------------------------
function pushbuttonGroup_Callback(hObject, eventdata, hb)
global bttnIds
bttnIds(1) = str2num(get(hObject, 'tag'));



% -------------------------------------------------------------
function checkboxDontAskOptions_Callback(hObject, ~, hf)
global bttnIds

if ~isvalid(hf)
    return
end

hb = get(hf, 'children');
checkboxId = [];
if ishandles(hObject)
    checkboxId = str2num(get(hObject, 'tag'));
    if ~get(hObject, 'value')
        bttnIds(2) = 0;
        return;
    end
else
    for ii = 1:length(hb)
        if strcmp(get(hb(ii), 'style'),'checkbox')
            if get(hb(ii), 'value')
                checkboxId = str2num(get(hb(ii), 'tag'));
                break;
            end
        end
    end
end

if isempty(checkboxId)
    return;
end

bttnIds(2) = checkboxId;

for ii = 1:length(hb)
    if strcmp(get(hb(ii), 'style'),'checkbox')
        if checkboxId ~= str2num(get(hb(ii), 'tag')) %#ok<*ST2NM>
            set(hb(ii), 'value',0);
        end
    end
end



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



% -------------------------------------------------------------
function checkboxes = getCheckboxes(options)

checkboxes = {};
if ~optionExists(options, 'dontAskAgainOptions') && ~optionExists(options, 'dontAskAgain') && ~optionExists(options, 'askEveryTime') && ~optionExists(options, 'askEveryTimeOptions')
    return;
end
if optionExists(options, 'dontAskAgainOptions') || optionExists(options, 'askEveryTimeOptions')
    checkboxes = { ...
        sprintf('don''t ask again');  ...
        sprintf('ask every time'); ...
        % sprintf('ask once at start of next session'); ...
        };
else
    checkboxes = { ...
        sprintf('don''t ask again');  ...
        };
end



% ---------------------------------------------------------------------------------
function val = GetCheckboxValue(k, nbttns, ncheckboxes, options)
val = [];
if optionExists(options, 'dontAskAgain') || optionExists(options, 'dontAskAgainOptions')
    if k-(nbttns-ncheckboxes)==1
        val = 1;
    else
        val = 0;
    end
elseif optionExists(options, 'askEveryTime') 
    if k-(nbttns-ncheckboxes)==1
        val = 0;
    else
        val = 1;
    end
elseif optionExists(options, 'askEveryTimeOptions')
    icheckbox = k-(nbttns-ncheckboxes);
    if icheckbox==ncheckboxes
        val = 1;
    else
        val = 0;
    end
end

