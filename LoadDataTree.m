function dataTree = LoadDataTree(varargin)

% Syntax:
%
%       dataTree = LoadDataTree()
%       dataTree = LoadDataTree(fmt)
%       dataTree = LoadDataTree(fmt, parent)
%       dataTree = LoadDataTree(fmt, parent, handles)
%       dataTree = LoadDataTree(fmt, parent, handles, fptr)
%       dataTree = LoadDataTree(handles)
%       dataTree = LoadDataTree(handles, fptr)
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
    if isstruct(varargin{1})
        handles  = varargin{1};
    elseif ischar(varargin{1})
        fmt     = varargin{1};
    end
elseif nargin==2
    if isstruct(varargin{1})
        handles = varargin{1};
        fptr    = varargin{2};
    else
        fmt     = varargin{1};
        parent  = varargin{2};
    end
elseif nargin==3
    fmt     = varargin{1};
    parent  = varargin{2};
    handles = varargin{3};
elseif nargin==4
    fmt     = varargin{1};
    parent  = varargin{2};
    handles = varargin{3};
    fptr    = varargin{4};
end

% Instantiate any non-existent arguments 
if ~exist('fmt','var')
    fmt = '';
end
if ~exist('parent','var')
    parent = []';
end
if ~exist('handles','var')
    handles = [];
end
if ~exist('fptr','var')
    fptr = [];
end

if isempty(parent) || ~isproperty(parent, 'dataTree') || isempty(parent.dataTree)
    dataTree = DataTreeClass(handles, fptr, fmt);
else
    dataTree = parent.dataTree;
end

