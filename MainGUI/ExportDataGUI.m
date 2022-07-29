function varargout = ExportDataGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportDataGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportDataGUI_OutputFcn, ...
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



% ----------------------------------------------------------------
function InitOutput()
global exportvar

if isfield(exportvar, 'hFigPlot')
    if ishandle(exportvar.hFigPlot)
        delete(exportvar.hFigPlot)
    end
end
exportvar = [];

% Output data structure
exportvar.pathname = '';
exportvar.filename = '';
exportvar.hFigPlot = -1;
exportvar.format = '';
% exportvar.formatchoices = {'.txt','.xls'};
exportvar.formatchoices = {'.txt'};

exportvar.datatype = '';
exportvar.datatypechoices = {'HRF','HRF mean'};

exportvar.trange = [0,0];

exportvar.procElemSelect = '';



% ----------------------------------------------------------------
function UpdateOutput(handles)
global exportvar

% Output data structure
exportvar.filename = get(handles.editFilename, 'string');

% Export format in the form of an extension
options = get(handles.popupmenuExportFormat, 'string');
exportvar.format = options{get(handles.popupmenuExportFormat, 'value')};

% Data type: HRF, or mean HRF or something else
options = get(handles.popupmenuDataType, 'string');
exportvar.datatype = options{get(handles.popupmenuDataType, 'value')};

% Time range for mean HRF within the HRF range 
exportvar.trange = [str2double(get(handles.editTimeRangeMin, 'string')), ...
                    str2double(get(handles.editTimeRangeMax, 'string'))];

% Which processing elements in the data tree to export
if get(handles.radiobuttonCurrProcElemAndSubTree, 'value')
    exportvar.procElemSelect = 'all';
elseif get(handles.radiobuttonCurrProcElemOnly, 'value')
    exportvar.procElemSelect = 'currentonly';
end


% ----------------------------------------------------------------
function ExportDataGUI_OpeningFcn(hObject, ~, handles, varargin)
global exportvar

InitOutput();

% Set filename edit box without the extension
if ~isempty(varargin)
    fname = '';
    if ~isempty(varargin{1})
        [~, fname] = fileparts(varargin{1});
    end
    set(handles.editFilename, 'string', fname);
end

% Set export format popup menu
set(handles.popupmenuExportFormat, 'string', exportvar.formatchoices);
k = 1;
if length(varargin)>1
    if ~isempty(varargin{2})
        k = find(strcmp(exportvar.formatchoices, varargin{2})==1);
    end
    if isempty(k)
        k = 1;
    end
end
set(handles.popupmenuExportFormat, 'value', k);

% Set data type popup menu
set(handles.popupmenuDataType, 'string', exportvar.datatypechoices);
k = 1;
if length(varargin)>2
    if ~isempty(varargin{3})
        k = find(strcmp(exportvar.datatypechoices, varargin{3})==1);
    end 
    if isempty(k)
        k = 1;
    end
end
set(handles.popupmenuDataType, 'value', k);

% Set time range edit boxes
set(handles.editTimeRangeMin, 'string', '-2');
set(handles.editTimeRangeMax, 'string', '20');

% Set processing elements to export radio buttons 
set(handles.radiobuttonCurrProcElemOnly, 'value', 1);
set(handles.radiobuttonCurrProcElemAndSubTree, 'value', 0);

popupmenuDataType_Callback(handles.popupmenuDataType, [], handles)

UpdateOutput(handles);
SetLoadPlotPanelVisible(handles, 'off')

handles.output = hObject;
guidata(hObject, handles);

% UIWAIT makes ExportDataGUI wait for user response (see UIRESUME)
uiwait(handles.figure);



% ----------------------------------------------------------------
function varargout = ExportDataGUI_OutputFcn(~, ~, ~) 
global exportvar
varargout{1} = exportvar;



% ----------------------------------------------------------------
function figure_DeleteFcn(~, ~, ~)



% ----------------------------------------------------------------
function popupmenuDataType_Callback(hObject, ~, handles)
UpdateOutput(handles)
choices = get(hObject, 'string');
idx = get(hObject, 'value');
if isempty(choices)
    return;
end
if idx<1
    return;
end
if isempty(strfind(choices{idx}, 'mean'))
    val = 'off';
else
    val = 'on';
end
set(handles.editTimeRangeMin, 'visible',val);
set(handles.editTimeRangeMax, 'visible',val);
set(handles.textTimeRange, 'visible',val);
set(handles.textTimeRangeMin, 'visible',val);
set(handles.textTimeRangeMax, 'visible',val);



% ----------------------------------------------------------------
function editTimeRangeMin_Callback(~, ~, handles) %#ok<*DEFNU>
UpdateOutput(handles)


% ----------------------------------------------------------------
function editTimeRangeMax_Callback(~, ~, handles)
UpdateOutput(handles)


% ----------------------------------------------------------------
function editFilename_Callback(~, ~, handles)
UpdateOutput(handles)


% ----------------------------------------------------------------
function popupmenuExportFormat_Callback(~, ~, handles)
UpdateOutput(handles)


% ----------------------------------------------------------------
function pushbuttonExport_Callback(~, ~, handles)
global exportvar
if isfield(exportvar, 'hFigPlot')
    if ishandle(exportvar.hFigPlot)
        delete(exportvar.hFigPlot)
    end
