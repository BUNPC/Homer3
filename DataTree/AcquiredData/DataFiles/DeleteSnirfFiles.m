function DeleteSnirfFiles(dirname, snirffiles0)

% Syntax:
%
%   DeleteSnirfFiles()
%   DeleteSnirfFiles(dirname)
%   DeleteSnirfFiles(dirname, snirffiles0)
%
% Description:
%   
%   Delete all .snirf files in group folder. The group folder is same
%   concept as in Homer3 so DeleteSnirfFiles will find all .snirf data 
%   acquisition files in folder dirname. If dirname is not supplied it'll 
%   treat the current working directory as the group folder. If snirffiles0
%   if supplied it'll delete.
%
% Examples:
%
%   1. Delete all .snirf files in the Homer3 Examples directory
%
%       DeleteSnirfFiles('C:\jdubb\workspaces\Homer3\DataTree\AcquiredData\Snirf\Examples')
%
%   2. Delete all .snirf files in the current group folder
%
%       DeleteSnirfFiles()
%
%

if ~exist('dirname','var')
    dirname = pwd;
end
dirname = convertToStandardPath(dirname);

if ~exist('snirffiles0','var')
    snirffiles0 = DataFilesClass(dirname, '.snirf', 'standalone').files;
end

snirffiles = mydir(dirname);
if iscell(snirffiles0)
    for ii=1:length(snirffiles0)
        snirffiles(ii) = mydir([dirname, snirffiles0{ii}]);
    end
elseif ischar(snirffiles0)
    snirffiles = mydir([dirname, snirffiles0]);
elseif isa(snirffiles0, 'FileClass')
    snirffiles = snirffiles0;
end

for ii=1:length(snirffiles)
    if snirffiles(ii).isdir
        continue;
    end
    fprintf('Deleting %s\n', [snirffiles(ii).pathfull, '/', snirffiles(ii).name]);
    delete([snirffiles(ii).pathfull, '/', snirffiles(ii).name]);
    pause(0.25);
end

