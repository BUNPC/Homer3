function [files, dirnameGroup] = FindFiles(varargin)

% Syntax:
%
%    [files, dirnameGroup] = FindFiles()
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
%      files = FindFiles('.nirs', 'c:\users\public\group');
%      files = FindFiles('.snirf');
%
%    Call FindFiles in a GUI context: 
%
%      files = FindFiles('.nirs');
%      files = FindFiles('.snirf');


global maingui
global supportedFormats

supportedFormats = {
    '.snirf',0;
    '.nirs',0;
    };

%%%% Parse arguments

% First get all the argument there are to get using the 7 possible syntax
% calls 
if nargin==1
    fmt = varargin{1};
elseif nargin==2
    fmt = varargin{1};
    dirnameGroup = varargin{2};
elseif nargin==3
    fmt = varargin{1};
    dirnameGroup = varargin{2};
end

if ~exist('fmt','var') || isempty(fmt)
    if ~isempty(maingui) && isstruct(maingui) && isfield(maingui,'format')
        fmt = maingui.format;
    else
        fmt = supportedFormats{1};
    end
end

if ~exist('dirnameGroup','var') || isempty(dirnameGroup)
    dirnameGroup = pwd;
end

% Check files data set for errors. If there are no valid
% nirs files don't attempt to load them.
files = DataFilesClass();
while files.isempty()
    cd(dirnameGroup)
    switch fmt
        case {'snirf','.snirf'}
            files = DataFilesClass('snirf');
            if files.isempty()
                files = DataFilesClass('nirs');
                if ~files.isempty()
                    if files.config.RegressionTestActive
                        q = 1;
                    else                        
                        msg{1} = sprintf('Homer3 did not find any .snirf files in the current folder but did find .nirs files. ');
                        msg{2} = sprintf('Do you want to convert .nirs files to .snirf format and load them?');
                        q = MenuBox([msg{:}], {'YES','NO'}, 'center');
                    end
                    if q==2
                        files = DataFilesClass();
                        return;
                    end
                end
                Nirs2Snirf();
                files = DataFilesClass('snirf');
            end
        case {'nirs','.nirs'}
            files = DataFilesClass('nirs');
        otherwise
            q = menu(sprintf('Homer3 only supports file formats: {%s}. Please choose one.', cell2str(supportedFormats(:,1))), ...
                    'OK','CANCEL');
            if q==2
                files = DataFilesClass();
                return;
            else
                selection = checkboxinputdlg(supportedFormats(:,1), 'Select Supported File Format');
                if isempty(selection)
                    files = DataFilesClass();
                    return;
                end
                fmt = supportedFormats{selection,1};
                continue;
            end
    end
    if files.isempty()
        msg{1} = sprintf('Homer3 did not find any %s data files to load in the current group folder. ', fmt);        
        msg{2} = sprintf('Do you want to select another group folder?');
        q = MenuBox([msg{:}], {'YES','NO'});
        if q==2
            files = DataFilesClass();
            return;
        end
        dirnameGroup = uigetdir(pwd, 'Please select another group folder ...');
        if dirnameGroup==0
            files = DataFilesClass();
            return;
        end
    end
end


