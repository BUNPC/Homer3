function dataTree = LoadDataTree(varargin)

% Syntax:
%
%       dataTree = LoadDataTree()
%       dataTree = LoadDataTree(groupDirs)
%       dataTree = LoadDataTree(groupDirs, fmt)
%       dataTree = LoadDataTree(groupDirs, fmt, procStreamCfgFile)
%       dataTree = LoadDataTree(groupDirs, fmt, procStreamCfgFile, parent)
%
% Description:
%       
%       This function is (or will be) used by all the Homer3 GUIs 
%       (e.g., ProcStreamGUI, PlotProbeGUI, StimEditGUI, and ofcourse 
%       Homer3 GUI itself) to load the primary Homer3 data class object, 
%       dataTree, containing group, subject and run data. 
%       


% First get all the argument there are to get using the 5 possible syntax
% calls 
if     nargin==0
    groupDirs{1}        = pwd;
    fmt                 = '';
    procStreamCfgFile   = '';
    parent              = [];
elseif nargin==1
    groupDirs           = varargin{1};
    fmt                 = '';
    procStreamCfgFile   = '';
    parent              = []';
elseif nargin==2
    groupDirs           = varargin{1};
    fmt                 = varargin{2};
    procStreamCfgFile   = '';
    parent              = []';
elseif nargin==3
    groupDirs           = varargin{1};
    fmt                 = varargin{2};
    procStreamCfgFile   = varargin{3};
    parent              = []';
elseif nargin==4
    groupDirs           = varargin{1};
    fmt                 = varargin{2};
    procStreamCfgFile   = varargin{3};
    parent              = varargin{4};
end

if isempty(parent) || ~isproperty(parent, 'dataTree') || isempty(parent.dataTree)
    dataTree = DataTreeClass(groupDirs, fmt, procStreamCfgFile);
else
    dataTree = parent.dataTree;
end

