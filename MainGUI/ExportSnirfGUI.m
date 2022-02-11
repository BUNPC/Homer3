function varargout = ExportSnirfGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ExportSnirfGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ExportSnirfGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


function ExportSnirfGUI_OpeningFcn(hObject, eventdata, handles, varargin)

if ~any([isa(varargin{1}, 'RunClass'), isa(varargin{1}, 'SubjClass'), isa(varargin{1}, 'SessClass'), isa(varargin{1}, 'GroupClass')])
    close(handles.exportSnirfGUI)
else
   handles.currElem = varargin{1};
end
    
handles.textElementName.String = handles.currElem.name;

[handles.dataKeys, handles.dataValues] = handles.currElem.procStream.output.GetAllData();

set(handles.listboxSelectData, 'String', handles.dataKeys);
set(handles.listboxSelectData, 'Max', length(handles.dataKeys));  % Enable multiple selection

handles.output = hObject;
guidata(hObject, handles);

% uiwait(handles.exportSnirfGUI);


% --- Outputs from this function are returned to the command line.
function varargout = ExportSnirfGUI_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function buttonSave_Callback(hObject, eventdata, handles)
selected = handles.listboxSelectData.Value;
data = handles.dataValues(selected);

% Prepare exported Snirf file
output = SnirfClass();
output.data = horzcat(data{:});
output.metaDataTags = MetaDataTagsClass();  % Generate default mdt
output.probe = handles.currElem.GetProbe();

name = handles.currElem.name;
name(name == '/') = '_';
name(name == '\') = '_';
name = erase(name, '.snirf');

if length(selected) < 1
    return
elseif length(selected) == 1
    suffix = handles.dataKeys{selected};
else
    suffix = 'exp';
end
[file, path, indx] = uiputfile(['homerOutput/', name, '_', suffix, '.snirf']);
if file ~= 0
    wb = waitbar(0.2, string(['Saving to ', file, ', please wait...']));
    output.Save([path, file]);
    waitbar(0.8, wb);
    close(wb);
    close(handles.exportSnirfGUI)
else
    close(handles.exportSnirfGUI)
end


function buttonCancel_Callback(hObject, eventdata, handles)
close(handles.exportSnirfGUI)
