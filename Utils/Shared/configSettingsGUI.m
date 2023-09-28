function handles = configSettingsGUI(varargin)
handles = [];

% Parse args
[filenames, nParamsPerCol, lastpos, options] = ParseArgs(varargin);

InitializeGuiStruct(filenames, options);
hf = CreateGui();
ResetGui(hf);
ResizeGui(hf, nParamsPerCol, lastpos);
hBttnSave = DrawBttns(hf);
DrawConfigParams(hf, hBttnSave);
handles.figure = hf;


% ----------------------------------------------------------
function [filenames, nParamsPerCol, lastpos, options] = ParseArgs(args)
filenames = {};
nParamsPerCol = [];
lastpos = [];
options = '';
if ~isempty(args) && isnumeric(args{end}) && length(args{end})==4
    lastpos = args{end};
    args(end) = [];
end
if length(args)==1
    if iscell(args{1}) || ischar(args{1})
        filenames = args{1};
    else
        nParamsPerCol = args{1};
    end
elseif length(args)==2
    if iscell(args{1}) || ischar(args{1})
        filenames = args{1};
        nParamsPerCol = args{2};
    else
        filenames = args{2};
        nParamsPerCol = args{1};
    end
elseif length(args)==3
    if iscell(args{1}) || ischar(args{1})
        filenames = args{1};
        nParamsPerCol = args{2};
    else
        filenames = args{2};
        nParamsPerCol = args{1};
    end
    options = args{2};
end
if ~exist('filenames','var') || isempty(filenames)
    filenames = {};
end
if ~exist('nParamsPerCol','var') || isempty(nParamsPerCol)
    nParamsPerCol = 6;
end
if ~exist('options','var') 
    options = '';
end    
if nParamsPerCol<1
    nParamsPerCol = 1;
end
if nParamsPerCol>12
    nParamsPerCol = 12;
end




% -------------------------------------------------------------
function InitializeGuiStruct(filenames, options)
global cfgGui

if ~isempty(cfgGui)
    if ishandles(cfgGui.handle)
        return;
    end
end

cfgGui = struct(...
    'filedata',[], ...
    'ysizeParam',0, ...
    'xsizeParam',0, ...
    'ysizeBttn',0, ...
    'xsizeBttn',0, ...
    'ysizeGap',0, ...
    'xsizeGap',0, ...
    'nrows',0, ...
    'ncols',0, ...
    'ysizeTotal',0, ...
    'xsizeTotal',0, ...
    'ysizeParamsAll',0, ...
    'xsizeParamsAll',0, ...
    'nParamsPerCol',8, ...
    'handle',[], ...
    'pos',[] ...
    );

cfgGui.filedata = ConfigFileClass(filenames);

% char to pixel conversion
cfgGui.units = 'pixels';
[fx, fy] = guiUnitConversion('characters', cfgGui.units);

% Hardcode size of each parameter panel in char units
cfgGui.ysizeParam = 5*fy;
cfgGui.xsizeParam = 50*fx;

% Hardcode size of each buttons
cfgGui.ysizeBttn = 2.4*fy;
cfgGui.xsizeBttn = 25*fx;

% Gaps sizes between controls
cfgGui.ysizeGap = 1*fy;
cfgGui.xsizeGap = 2*fx;

cfgGui.fontsizes = [15, 11, 10, 9];
if ismac()
    cfgGui.fontsizes = cfgGui.fontsizes+4;
end
cfgGui.posParam     = [.10,.10,.80,.80];

cfgGui.options = options;



% -------------------------------------------------------------
function hf = CreateGui()
global cfgGui

if ~ishandles(cfgGui.handle)
    hf = figure('name', 'App Setting Config GUI', 'NumberTitle','off', 'MenuBar','none', 'ToolBar','none', ...
        'units',cfgGui.units);
else
    hf = cfgGui.handle;
end
cfgGui.handle = hf;




% -------------------------------------------------------------
function ResetGui(hf)
hc = get(hf, 'children');
for ii = 1:length(hc)
    if strcmpi(get(hc(ii), 'type'), 'uimenu')
        continue;
    end
    delete(hc(ii));
end



% -------------------------------------------------------------
function ResizeGui(hf, nParamsPerCol, ~)
global cfgGui

cfgGui.nParamsPerCol = nParamsPerCol;

p0 = get(hf, 'position');

% Calculate number of columns and rows needed to accomodate all the
% parameters
cfgGui.np = cfgGui.filedata.GetParamNum();
if floor(cfgGui.np/cfgGui.nParamsPerCol) == 0
    k = 1;
