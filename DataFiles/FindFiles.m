function [files, dirnameGroup] = FindFiles(varargin)

% Syntax:
%
%    [files, dirnameGroup] = FindFiles()
%    [files, dirnameGroup] = FindFiles(handles)
%    [files, dirnameGroup] = FindFiles(handles, fmt);
%    [files, dirnameGroup] = FindFiles(handles, fmt, dirnameGroup);
%    [files, dirnameGroup] = FindFiles(fmt)
%    [files, dirnameGroup] = FindFiles(fmt, dirnameGroup)
%    [files, dirnameGroup] = FindFiles(fmt, dirnameGroup, handles)
% 
% Descrition:
%
%    Find all files of format fmt, in the current folder. 
% 
% Examples: 
%
%    Call FindFiles standalone
% 
%      files = FindFiles([], '.nirs', 'c:\users\public\group');
%      files = FindFiles([], '.snirf');
%
%    Call FindFiles in a GUI context: 
%
%      files = FindFiles(handles, '.nirs');
%      files = FindFiles(handles, '.snirf');


global hmr

%%%% Parse arguments

% First get all the argument there are to get using the 7 possible syntax
% calls 
if nargin==1
    if isstruct(varargin{1})
        handles = varargin{1};
    else
        fmt = varargin{1};
    end
elseif nargin==2
    if isstruct(varargin{1})
        handles = varargin{1};
        fmt = varargin{2};
    else
        fmt = varargin{1};
        dirnameGroup = varargin{2};
    end
elseif nargin==3
    if isstruct(varargin{1})
        handles = varargin{1};
        fmt = varargin{2};
        dirnameGroup = varargin{2};
    else
        fmt = varargin{1};
        dirnameGroup = varargin{2};
        handles = varargin{3};
    end
end

% Decide what to assign for missing arguments
if ~exist('handles','var') || isempty(handles)
    handles = [];
end
if ~exist('fmt','var')
    if ~isempty(hmr) && isstruct(hmr) && isfield(hmr,'format')
        fmt = hmr.format;
    else
        fmt = 'nirs';
    end
end
if ~exist('dirnameGroup','var') || isempty(dirnameGroup)
    dirnameGroup = pwd;
end


% Check files data set for errors. If there are no valid
% nirs files don't attempt to load them.
files = [];
while ~isobject(files) || isempty(files)
    cd(dirnameGroup)
    switch fmt
        case {'snirf','.snirf'}
            files = SnirfFilesClass(handles).files;
        case {'nirs','.nirs'}
            files = NirsFilesClass(handles).files;
        otherwise
            q = menu('Homer3 only supports .snirf and .nirs file formats. Please choose one.', '.snirf', '.nirs', 'CANCEL');
            if q==3
                return;
            elseif q==2
                fmt = 'nirs';
            else
                fmt = 'snirf';
            end
            continue;
    end
    if isempty(files)
        msg{1} = sprintf('Homer3 did not find any %s data files to load in the current group folder. ', fmt);
        msg{2} = sprintf('Do you want to select another group folder?');
        q = menu([msg{:}],'YES','NO');
        if q==2
            return;
        end
        dirnameGroup = uigetdir(pwd, 'Please select another group folder ...');
        if dirnameGroup==0
            return;
        end
    end
end

if isempty(files)
    files = NirsFilesClass(handles).files;
    if isempty(files)
        return;
    end
    Nirs2Snirf();
    files = SnirfFilesClass(handles).files;
end

