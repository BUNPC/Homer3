function varargout = PvaluesDisplayGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PvaluesDisplayGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PvaluesDisplayGUI_OutputFcn, ...
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



% ----------------------------------------------------------------------
function ParseArgs(args)
global pvaluesgui
global maingui

if ~exist('args','var')
    return;
end

varargin = args;

%%%% These are the parameters that are assigned from external soutrces,
%%%% either from GUI arguments or parent GUI. 
%
% pvaluesgui.groupDirs
% pvaluesgui.format
% pvaluesgui.pos
%

%  Syntax:
%
%     PvaluesDisplayGUI()
%     PvaluesDisplayGUI(groupDirs)
%     PvaluesDisplayGUI(groupDirs, format)
%     PvaluesDisplayGUI(groupDirs, format, pos)

% Arguments take precedence over parent gui parameters
if length(varargin)==0
    return;                                                 % PvaluesDisplayGUI()
elseif length(varargin)==1
    pvaluesgui.groupDirs = varargin{1};                     % PvaluesDisplayGUI(groupDirs)
elseif length(varargin)==2
    pvaluesgui.groupDirs = varargin{1};
    pvaluesgui.format = varargin{2};                        % PvaluesDisplayGUI(groupDirs, format)
elseif length(varargin)==2
    pvaluesgui.groupDirs = varargin{1};
    pvaluesgui.format = varargin{2};
    pvaluesgui.pos = varargin{3};                           % PvaluesDisplayGUI(groupDirs, format, pos)
end

% Now whichever of the above parameters weren't assigned values
% obtain values either from parent gui or assign default value
if isempty(maingui)
    if isempty(pvaluesgui.groupDirs)
        pvaluesgui.groupDirs = convertToStandardPath({pwd});
    end
    if isempty(pvaluesgui.format)
        pvaluesgui.format = 'snirf';
    end
 else
    if isempty(pvaluesgui.groupDirs)
        pvaluesgui.groupDirs = maingui.groupDirs;
    end
    if isempty(pvaluesgui.format)
        pvaluesgui.format = maingui.format;
    end
end



% --------------------------------------------------------------------------
function PvaluesDisplayGUI_OpeningFcn(hObject, eventdata, handles, varargin)
global pvaluesgui
global maingui

handles.output = hObject;
guidata(hObject, handles);

pvaluesgui = [];
pvaluesgui.status = -1;

% These are the parameters that are assigned from external sources,
% either from GUI arguments or parent GUI. 
pvaluesgui.groupDirs = {};
pvaluesgui.format = '';
pvaluesgui.pos = [];

% Parse GUI args
ParseArgs(varargin);

p = pvaluesgui.pos;
if ~isempty(p)
    set(hObject, 'position', [p(1), p(2), p(3), p(4)]);
end
pvaluesgui.version  = get(hObject, 'name');
pvaluesgui.dataTree = LoadDataTree(pwd, pvaluesgui.format, '', maingui);
if pvaluesgui.dataTree.IsEmpty()
    return;
end
Display(handles);



% --------------------------------------------------------------------------
function varargout = PvaluesDisplayGUI_OutputFcn(hObject, eventdata, handles) 
handles.updateptr = @Display;
handles.closeptr = @PvaluesDisplayGUI_Close;
varargout{1} = handles;



% ----------------------------------------------------------------------------------
function Display(handles)
global pvaluesgui

figure(handles.figure);
set(handles.uitablePvalues, 'data', [])
set(handles.textCurrElemName, 'string',pvaluesgui.dataTree.currElem.GetName())

pValues = pvaluesgui.dataTree.currElem.GetPvalues();
if isempty(pValues)
    return;
end
for iBlk=1:length(pValues)
    fprintf('P-Values for %s, data block %d:\n', pvaluesgui.dataTree.currElem.GetName(), iBlk);
    pretty_print_matrix(pValues{iBlk});
end
set(handles.uitablePvalues, 'data',pValues{iBlk})



% ----------------------------------------------------------------------------------
function PvaluesDisplayGUI_Close(handles)
if nargin==0
    return;
end
if ishandles(handles.figure)
    delete(handles.figure);
end


% ----------------------------------------------------------------------------------
function pushbuttonExit_Callback(hObject, eventdata, handles)
PvaluesDisplayGUI_Close(handles)
