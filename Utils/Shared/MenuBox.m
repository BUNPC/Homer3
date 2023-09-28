function [answer, hf] = MenuBox(msg, bttns, relativePos, textLineWidth, options)

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
%   q = MenuBox('Please select option',{'option1','option2','option3'},[],[],'askEveryTime');
%   q = MenuBox('Please select option',{'option1','option2','option3'},'centerright',[],'dontAskAgainOptions');
%   q = MenuBox('Please select option',{'option1','option2','option3'},[],75,'dontAskAgain');
%
%   % Next few examples use radio button selection style
%   q = MenuBox('Please select option',{'option1','option2','option3'},[],[],'radiobutton');
%   q = MenuBox('Please select option',{'option1','option2','option3'},[],[],'dontAskAgain:radiobutton');
%   q = MenuBox('Please select option',{'option1','option2','option3'},'upperright',80,'askEveryTime:radiobutton');
%
hf = [];

global bttnIds
global selection
global selectionStyle

bttnIds = 0;
selection = 0;

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
if ~exist('options','var') || isempty(options)
    options = '';
end

title = 'MENU';

if optionExists(options, 'radiobutton')
    selectionStyle = 'radiobutton';
else
    selectionStyle = 'pushbutton';
end

% Syntax for special call of MenuBox to ONLY get back the selection of
% "ask/don't ask" checkbox strings, then exit function
checkboxes  = getCheckboxes(options);
if isempty(msg)
    answer = checkboxes;
    return;
end

fs(1) = 10;
fs(2) = 8;
if ismac()
    fs = fs + 4;
end

ncheckboxes = length(checkboxes);
nbttns       = length(bttns)+ncheckboxes;


% Initial X size and position of text
Wtext = textLineWidth;

nNewLines = length(find(msg == sprintf('\n')))+4; %#ok<SPRINTFN>
nLines = ceil(length(msg) / Wtext)*1.5;
Htext = max([nNewLines, nLines]);
HtextGap0 = 1;
HtextGap = 2;

% Initial X sizes and positions of buttons
Wbttn = 65;
WbttnMin = 20;
XbttnOffset = 5;


% Calculate standard width of buttons
WbttnMaxActual = length(bttns{1});
for ii = 1:length(bttns)
    if length(bttns{ii}) > WbttnMaxActual
        WbttnMaxActual = length(bttns{ii});
    end
end
if WbttnMaxActual < Wbttn
    Wbttn = WbttnMaxActual;
end
if WbttnMaxActual < WbttnMin
    Wbttn = WbttnMin;
end

% Initial Y size and position of buttons
Hbttn = 1;
HbttnGap = 2;

% Calculate standard height of buttons
for ii = 1:length(bttns)    
    temp = ceil(length(bttns{ii}) / Wbttn);
    if temp > Hbttn
        Hbttn = temp;
    end
end


% Character size doesn't quite equal character units so we compensate by multiplying by 
% scaling factor in the x and y directions
Wbttn = Wbttn*1.2;
Hbttn = Hbttn*1.2;


% Figure size and position 
if strcmpi(selectionStyle, 'radiobutton')
    Hc = 7;
else
    Hc = 4;
end
XtextOffset = Wtext/8;
Wfig = Wtext + 2*XtextOffset;

HfigBottom = nbttns * (Hbttn + HbttnGap) + Hc;
HfigTop = HtextGap0 + Htext + HtextGap;
Hfig = HfigTop + HfigBottom;

hf = figure('numbertitle', 'off', 'menubar','none', 'toolbar','none', 'name',title, 'resize','on');
%set(hf, 'visible','off');
set(hf, 'units','characters');

hParent = get(groot,'CurrentFigure');
if isempty(hParent)
    hParent = hf;
end
set(hParent, 'units','characters');
posParent = get(hParent, 'position');

% Determine optimal position of MenuBox relative to parent GUI
if hf == hParent
    pX = posParent(1);
    pY = posParent(2);
else
    [pX, pY] = positionRelative(hf, posParent, relativePos);
end
posBox = [pX, pY, Wfig, Hfig];
set(hf, 'position', posBox);
if strcmpi(selectionStyle, 'radiobutton')
    DispSaveCancelBttns(hf);
end
pF = get(hf, 'position');

YbttnStart = Htext + HtextGap;

ht = uicontrol('parent',hf, 'style','text', 'units','characters', 'string',msg, 'fontsize',fs(1), ...
    'position',[XtextOffset, pF(4)-(HtextGap0+Htext), Wtext, Htext], 'horizontalalignment','left', ...
    'userdata',2);    