end
delete(handles.figure)


% ----------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
InitOutput();
delete(handles.figure)


% ----------------------------------------------------------------
function radiobuttonCurrProcElemOnly_Callback(hObject, ~, handles)
if get(hObject,'value')
    set(handles.radiobuttonCurrProcElemAndSubTree, 'value', 0);
else
    set(handles.radiobuttonCurrProcElemAndSubTree, 'value', 1);
end
UpdateOutput(handles);


% ----------------------------------------------------------------
function radiobuttonCurrProcElemAndSubTree_Callback(hObject, ~, handles)
if get(hObject,'value')
    set(handles.radiobuttonCurrProcElemOnly, 'value', 0);
else
    set(handles.radiobuttonCurrProcElemOnly, 'value', 1);
end
UpdateOutput(handles)


% ----------------------------------------------------------------
function figure_CloseRequestFcn(hObject, ~, ~)
InitOutput();
delete(hObject);


% ----------------------------------------------------------------
function pushbuttonPlot_Callback(~, ~, handles)
global exportvar
global maingui
global logger
logger = InitLogger(logger);

str = get(handles.editChannels, 'string');
iCh = str2num(str);
if length(iCh) > 6
    MenuBox('Number of channels to plot exceeds maximum of 6','OK');
    return
end
if isempty(iCh)
    return
end
fnameExport = maingui.dataTree.currElem.ExportHRF_GetFilename();
fname = maingui.dataTree.currElem.GetName();
if ispathvalid(fnameExport) && GetFileSize(fnameExport)>0
    logger.Write('Loading %s\n', fnameExport);
    fid = fopen(fnameExport, 'rt');
    d = [];
    tt = 1;
    while 1
        l = fgetl(fid);
        if l == -1
            break
        end
        if tt>2
            d(tt,:) = str2num(l); %#ok<*AGROW>
        end
        tt = tt+1;
    end
    fclose(fid);
    t = d(:,1);
    d = d(:,2:end);

    if max(iCh)>size(d,2)
        return
    end
    if min(iCh)<1
        return
    end    
    if ishandle(exportvar.hFigPlot)
        delete(exportvar.hFigPlot)
    end
    exportvar.hFigPlot = figure('name',sprintf('%s channel [%s] data plot :', fname, num2str(iCh)), ...
        'toolbar','none', 'menubar','none', 'NumberTitle','off'); 
    h = plot(t, d(:,iCh));
    ha = get(h(1), 'parent');
    set(ha, 'xlim',[t(1), t(end)])
    PositionFigures(exportvar.hFigPlot, handles.figure);
else
    logger.Write('The export file for %s has not been generated yet.\n', fname);
end




% ----------------------------------------------------------------
function checkboxLoad_Callback(hObject, ~, handles)
val = get(hObject, 'value');
if val==1
    SetLoadPlotPanelVisible(handles, 'on')
else
    SetLoadPlotPanelVisible(handles, 'off')
end



% ----------------------------------------------------------------
function editChannels_Callback(~, ~, ~)



% ----------------------------------------------------------------
function SetLoadPlotPanelVisible(handles, onoff)
if ~exist('onoff', 'var')
    onoff = 'off';
end
if strcmp(onoff, 'on')
    enable = 'off';
else
    enable = 'on';
end
set(handles.uipanelLoadPlot, 'visible', onoff);
set(handles.pushbuttonPlot, 'visible', onoff);
set(handles.popupmenuExportFormat,  'enable', enable);
set(handles.editTimeRangeMin,  'enable', enable);
set(handles.editTimeRangeMax,  'enable', enable);
set(handles.textTimeRange,  'enable', enable);
set(handles.textExportFormat,  'enable', enable);
set(handles.textDataType,  'enable', enable);
set(handles.popupmenuDataType,  'enable', enable);
set(handles.editFilename, 'enable', enable);
set(handles.textFilename, 'enable', enable);
if strcmp(enable, 'off')
    set(handles.popupmenuDataType, 'value',1);
end



% -------------------------------------------------------------------
function PositionFigures(hc, hp)

% Get initial units of parent and child guis
us0 = get(0, 'units');
up0 = get(hc, 'units');
uc0 = get(hc, 'units');

% Normalize units of parent and child guis
set(0,'units','normalized');
set(hp, 'units', 'normalized');
set(hc, 'units', 'normalized');

% Get positions of parent and child guis
% Set screen units to be same as GUI
ps = get(0,'MonitorPositions');
pp = get(hp, 'position');
pc = get(hc, 'position');

% To work correctly for mutiple sceens, Ps must be sorted in ascending order
ps = sort(ps,'ascend');

% Find which monitor parent gui is in
for ii = 1:size(ps,1)
    if (pp(1)+pp(3)/2) < (ps(ii,1)+ps(ii,3))
        break;
    end
end

% Fix bug: if multiple monitors left-to-right physical arrangement does
% not match left-to-right virtual setting then subtract 1 from monitor number.
if ps(1)<0
    ii = ii-1;
end

% Re-position parent and child guis
set(hp, 'position', [ii-pp(3), pp(2), pp(3), pp(4)])
set(hc, 'position', [ii-1, pc(2), pc(3), pc(4)])


% Reset parent and child guis' units
set(0, 'units', us0);
set(hp, 'units', up0);
set(hc, 'units', uc0);
