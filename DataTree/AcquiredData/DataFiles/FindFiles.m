function [files, dirnameGroup] = FindFiles(varargin)

% Syntax:
%
%    [files, dirnameGroup] = FindFiles()
%    [files, dirnameGroup] = FindFiles(dirnameGroup)
%    [files, dirnameGroup] = FindFiles(dirnameGroup, fmt)
% 
% Descrition:
%
%    Find all files of format fmt, in the current folder. 
% 
% Examples: 
%
%    files = FindFiles('c:\users\public\group1');
%    files = FindFiles('c:\users\public\group1','.snirf');


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
    dirnameGroup = varargin{1};
elseif nargin==2
    dirnameGroup = varargin{1};
    fmt = varargin{2};
end

if ~exist('dirnameGroup','var') || isempty(dirnameGroup)
    dirnameGroup = pwd;
end

if ~exist('fmt','var') || isempty(fmt)
    if ~isempty(maingui) && isstruct(maingui) && isfield(maingui,'format')
        fmt = maingui.format;
    else
        fmt = supportedFormats{1};
    end
end

% Check files data set for errors. If there are no valid
% nirs files don't attempt to load them.
files = DataFilesClass();
while files.isempty()
    switch fmt
        case {'snirf','.snirf'}
            files = DataFilesClass(dirnameGroup, 'snirf');
            if files.isempty()
                files = DataFilesClass(dirnameGroup, 'nirs');
                if ~files.isempty()
                    if files.config.RegressionTestActive
                        q = 1;
                    else                        
                        msg{1} = sprintf('Homer3 did not find any .snirf files in the current folder but did find .nirs files. ');
                        msg{2} = sprintf('Do you want to convert .nirs files to .snirf format and load them?');
                        q = MenuBox([msg{:}], {'YES','NO'}, 'center');
                    end
                    if q==2
                        files = DataFilesClass(dirnameGroup);
                        return;
                    end
                end
                Nirs2Snirf(dirnameGroup);
                files = DataFilesClass(dirnameGroup, 'snirf');
            end
        case {'nirs','.nirs'}
            files = DataFilesClass(dirnameGroup, 'nirs');
        otherwise
            q = menu(sprintf('Homer3 only supports file formats: {%s}. Please choose one.', cell2str(supportedFormats(:,1))), ...
                    'OK','CANCEL');
            if q==2
                files = DataFilesClass(dirnameGroup);
                return;
            else
                selection = checkboxinputdlg(supportedFormats(:,1), 'Select Supported File Format');
                if isempty(selection)
                    files = DataFilesClass(dirnameGroup);
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


