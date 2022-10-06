function varargout = OpenFileGUI(varargin)
% Syntax:
%
%       filepath = OpenFileGUI(fileWildcard, initialFolder, title)
%
%
% Examples:
%       
%       r = OpenFileGUI('', pwd, 'diagnostics')
%
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OpenFileGUI_OpeningFcn, ...
    'gui_OutputFcn',  @OpenFileGUI_OutputFcn, ...
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
global OpenFile

% Init all parameters whose value can be obtained from args
OpenFile.filenameIn = '';
OpenFile.rootpath = filesepStandard(pwd);
OpenFile.title = '';
OpenFile.ext = '';
OpenFile.filenameOut = '';

% Extract all available arg values
nargin = length(args);
if nargin == 1
    if ~isempty(args{1}) && ispathvalid([OpenFile.rootpath, filesepStandard(args{1})])
        OpenFile.filenameIn     = args{1};
    end
elseif nargin == 2
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        OpenFile.rootpath       = filesepStandard(args{2}, 'full');
    end
    if ~isempty(args{1}) && ispathvalid([OpenFile.rootpath, filesepStandard(args{1})])
        OpenFile.filenameIn     = args{1};
    end
elseif nargin == 3
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        OpenFile.rootpath       = filesepStandard(args{2}, 'full');
    end
    if ~isempty(args{1}) && ispathvalid([OpenFile.rootpath, filesepStandard(args{1})])
        OpenFile.filenameIn     = args{1};
    end
    OpenFile.title          = args{3};
elseif nargin == 4
    if args{4}(1) == '*'
        args{4}(1) = '';
    end
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        OpenFile.rootpath       = filesepStandard(args{2}, 'full');
    end
    if ~isempty(args{1}) && ispathvalid([OpenFile.rootpath, filesepStandard(args{1})])
        OpenFile.filenameIn     = args{1};
    end
    OpenFile.title          = args{3};
    OpenFile.ext           = args{4};
elseif nargin == 5
    if args{4}(1) == '*'
        args{4}(1) = '';
    end
    if ~isempty(args{2}) && ispathvalid(filesepStandard(args{2}, 'full'))
        OpenFile.rootpath       = filesepStandard(args{2}, 'full');
    end
    if ~isempty(args{1}) && ispathvalid([OpenFile.rootpath, filesepStandard(args{1})])
        OpenFile.filenameIn     = args{1};
    end
    OpenFile.title          = args{3};
    OpenFile.ext        = args{4};
    OpenFile.filenameOut    = args{5};
end



% ------------------------------------------------------------------------
function GenerateFolderList()
global OpenFile
files = dir([OpenFile.rootpath, '*']);
filenames = {};
dirnames = {};
kk = 1;
mm = 1;
for ii = 1:length(files)
    if strcmp(files(ii).name, '.')
        continue;
    end
    
    % Show only files which match extension filter
    if ispathvalid([OpenFile.rootpath, files(ii).name], 'file')
        if ~isempty(OpenFile.ext)
            if ~strcmp(OpenFile.ext, '.*')
                [~, ~, ext] = fileparts(files(ii).name);
                if ~strcmp(ext, OpenFile.ext)
                    continue;
                end
            end
        end
        filenames{kk,1} = files(ii).name;  %#ok<*AGROW>
        kk = kk+1;
    elseif ispathvalid([OpenFile.rootpath, files(ii).name], 'dir')
        dirnames{mm,1} = [files(ii).name, '/'];  %#ok<*AGROW>
        mm = mm+1;
    end
end
OpenFile.filesCurrFolder = [dirnames; filenames];



% ------------------------------------------------------------------------
function b = UsePlatformWindow()
global OpenFile

b = false;
if ~ismac() && ~strcmp(OpenFile.title, 'diagnostics')
    % This pause is a workaround for a matlab bug in version
    % 7.11 for Linux, where uigetfile won't block unless there's
    % a breakpoint.
    pause(.1);
    [fname, pname] = uigetfile([OpenFile.rootpath, '*.cfg'], OpenFile.title);
    if fname ~= 0
        OpenFile.rootpath = filesepStandard(pname);
        OpenFile.filenameOut = fname;
    end
    b = true;
end




% ------------------------------------------------------------------------
function OpenFileGUI_OpeningFcn(hObject, ~, handles, varargin)
global OpenFile
OpenFile = [];

ParseArgs(varargin);

if UsePlatformWindow()
    close(hObject)
    return;
end

GenerateFolderList();

handles.output = hObject;
guidata(hObject, handles);

set(handles.editFilename, 'string',sprintf('%s', OpenFile.filenameIn));
set(handles.listboxFilesFolders, 'string',OpenFile.filesCurrFolder);
idx = find(strcmp(OpenFile.filesCurrFolder, OpenFile.filenameIn));
if isempty(idx)
    set(handles.listboxFilesFolders, 'value',1);
