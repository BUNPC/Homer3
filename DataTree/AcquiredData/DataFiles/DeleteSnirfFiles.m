function DeleteSnirfFiles(snirffiles0)

if ~exist('snirffiles0','var')
    snirffiles0 = DataFilesClass('.snirf','standalone').files;
end

snirffiles = mydir('');
if iscell(snirffiles0)
    for ii=1:length(snirffiles0)
        snirffiles(ii) = mydir(snirffiles0{ii});
    end
elseif ischar(snirffiles0)
    snirffiles = mydir(snirffiles0);
elseif isa(snirffiles0, 'FileClass')
    snirffiles = snirffiles0;
end

for ii=1:length(snirffiles)
    if snirffiles(ii).isdir
        continue;
    end
    fprintf('Deleting %s\n', [snirffiles(ii).pathfull, '/', snirffiles(ii).filename]);
    delete([snirffiles(ii).pathfull, '/', snirffiles(ii).filename]);
    pause(0.25);
end

