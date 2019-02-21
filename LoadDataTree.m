function dataTree = LoadDataTree(varargin)

% Syntax:
%
%       dataTree = LoadDataTree()
%       dataTree = LoadDataTree(fmt)
%       dataTree = LoadDataTree(fmt, cfgfilename)
%       dataTree = LoadDataTree(fmt, cfgfilename, parent)
%
% Description:
%       
%       This function is (or will be) used by all the Homer3 GUIs 
%       (e.g., ProcStreamGUI, PlotProbeGUI, StimEditGUI, and ofcourse 
%       Homer3 GUI itself) to load the primary Homer3 data class object, 
%       dataTree, containing group, subject and run data. 
%       


% First get all the argument there are to get using the 7 possible syntax
% calls 
if nargin==0
    fmt          = '';
    cfgfilename  = '';
    parent       = [];
elseif nargin==1
    fmt          = varargin{1};
    cfgfilename  = '';
    parent       = []';
elseif nargin==2
    fmt          = varargin{1};
    cfgfilename  = varargin{2};
    parent       = []';
elseif nargin==3
    fmt          = varargin{1};
    cfgfilename  = varargin{2};
    parent       = varargin{3};
end

if isempty(parent) || ~isproperty(parent, 'dataTree') || isempty(parent.dataTree)
    dataTree = DataTreeClass(fmt, cfgfilename);
else
    dataTree = parent.dataTree;
end

