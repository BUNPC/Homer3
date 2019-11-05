function varargout = finishInstallGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @finishInstallGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @finishInstallGUI_OutputFcn, ...
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



% ---------------------------------------------------------------------------
function msgFailure(errnum)
global stats

handles = stats.handles;

stats.err = errnum;

msgFail{1}    = sprintf('Homer3 failed to install properly. Error code %d', stats.err);
msgFail{2}    = 'Contact jdubb@bu.edu for help with installation.';

hGui         = handles.this;
hMsgFinished = handles.msgFinished;
hMsgMoreInfo = handles.msgMoreInfo;

set(hGui, 'name','Installation Error:');
set(hMsgFinished,'string', msgFail{1});
set(hMsgMoreInfo,'string', msgFail{2});

fd = fopen([stats.dirnameApp, '.finished'], 'w');
fprintf(fd, '%d', stats.err);
fclose(fd);



% ---------------------------------------------------------------------------
function msgSuccess()
global stats

handles = stats.handles;

msgSuccess{1} = 'Installation Completed Successfully!';
if ispc()
    msgSuccess{2} = 'To run: Click on the Homer3 icon on your Desktop to launch one of these applications';
elseif islinux()
    msgSuccess{2} = 'To run: Click on the Homer3.sh icon on your Desktop to launch one of these applications';
elseif ismac()
    msgSuccess{2} = 'To run: Click on the Homer3.command icon on your Desktop to launch one of these applications';
end

hGui         = handles.this;
hMsgFinished = handles.msgFinished;
hMsgMoreInfo = handles.msgMoreInfo;

set(handles.this, 'name','SUCCESS:');
set(handles.msgFinished,'string', msgSuccess{1}, 'fontsize',14);
set(handles.msgMoreInfo,'string', msgSuccess{2}, 'fontsize',14);

fd = fopen([stats.dirnameApp, '.finished'], 'w');
fprintf(fd, '%d', stats.err);
fclose(fd);


% ---------------------------------------------------------------------------
function finishInstallGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global stats

handles.output = hObject;
guidata(hObject, handles);

stats.err = 0;
stats.handles.this = hObject;
stats.handles.msgFinished = handles.textFinished;
stats.handles.msgMoreInfo = handles.textMoreInfo;
stats.dirnameApp = getAppDir('isdeployed');
stats.pushbuttonOKPress = false;
stats.Homer3_exe_flag = false;

fprintf('FinishInstallGUI_OpeningFcn: dirnameApp = %s\n', stats.dirnameApp);

% Error checks
if stats.dirnameApp==0
    msgFailure(1);
end

if isempty(stats.dirnameApp)
    msgFailure(2);
end

files = dir([stats.dirnameApp, '/*']);
if isempty(files)
    msgFailure(3);
end

for ii=1:length(files)
    [~, fname] = fileparts(files(ii).name);
    if strcmp(fname, 'Homer3')
        stats.Homer3_exe_flag = true;
        break;
    end
end

if stats.Homer3_exe_flag==false
    msgFailure(4);
end

if stats.err==0
msgSuccess();
end





% ---------------------------------------------------------------------------
function varargout = finishInstallGUI_OutputFcn(hObject, eventdata, handles) 
global stats

varargout{1} = stats.err;


% ---------------------------------------------------------------------------
function pushbuttonOK_Callback(hObject, eventdata, handles)
global stats

stats.pushbuttonOKPress = true;

delete(stats.handles.this);
