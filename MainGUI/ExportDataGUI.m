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

exportvar = [];

% Output data structure
exportvar.pathname = '';
exportvar.filename = '';

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
function pushbuttonSubmit_Callback(~, ~, handles)
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