for k = 1:nbttns
    Ypfk = pF(4) - (YbttnStart + k*(Hbttn+HbttnGap));
    p = [XbttnOffset, Ypfk, Wbttn, Hbttn];    
    if k > (nbttns-ncheckboxes)
        val = GetCheckboxValue(k, nbttns, ncheckboxes, options);
        hb(k) = uicontrol('parent',hf, 'style','checkbox', 'string',checkboxes{k-(nbttns-ncheckboxes)}, 'units','characters', ...
            'position',[p(1), p(2), 2*length(checkboxes{k-(nbttns-ncheckboxes)}), p(4)], 'value',val, ...
            'tag',sprintf('%d', k-(nbttns-ncheckboxes)), 'callback',{@checkboxDontAskOptions_Callback, hf});
        
        checkboxDontAskOptions_Callback(hb(k), [], hf);
    else
        if strcmpi(selectionStyle, 'radiobutton')
            hb = uicontrol('parent',hf, 'style',selectionStyle, 'string','', 'units','characters', 'position',[p(1), p(2), 4, p(4)], ...
                'tag',sprintf('%d', k), 'callback',@pushbuttonGroup_Callback,  'backgroundcolor',[0.80, 0.80, 0.80]);
            
            uicontrol('parent',hf, 'style','text', 'string',bttns{k}, 'units','characters', 'position',[p(1)+4, p(2), p(3), p(4)], ...
                'horizontalalignment','left', 'fontsize',fs(2), 'userdata',2, 'backgroundcolor',[1.0, 1.0, 1.0]);
        else
            if nbttns==1
                p(1) = floor(Wfig/2 - Wbttn/2);
            end
            uicontrol('parent',hf, 'style',selectionStyle, 'string',bttns{k}, 'units','characters', 'position',[p(1), p(2), p(3), p(4)+Hbttn/2], ...
                'tag',sprintf('%d', k), 'fontsize',fs(2), 'callback',@pushbuttonGroup_Callback, 'userdata',2, 'backgroundcolor',[1.0, 1.0, 1.0]);
        end
    end
end

setGuiFonts(hf);
p = guiOutsideScreenBorders(hf);

% Change units temporarily to normalized to apply the repositiong because
% guiOutsideScreenBorders uses normalized units
set(hf, 'visible','on', 'units','normalized', 'position',p);

% Change units back to characters
set(hf, 'units','characters');
normalizeObjPos(hf);

% Wait for user to respond before exiting
t = 0;
while selection(1)==0 && ishandles(hf)
    t=t+1;
    pause(.2);
    if mod(t,30)==0
        if optionExists(options, 'quiet')
            continue
        end
        fprintf('Waiting for user responce, t = %d ticks\n', t);
    end
end

% Call this callback in case default is preselected in the code, that way
% we make sure that if one of the checkboxes is preselected not by user
% action but by code, that we detect that.
checkboxDontAskOptions_Callback([], [], hf)

answer = selection;

if ishandles(hf)
    delete(hf);
else
    if strcmpi(selectionStyle, 'pushbutton')
        answer = 0;
    end
end





% -------------------------------------------------------------
function pushbuttonGroup_Callback(hObject, ~, ~)
global bttnIds
global selection
global selectionStyle
bttnIds(1) = str2num(get(hObject, 'tag'));
if strcmpi(selectionStyle, 'pushbutton')
    selection = bttnIds;
    return;
end
hp = get(hObject,'parent');
hc = get(hp, 'children');
for ii = 1:length(hc)
    if strcmpi(get(hc(ii),'type'), 'uicontrol')
        if strcmpi(get(hc(ii),'style'), 'radiobutton')
            if ~strcmpi(get(hc(ii), 'tag'), get(hObject, 'tag'))
                set(hc(ii), 'value',0);
            end
        end
    end
end



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
        if strcmp(get(hb(ii), 'type'),'uicontrol')
        if strcmp(get(hb(ii), 'style'),'checkbox')
            if get(hb(ii), 'value')
                checkboxId = str2num(get(hb(ii), 'tag'));
                break;
            end
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



% -------------------------------------------------------------
function [hBttnSave, hBttnExit] = DispSaveCancelBttns(hf)
uhf0 = get(hf, 'units');
set(hf, 'units','characters');
phf = get(hf, 'position');
set(hf, 'position',[phf(1), phf(2), phf(3), phf(4)+phf(4)*.2]);
xsize = 20;
ysize = 3;
xpos  = .1*phf(3);
ypos  = .1*phf(4);
hBttnSave = uicontrol(hf, 'Style','pushbutton', 'FontSize',15, 'Units','normalized', 'String','SAVE', 'units','characters', 'Position',[xpos, ypos, xsize, ysize]);
hBttnExit = uicontrol(hf, 'Style','pushbutton', 'FontSize',15, 'Units','normalized', 'String','CANCEL', 'units','characters', 'Position',[phf(3) - (xsize + .1*phf(3)),  ypos, xsize, ysize]);
hBttnSave.Callback = @cfgSave;
hBttnExit.Callback = @cfgExit;
set(hf, 'units',uhf0)



% -------------------------------------------------------------
function cfgSave(hObject, ~) %#ok<*DEFNU>
global bttnIds
global selection
selection = bttnIds;
close;



% -------------------------------------------------------------
function cfgExit(~,~)
close;



% -------------------------------------------------------------
function normalizeObjPos(hf)
hc = get(hf, 'children');
for ii = 1:length(hc)
    set(hc(ii), 'units','normalized');
end



