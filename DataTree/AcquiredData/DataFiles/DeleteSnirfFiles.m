function DeleteSnirfFiles(dirname, snirffiles0)

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

