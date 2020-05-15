function DeleteDataFiles(varargin)

% Syntax:
%
%   DeleteDataFiles()
%   DeleteDataFiles(dirname)
%   DeleteDataFiles(dirname, datafiles0)
%   DeleteDataFiles(dirname, format)
%   DeleteDataFiles(dirname, datafiles0, options)
%   DeleteDataFiles(dirname, format, options)
%
% Description:
%   
%   Delete all .<format extension> files in group folder. DeleteDataFiles will find all 
%   .<format extension> data acquisition files in the group folder. If dirname is not supplied it'll 
%   treat the current working directory as the group folder. 
%
% Examples:
%
%   1. Delete all .snirf files in the Homer3 Examples directory
%
%       DeleteDataFiles('C:\jdubb\workspaces\Homer3\DataTree\AcquiredData\Snirf\Examples', '.snirf')
%
%   2. Delete all .nirs files files in the current group folder
%
%       DeleteDataFiles(pwd, '.nirs)
%
%

global supportedFormats
if isempty(supportedFormats)
    supportedFormats = {
    '.snirf',0;
    '.nirs',0;
    };
end


% Set argument defaults
dirname = convertToStandardPath(pwd);
format = supportedFormats{1};
datafiles0 = [];
options = 'delete';


% Parse arguments
if nargin==1
    dirname = convertToStandardPath(varargin{1});
elseif nargin==2
    dirname = convertToStandardPath(varargin{1});
    if ischar(varargin{2})
        format = varargin{2};
    else
        datafiles0 = varargin{2};
    end
elseif nargin==3
    dirname = convertToStandardPath(varargin{1});
    if ischar(varargin{2})
        format = varargin{2};
    else
        datafiles0 = varargin{2};
    end
    options = varargin{3};
end
if isempty(datafiles0)
    datafiles0 = DataFilesClass(dirname, format, 'standalone').files;
end


% Get final list of data files
datafiles = mydir(dirname);
if iscell(datafiles0)
    for ii=1:length(datafiles0)
        datafiles(ii) = mydir([dirname, datafiles0{ii}]);
    end
elseif ischar(datafiles0)
    datafiles = mydir([dirname, datafiles0]);
elseif isa(datafiles0, 'FileClass')
    datafiles = datafiles0;
end


% Delete data files
for ii=1:length(datafiles)
    if datafiles(ii).isdir
        continue;
    end
    if strcmp(options, 'delete')
        fprintf('Deleting %s\n', [datafiles(ii).pathfull, '/', datafiles(ii).name]);
        delete([datafiles(ii).pathfull, '/', datafiles(ii).name]);
    elseif strcmp(options, 'move')
        fprintf('Moving %s to %s\n', [datafiles(ii).pathfull, '/', datafiles(ii).name], [datafiles(ii).pathfull, '/', datafiles(ii).name, '.old']);
        movefile([datafiles(ii).pathfull, '/', datafiles(ii).name], [datafiles(ii).pathfull, '/', datafiles(ii).name, '.old']);
    elseif strcmp(options, 'restore')
        [pname, fname] = fileparts(datafiles(ii).name);
        fprintf('Restoring %s to %s\n', [datafiles(ii).pathfull, '/', datafiles(ii).name], [datafiles(ii).pathfull, '/', pname, '/', fname]);
        movefile([datafiles(ii).pathfull, '/', datafiles(ii).name], [datafiles(ii).pathfull, '/', pname, '/', fname]);
    end
    pause(0.25);
end

