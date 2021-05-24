function configSettingsGUI(nParamsPerCol)

if nargin==0
    nParamsPerCol = 6;
end
if nParamsPerCol<1
    nParamsPerCol = 1;
end
if nParamsPerCol>12
    nParamsPerCol = 12;
end

InitializeGuiStruct();
hf = CreateGui();
ResetGui(hf);
ResizeGui(hf, nParamsPerCol);
DrawConfigParams(hf)
DrawBttns(hf);


% -------------------------------------------------------------
function InitializeGuiStruct()
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
    'handle',[] ...
    );

cfgGui.filedata = ConfigFileClass();

% char to pixel conversion
cfgGui.units = 'pixels';
[fx, fy] = guiUnitConversion('characters', cfgGui.units);

% Hardcode size of each parameter panel in char units
cfgGui.ysizeParam = 5*fy;
cfgGui.xsizeParam = 50*fx;

% Hardcode size of each buttons
cfgGui.ysizeBttn = 2*fy;
cfgGui.xsizeBttn = 20*fx;

% Gaps sizes between controls
cfgGui.ysizeGap = 1*fy;
cfgGui.xsizeGap = 2*fx;

cfgGui.fontsizeVals = 9;
cfgGui.posParam     = [.10,.10,.80,.80];




% -------------------------------------------------------------
function hf = CreateGui()
global cfgGui

if ~ishandles(cfgGui.handle)
    hf = figure('name', 'App Setting Config GUI', 'NumberTitle','off', 'MenuBar','none', 'ToolBar','none', 'units',cfgGui.units);
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
function ResizeGui(hf, nParamsPerCol)
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
function DrawConfigParams(hf)
global cfgGui

np = cfgGui.filedata.GetParamNum();
hp = zeros(np,1);
for i = 1:cfgGui.ncols
    for j = 1:cfgGui.nrows
        % Figure out param panel position
        xpos    = (cfgGui.xsizeParam+cfgGui.xsizeGap)*(i-1) + cfgGui.xsizeGap;
        ypos    = cfgGui.ysizeTotal - 2*cfgGui.ysizeGap - (cfgGui.ysizeParam+cfgGui.ysizeGap)*j;
        posPanel = [xpos, ypos, cfgGui.xsizeParam, cfgGui.ysizeParam];

        ip = cfgGui.nParamsPerCol*(i-1) + j;
        if ip>np
            if np==0
                uicontrol(hf, 'Style','text', 'string','CONFIG FILE IS EMPTY', 'FontSize',11, ...
                          'fontweight','bold', 'units',cfgGui.units, 'Position',posPanel, 'foregroundcolor',[.6,.3,.1]);
            end
            break;
        end

        % Draw param panel
        hp(ip) = uipanel('parent',hf, 'Title',cfgGui.filedata.GetParamName(ip), 'FontSize',10, 'fontweight','bold', 'foregroundcolor',[.6,.3,.1], ...
            'units',cfgGui.units, 'Position',posPanel);
        
        % Draw param values control within panel. Note all controls have same relative position within panel 
        pval = cfgGui.filedata.GetParamValue(ip);
        if isempty(cfgGui.filedata.GetParamValueOptions(ip))
            hv = uicontrol(hp(ip), 'Style','edit', 'string',pval, 'FontSize',cfgGui.fontsizeVals, 'fontweight','bold', 'Tag',cfgGui.filedata.GetParamName(ip), ...
                'units','normalized', 'position',cfgGui.posParam);
        else
            hv = uicontrol(hp(ip), 'Style','popupmenu', 'string',cfgGui.filedata.GetParamValueOptions(ip), ...
                'FontSize',cfgGui.fontsizeVals, 'fontweight','bold', 'Tag',cfgGui.filedata.GetParamName(ip), ...
                'units','normalized', 'position',cfgGui.posParam);
            k = find(strcmp(cfgGui.filedata.GetParamValueOptions(ip), pval));
            if isempty(k)
                set(hv, 'string',[{''}, cfgGui.filedata.GetParamValueOptions(ip)]);
            else
                hv.Value = k;
            end
        end
        hv.Callback = @setVal;
    end
end



% -------------------------------------------------------------
function DrawBttns(hf)
global cfgGui

if cfgGui.ncols == 1
    k = 10;
else
    k = 5;
end
xoffset = cfgGui.xsizeTotal/k;
hBttnSave = uicontrol(hf, 'Style','pushbutton', 'FontSize',15, 'Units',cfgGui.units, 'String','Save', ...
    'Position', [xoffset, cfgGui.ysizeTotal-(cfgGui.ysizeParamsAll+cfgGui.ysizeParam), cfgGui.xsizeBttn, cfgGui.ysizeBttn]);
hBttnSave.Callback = @cfgSave;
hBttnExit = uicontrol(hf, 'Style','pushbutton', 'FontSize',15, 'Units',cfgGui.units, 'String','Exit', ...
    'Position', [cfgGui.xsizeTotal-(cfgGui.xsizeBttn+xoffset), cfgGui.ysizeTotal-(cfgGui.ysizeParamsAll+cfgGui.ysizeParam), cfgGui.xsizeBttn, cfgGui.ysizeBttn]);
hBttnExit.Callback = @cfgExit;




% -------------------------------------------------------------
function setVal(src,~)
global cfgGui
if iscell(src.String)
    cfgGui.filedata.SetValue(src.Tag, src.String{src.Value});
else
    cfgGui.filedata.SetValue(src.Tag, src.String);
end


% -------------------------------------------------------------
function cfgSave(~,~) %#ok<*DEFNU>
global cfgGui
cfgGui.filedata.Save();
close;


% -------------------------------------------------------------
function cfgExit(~,~)
close;