elseif floor(cfgGui.np/cfgGui.nParamsPerCol) == cfgGui.np/cfgGui.nParamsPerCol
    k = 0;
else
    k = 1;
end
cfgGui.ncols = floor(cfgGui.np/cfgGui.nParamsPerCol)+k;
cfgGui.nrows = cfgGui.nParamsPerCol;
cfgGui.ysizeParamsAll = cfgGui.nrows * (cfgGui.ysizeParam + cfgGui.ysizeGap) + 2*cfgGui.ysizeGap;
cfgGui.xsizeParamsAll = cfgGui.ncols * (cfgGui.xsizeParam + cfgGui.xsizeGap) + 2*cfgGui.xsizeGap;
cfgGui.ysizeTotal = cfgGui.ysizeParamsAll+cfgGui.ysizeBttn+4*cfgGui.ysizeGap;
cfgGui.xsizeTotal = cfgGui.xsizeParamsAll;
set(hf, 'position', [p0(1), p0(2), cfgGui.xsizeTotal, cfgGui.ysizeTotal])
rePositionGuiWithinScreen(hf);



% -------------------------------------------------------------
function hv = DrawConfigParams(hf, hBttnSave)
global cfgGui

np = cfgGui.filedata.GetParamNum();
hp = zeros(np,1);
hcm = setMouseClickAction();

for i = 1:cfgGui.ncols
    for j = 1:cfgGui.nrows
        % Figure out param panel position
        xpos    = (cfgGui.xsizeParam+cfgGui.xsizeGap)*(i-1) + cfgGui.xsizeGap;
        ypos    = cfgGui.ysizeTotal - 2*cfgGui.ysizeGap - (cfgGui.ysizeParam+cfgGui.ysizeGap)*j;
        posPanel = [xpos, ypos, cfgGui.xsizeParam, cfgGui.ysizeParam];

        ip = cfgGui.nParamsPerCol*(i-1) + j;
        if ip>np
            if np==0
                uicontrol(hf, 'Style','text', 'string','CONFIG FILE IS EMPTY', 'FontSize',cfgGui.fontsizes(2), ...
                          'fontweight','bold', 'units',cfgGui.units, 'Position',posPanel, 'foregroundcolor',[.6,.3,.1]);
            end
            break;
        end

        % Draw param panel
        hp(ip) = uipanel('parent',hf, 'Title',cfgGui.filedata.GetParamName(ip), 'FontSize',cfgGui.fontsizes(3), 'fontweight','bold', 'foregroundcolor',[.6,.3,.1], ...
            'units',cfgGui.units, 'Position',posPanel);        
        
        % Draw param values control within panel. Note all controls have same relative position within panel 
        pval = cfgGui.filedata.GetParamValue(ip);
        if isempty(pval)
            pval = '';
        end
        if isempty(cfgGui.filedata.GetParamValueOptions(ip))
            hv = uicontrol(hp(ip), 'Style','edit', 'string',pval, 'FontSize',cfgGui.fontsizes(4), 'fontweight','bold', 'Tag',cfgGui.filedata.GetParamName(ip), ...
                           'units','normalized', 'position',cfgGui.posParam);
        else
            hv = uicontrol(hp(ip), 'Style','popupmenu', 'string',cfgGui.filedata.GetParamValueOptions(ip), ...
                           'FontSize',cfgGui.fontsizes(4), 'fontweight','bold', 'Tag',cfgGui.filedata.GetParamName(ip), ...
                           'units','normalized', 'position',cfgGui.posParam);
            k = find(strcmp(cfgGui.filedata.GetParamValueOptions(ip), pval));
            if isempty(k)
                set(hv, 'string',[{''}; cfgGui.filedata.GetParamValueOptions(ip)]);
            else
                hv.Value = k;
            end            
        end
        hv.Callback = {@setVal, hBttnSave};
    end
    
end

if verGreaterThanOrEqual('matlab','9.8')
    set(hp, 'ContextMenu',setMouseClickAction(hcm,hp));
else
    set(hp, 'ButtonDownFcn',{@mouseClickFcn_Callback,hp});
end
set(hf, 'ButtonDownFcn',{@mouseClickFcn_Callback,hp});



% -------------------------------------------------------------
function [hBttnSave, hBttnExit] = DrawBttns(hf)
global cfgGui

if cfgGui.ncols == 1
    k = 10;
else
    k = 5;
