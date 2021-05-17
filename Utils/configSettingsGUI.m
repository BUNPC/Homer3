function configSettingsGUI
global cfgSet

cfgSet = ConfigFileClass();

% Hardcode size of each parameter panel in char units
ysize = 5;
xsize = 50;


% Hardcode size of each buttons
ysizeBttn = 2;
xsizeBttn = 20;


% Gaps sizes between controls
ygapsize = 1;
xgapsize = 2;


% Calculate number of columns and rows needed to accomodate all the
% parameters
np = length(cfgSet.sections);
nParamsPerCol = 8;
ncols = floor(np/nParamsPerCol)+1;
nrows = nParamsPerCol;


% Create figure and calculate it's size
hf = figure('name', 'App Setting Config GUI', 'NumberTitle','off', 'MenuBar','none', 'ToolBar','none', 'units','characters');
p0 = get(hf, 'position');
ysizeParamsGui = nrows * (ysize + ygapsize) + 2*ygapsize;
xsizeParamsGui = ncols * (xsize + xgapsize) + 2*xgapsize;
d = ysizeParamsGui - p0(4);
offset = 0;
if d>0
    offset = d;
end
ysizeGui = ysizeParamsGui+ysizeBttn+4*ygapsize;
xsizeGui = xsizeParamsGui;
set(hf, 'position', [p0(1), p0(2)-offset, xsizeGui, ysizeGui])


% Draw all param panels and their controls in the figure gui
fontsizeVals = 9;
posParam     = [.10,.10,.80,.80];
hp           = zeros(np,1);
for i = 1:ncols
    for j = 1:nrows
        % Figure out param panel position
        xpos    = (xsize+xgapsize)*(i-1) + xgapsize;
        ypos    = ysizeGui - 2*ygapsize - (ysize+ygapsize)*j;
        
        ip = nParamsPerCol*(i-1) + j;
        if ip>np
            break;
        end

        % Draw param panel
        posPanel = [xpos, ypos, xsize, ysize];
        hp(ip) = uipanel('Title',cfgSet.sections(ip).name, 'FontSize',10, 'fontweight','bold', 'foregroundcolor',[.6,.3,.1], ...
            'units','characters', 'Position',posPanel);
        
        % Draw param values control within panel. Note all controls have same relative position within panel 
        pval = '';
        if ~isempty(cfgSet.sections(ip).val)
            pval = cfgSet.sections(ip).val{1};
        end
        if isempty(cfgSet.sections(ip).param)
            hv = uicontrol(hp(ip), 'Style','edit', 'string',pval, 'FontSize',fontsizeVals, 'fontweight','bold', 'Tag',cfgSet.sections(ip).name, ...
                'units','normalized', 'position',posParam);
        else
            hv = uicontrol(hp(ip), 'Style','popupmenu', 'string',cfgSet.sections(ip).param, ...
                'FontSize',fontsizeVals, 'fontweight','bold', 'Tag',cfgSet.sections(ip).name, ...
                'units','normalized', 'position',posParam);
            k = find(strcmp(cfgSet.sections(ip).param, pval));
            if isempty(k)
                set(hv, 'string',[{''}, cfgSet.sections(ip).param(:)']);
            else
                hv.Value = k;
            end
        end
        hv.Callback = @setVal;
    end
end

% Draw buttons
xoffset = xsizeGui/5;
hBttnSave = uicontrol('Style','pushbutton', 'FontSize',15, 'Units','characters', 'String','Save', ...
    'Position', [xoffset, ysizeGui-(ysizeParamsGui+ysize), xsizeBttn, ysizeBttn]);
hBttnSave.Callback = @cfgSave;
hBttnExit = uicontrol('Style','pushbutton', 'FontSize',15, 'Units','characters', 'String','Exit', ...
    'Position', [xsizeGui-(xsizeBttn+xoffset), ysizeGui-(ysizeParamsGui+ysize), xsizeBttn, ysizeBttn]);
hBttnExit.Callback = @cfgExit;



% -------------------------------------------------------------
function setVal(src,~)
global cfgSet
if iscell(src.String)
    cfgSet.SetValue(src.Tag, src.String{src.Value});
else
    cfgSet.SetValue(src.Tag, src.String);
end


% -------------------------------------------------------------
function cfgSave(~,~) %#ok<*DEFNU>
global cfgSet
cfgSet.Save();
close;


% -------------------------------------------------------------
function cfgExit(~,~)
close;