else
    set(handles.listboxFilesFolders, 'value',idx);
end
set(handles.editRootpath, 'string',filesepStandard(OpenFile.rootpath, 'filesepwide'));
editFilename_Callback(handles.editFilename, 1, handles);


if ~isempty(OpenFile.title)
    set(handles.figure1, 'name',OpenFile.title);
end

if ismac() 
    fs = 14;
else
    fs = 11;
end
setGuiFonts(hObject, fs)

% Set focus on file name edit box
% uicontrol(handles.editFilename);
uicontrol(handles.listboxFilesFolders);
waitForGui(hObject, true);




% ------------------------------------------------------------------------
function varargout = OpenFileGUI_OutputFcn(~, ~, ~)
global OpenFile
if isempty(OpenFile.filenameOut)
    varargout{1} = '';
else
    varargout{1} = [filesepStandard(OpenFile.rootpath), OpenFile.filenameOut];
end



% ------------------------------------------------------------------------
function editFilename_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
global OpenFile
if ~ishandles(hObject)
    return
end
if iswholenum(eventdata) && eventdata==1
    idx = get(handles.listboxFilesFolders, 'value');
    filenames = get(handles.listboxFilesFolders, 'string');
    set(hObject, 'string',filenames{idx});    
end

f = get(hObject, 'string');
if ~ispathvalid([OpenFile.rootpath, f], 'file')
    if  isobject(eventdata)
        msgbox('The selected file does not exist in the current folder. Choose another file.');
    end
    set(hObject, 'string','');
    OpenFile.filenameOut = '';
else
    OpenFile.filenameOut = f;
end


% ------------------------------------------------------------------------
function listboxFilesFolders_Callback(hObject, eventdata, handles)
global OpenFile %#ok<*GVMIS>

keypress = getappdata(hObject, 'keypress');
if isempty(keypress)
    setappdata(hObject, 'keypress',0)
elseif keypress == 1
    setappdata(hObject, 'keypress',0)
    return
else
    setappdata(hObject, 'keypress',0)
end

idx = get(hObject, 'value');
filenames = get(hObject, 'string');
if isempty(filenames)
    return;
end

mouseevent = get(get(hObject,'parent'),'selectiontype'); 

if ispathvalid([OpenFile.rootpath, filenames{idx}], 'dir')
    currdir = pwd;
    cd([OpenFile.rootpath, filenames{idx}])
    OpenFile.rootpath = filesepStandard(pwd);
    set(handles.editRootpath, 'string',filesepStandard(OpenFile.rootpath, 'filesepwide'));
    GenerateFolderList();
    set(hObject, 'string',OpenFile.filesCurrFolder)
    set(hObject, 'value',1);
    cd(currdir)
elseif strcmp(mouseevent, 'open')
    set(handles.editFilename, 'string',filenames{idx});
    pushbuttonOpen_Callback(hObject, eventdata, handles)
end
editFilename_Callback(handles.editFilename, 1, handles);




% ------------------------------------------------------------------------
function editRootpath_Callback(hObject, ~, handles)
global OpenFile
p = get(hObject, 'string');
pp = str2cell(p, {'/', '\'});
OpenFile.rootpath = buildpathfrompathparts(pp);
if ispathvalid(OpenFile.rootpath, 'dir')
    currdir = pwd;
    cd(OpenFile.rootpath)
    GenerateFolderList();
    set(handles.listboxFilesFolders, 'string',OpenFile.filesCurrFolder)
    set(handles.listboxFilesFolders, 'value',1);
    cd(currdir)
end
editFilename_Callback(handles.editFilename, 1, handles);





% ------------------------------------------------------------------------
function pushbuttonOpen_Callback(~, ~, handles)
global OpenFile
f = get(handles.editFilename, 'string');
if ~ispathvalid([OpenFile.rootpath, f], 'file')
    msgbox('No file selected. Please choose a file or ckicl Cancel to exit GUI.');
    return;
end
close(handles.figure1);



% ------------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
global OpenFile
OpenFile.rootpath = '';
OpenFile.filenameOut = '';
close(handles.figure1);



% ------------------------------------------------------------------------
function dummyfunc(~, ~, ~)


% ------------------------------------------------------------------------
function listboxFilesFolders_KeyPressFcn(hObject, eventdata, handles)
if strcmp(eventdata.Key, 'downarrow') || strcmp(eventdata.Key, 'uparrow')
    setappdata(hObject, 'keypress',1)
elseif strcmp(eventdata.Key, 'home') || strcmp(eventdata.Key, 'end')
    setappdata(hObject, 'keypress',1)
elseif strcmp(eventdata.Key, 'return')
    editFilename_Callback(handles.editFilename, 1, handles);
end