end
xoffset = cfgGui.xsizeTotal/k;
hBttnSave = uicontrol(hf, 'Style','pushbutton', 'FontSize',cfgGui.fontsizes(1), 'Units',cfgGui.units, 'String','SAVE', ...
    'Position', [xoffset, cfgGui.ysizeTotal-(cfgGui.ysizeParamsAll+cfgGui.ysizeParam), cfgGui.xsizeBttn, cfgGui.ysizeBttn]);
hBttnSave.Callback = @cfgSave;
hBttnExit = uicontrol(hf, 'Style','pushbutton', 'FontSize',cfgGui.fontsizes(1), 'Units',cfgGui.units, 'String','EXIT', ...
    'Position', [cfgGui.xsizeTotal-(cfgGui.xsizeBttn+xoffset), cfgGui.ysizeTotal-(cfgGui.ysizeParamsAll+cfgGui.ysizeParam), cfgGui.xsizeBttn, cfgGui.ysizeBttn]);
hBttnExit.Callback = @cfgExit;
setappdata(hBttnSave, 'backgroundcolororiginal',hBttnSave.BackgroundColor); 
setappdata(hBttnSave, 'foregroundcolororiginal',hBttnSave.ForegroundColor); 




% -------------------------------------------------------------
function setVal(hObject, ~, hBttnSave)
global cfgGui

if strcmp(hObject.Style, 'popupmenu')
    if hObject.Value>0
        s = hObject.String{hObject.Value};
    else
        s = {};
    end
else
    s = hObject.String;
end
if iscell(s) && ~isempty(s)
    s = s{1};
elseif isempty(s)    
    s = '';
end

% Check if param value has changed
if cfgGui.filedata.ChangedValue(hObject.Tag, s)
    hBttnSave.BackgroundColor = [.90, .10, .05];
    hBttnSave.ForegroundColor = [.90, .80, .75];
end
cfgGui.filedata.SetValue(hObject.Tag, s);



% -------------------------------------------------------------
function cfgSave(hObject, ~) %#ok<*DEFNU>
global cfgGui
global cfg
cfgGui.filedata.Save();

% This is the only place in configSettingsGUI that we access global cfg.
% We only use it to update the global variable when we to save changes
if isa(cfg, 'ConfigFileClass')
    cfg.Update();
end

hObject.BackgroundColor = getappdata(hObject, 'backgroundcolororiginal'); 
hObject.ForegroundColor = getappdata(hObject, 'foregroundcolororiginal'); 
if optionExists(cfgGui.options, {'keepopen','stayopen'})
    return
end
close;



% -------------------------------------------------------------
function cfgExit(~,~)
close;


% -------------------------------------------------------------
function mouseClickFcn_Callback(hObject, ~, handles)
type = get(hObject, 'type');
if strcmp(type, 'figure')
    return;
end
    
hf = [];
while ~strcmp(type, 'root')
    hObject = get(hObject, 'parent');
    type = get(hObject, 'type');    
    if strcmp(type, 'figure')
        hf = hObject;
        break;
    end
end
if isempty(hf)
    return;
end
    
me = get(hf,'selectiontype');
if ~strcmp(me, 'alt')
    return
end

mp = get(hf,'currentpoint');
if length(mp)<2
    return;
end
% fprintf('Mouse click position: [%0.1f, %0.1f]:\n\n', mp(1), mp(2));
paramNameClicked = '';
for ii = 1:length(handles)
    p = get(handles(ii), 'position');
    paramName = get(handles(ii), 'title');
    if (mp(1)>=p(1) && mp(1)<=p(1)+p(3)) && (mp(2)>=p(2) && mp(2)<=p(2)+p(4))
        % fprintf('**** Clicked on ''%s'': [%0.1f, %0.1f] ****\n', paramName, p(1), p(2));
        paramNameClicked = paramName;
    else
        % fprintf('Param ''%s'' position: [%0.1f, %0.1f]\n', paramName, p(1), p(2));
    end
end
if isempty(paramNameClicked)
    return;
end
clipboard('copy',paramNameClicked) 
msg = sprintf('''%s''   copied to clipboard',paramNameClicked);
try
    MessageBox(msg, sprintf('Parameter: ''%s''', paramNameClicked), 'timelimit');
catch
    msgbox(msg);
end


% -------------------------------------------------------------
function hcm = setMouseClickAction(hcm, hp)
if nargin<2
    hcm = uicontextmenu();
    uimenu(hcm, 'text','Copy Param Name');
    return
end
hm = get(hcm, 'children');
hm.MenuSelectedFcn = {@mouseClickFcn_Callback,hp};

