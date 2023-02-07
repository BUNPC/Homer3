function files = FindFiles(varargin)

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
elseif nargin==3
    dirnameGroup = varargin{1};
    fmt = varargin{2};
    options = varargin{3};
    if optionExists(options, 'oneformat')
        fmt = [fmt, 'only'];
    end
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
while files.IsEmpty()
    switch fmt
        case {'snirf','.snirf'}
            files = DataFilesClass(dirnameGroup, 'snirf');
            filesSrc = DataFilesClass(dirnameGroup, 'nirs', '', false);
            if ~filesSrc.IsEmpty()
                nfolders = length(filesSrc.files)-filesSrc.nfiles;
                if nfolders==0
                    nfolders = 1;
                end
            end
            
            % Search for source acquisition files in .nirs format which have not
            % been converted to .snirf. 
            found = files.ConvertedFrom(filesSrc);
            if ~all(found)
                q = GetOptionsForIncompleteDataSet(files, filesSrc);
                if q==2
                    if files.IsEmpty()
                        files = [];
                    end
                    return;
                end
                Nirs2Snirf(dirnameGroup, filesSrc.files(~found));
                files = DataFilesClass(dirnameGroup, 'snirf');
            end
        case {'snirfonly'}
            files = DataFilesClass(dirnameGroup, 'snirf');
            if files.IsEmpty()
                files = [];
                return;
            end
        case {'nirs','.nirs'}
            files = DataFilesClass(dirnameGroup, 'nirs');
        otherwise
            q = MenuBox(sprintf('Homer3 only supports file formats: {%s}. Please choose one.', cell2str(supportedFormats(:,1))), ...
                    {'OK','CANCEL'}); 
            if q==2
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
    
    
    % If no files were found ion the current format then ask user to choose
    % another group folder
    if files.IsEmpty()
        if strcmp(fmt, 'snirfonly')
            files = [];
            return
        end
        
        msg{1} = sprintf('Homer3 did not find any %s data files to load in the current group folder. ', fmt);
        msg{2} = sprintf('Do you want to select another group folder?');
        q = MenuBox(msg, {'YES','NO'});
        if q==2
            return;
        end
        dirnameGroup = uigetdir(pwd, 'Please select another group folder ...');
        if dirnameGroup==0
            files = DataFilesClass(pwd, fmt);
            return;
        end
        
        % Change current folder to new group
        cd(dirnameGroup)
    end
    
end



% ----------------------------------------------------------------------------
function  q = GetOptionsForIncompleteDataSet(files, filesSrc)
if files.config.RegressionTestActive
    q = 1;
elseif  files.IsEmpty()
    msg{1} = sprintf('Homer3 did not find any .snirf files in the current folder but did find %d .nirs files. ', filesSrc.nfiles);
    msg{2} = sprintf('Do you want to convert .nirs files to .snirf format and load them?');
    q = MenuBox(msg, {'YES','NO'}, 'center');
else
    if files.nfiles>1
        s = 'have';
    else
        s = 'has';
    end
    if filesSrc.nfiles-files.nfiles>1
        msg{1} = sprintf('Homer3 found %d .nirs files which have not been converted to .snirf format and %d that %s. ', filesSrc.nfiles-files.nfiles, files.nfiles, s);
        msg{2} = sprintf('Do you want to convert the remaining %d .nirs files to .snirf format?', filesSrc.nfiles-files.nfiles);
    else
        msg{1} = sprintf('Homer3 found %d .nirs file which has not been converted to .snirf format and %d that %s. ', filesSrc.nfiles-files.nfiles, files.nfiles, s);
        msg{2} = sprintf('Do you want to convert the remaining .nirs file to .snirf format?');
    end
    q = MenuBox(msg, {'YES','NO'}, 'center');
end


