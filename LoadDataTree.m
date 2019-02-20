function dataTree = LoadDataTree(varargin)

% Syntax:
%
%       dataTree = LoadDataTree()
%       dataTree = LoadDataTree(fmt)
%       dataTree = LoadDataTree(fmt, parent)
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
if nargin==1
    fmt     = varargin{1};
elseif nargin==2
    fmt     = varargin{1};
    parent  = varargin{2};
end

% Instantiate any non-existent arguments 
if ~exist('fmt','var')
    fmt = '';
end
if ~exist('parent','var')
    parent = []';
end
if isempty(parent) || ~isproperty(parent, 'dataTree') || isempty(parent.dataTree)
    dataTree = DataTreeClass(fmt, parent);
else
    dataTree = parent.dataTree;
end

