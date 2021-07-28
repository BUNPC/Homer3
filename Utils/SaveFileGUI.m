function varargout = SaveFileGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @SaveFileGUI_OpeningFcn, ...
    'gui_OutputFcn',  @SaveFileGUI_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1}) && isvalidfuncname(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end



% ------------------------------------------------------------------
function ParseArgs(args)
global savefile

% Init all parameters whose value can be obtained from args
savefile.filenameIn = '';
savefile.rootpath = filesepStandard(pwd);
savefile.title = '';
savefile.mode = 'save';
savefile.filenameOut = '';

% Extract all available arg values
nargin = length(args);
if nargin == 1
    savefile.filenameIn     = args{1};
elseif nargin == 2
    savefile.filenameIn     = args{1};
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        savefile.rootpath       = filesepStandard(args{2}, 'full');
    end
elseif nargin == 3
    savefile.filenameIn     = args{1};
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        savefile.rootpath       = filesepStandard(args{2}, 'full');
    end
    savefile.title          = args{3};
elseif nargin == 4
    savefile.filenameIn     = args{1};
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        savefile.rootpath       = filesepStandard(args{2}, 'full');
    end
    savefile.title          = args{3};
    savefile.mode           = args{4};
elseif nargin == 5
    savefile.filenameIn     = args{1};
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        savefile.rootpath       = filesepStandard(args{2}, 'full');
    end
    savefile.title          = args{3};
    if ~isempty(args{2})
        savefile.mode           = args{4};
    end
    savefile.filenameOut    = args{5};
end

if ~optionExists(savefile.mode, 'save') && ~optionExists(savefile.mode, 'rename')
    savefile.mode = 'save';
end



% ------------------------------------------------------------------------
function GenerateFolderList()
global savefile
files = dir([savefile.rootpath, '*']);
filenames = {};
kk = 1;
for ii = 1:length(files)
    if strcmp(files(ii).name, '.')
        continue;
    end
    if strcmp(files(ii).name, '..')
        continue;
    end
    filenames{kk} = files(ii).name;  %#ok<*AGROW>
    kk = kk+1;
end
savefile.filesCurrFolder = filenames;



% ------------------------------------------------------------------------
function SaveFileGUI_OpeningFcn(hObject, ~, handles, varargin)
global savefile
savefile = [];

ParseArgs(varargin);

GenerateFolderList();

handles.output = hObject;
guidata(hObject, handles);

set(handles.editFilename, 'string',sprintf('%s', savefile.filenameIn));
set(handles.listboxFilesFolders, 'string',savefile.filesCurrFolder);
idx = find(strcmp(savefile.filesCurrFolder, savefile.filenameIn));
if isempty(idx)
    set(handles.listboxFilesFolders, 'value',1);
else
    set(handles.listboxFilesFolders, 'value',idx);
end
set(handles.editRootpath, 'string',sprintf('%s', savefile.rootpath));
editFilename_Callback(handles.editFilename);

if optionExists(savefile.mode, 'rename')
    set(handles.figure1, 'name','Rename File');
    set(handles.pushbuttonSave, 'string','RENAME');
    set(handles.textFilename, 'string', 'Suggested File Name')
end

% Set focus on file name edit box
uicontrol(handles.editFilename);

waitForGui(hObject);



% ------------------------------------------------------------------------
function varargout = SaveFileGUI_OutputFcn(~, ~, ~)
global savefile
varargout{1} = savefile.rootpath;
varargout{2} = savefile.filenameOut;


% ------------------------------------------------------------------------
function editFilename_Callback(hObject, ~, ~) %#ok<*DEFNU>
global savefile
savefile.filenameOut = get(hObject, 'string');


% ------------------------------------------------------------------------
function listboxFilesFolders_Callback(hObject, ~, handles)
global savefile
idx = get(hObject, 'value');
filenames = get(hObject, 'string');
if isempty(filenames)
    return;
end
if strcmp(filenames{idx}, '..')
    savefile.rootpath = fileparts(filesepStandard(savefile.rootpath, 'file'));
    set(handles.editRootpath, 'string',savefile.rootpath);
    GenerateFolderList();
    set(hObject, 'string',savefile.filesCurrFolder)
    set(hObject, 'value',1);
end
set(handles.editFilename, 'string',sprintf('%s', filenames{idx}));
editFilename_Callback(handles.editFilename);



% ------------------------------------------------------------------------
function editRootpath_Callback(hObject, ~, ~)
global savefile
savefile.rootpath = filesepStandard(get(hObject, 'string'));


% ------------------------------------------------------------------------
function pushbuttonSave_Callback(~, ~, handles)
close(handles.figure1);



% ------------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
global savefile
savefile.rootpath = '';
savefile.filenameOut = '';
close(handles.figure1);



% ------------------------------------------------------------------------
function dummyfunc(~, ~, ~)
