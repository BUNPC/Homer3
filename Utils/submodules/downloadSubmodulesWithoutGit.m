function downloadSubmodulesWithoutGit(submodules, branch)
if isempty(submodules)
    return;
end
if isempty(branch)
    return;
end

for ii = 1:size(submodules,1)
    url             = submodules{ii,1};
    submodulepath   = submodules{ii,3};
    
    [~, submodulename] = fileparts(url);
    filenameDownload = sprintf('./%s-%s', submodulename, branch);

    cleanup(filenameDownload, submodulepath);
    
    fprintf('Downloading %s/archive/refs/heads/%s.zip  to  %s\n', url, branch, [filenameDownload, '.zip']);
    urlwrite(sprintf('%s/archive/refs/heads/%s.zip', url, branch), [filenameDownload, '.zip']); %#ok<URLWR>

    install(filenameDownload, submodulepath);
    
    fprintf('\n');
end




% ----------------------------------------------------------
function cleanup(filenameDownload, submodulepath)
removeFolderContents(submodulepath);
if ispathvalid_startup([filenameDownload, '.zip'])
    fprintf('Removing %s\n', [filenameDownload, '.zip']);
    try
        delete([filenameDownload, '.zip']);
    catch
        warning('Failed to remove %s\n', [filenameDownload, '.zip']);
    end
end
if ispathvalid_startup(filenameDownload)
    fprintf('Removing %s\n', filenameDownload);
    try
        rmdir(filenameDownload, 's');
    catch
        warning('Failed to remove %s\n', filenameDownload);
    end
end



% ---------------------------------------------------------
function install(filenameDownload, submodulepath)
if ispathvalid_startup([filenameDownload, '.zip'])
    fprintf('Unzipping %s\n', [filenameDownload, '.zip']);
    unzip([filenameDownload, '.zip']);
end
if ispathvalid_startup(filenameDownload)
    fprintf('Copying %s/*  to  %s\n', filenameDownload, submodulepath);
    copyFolderContents(filenameDownload, submodulepath);
end
if ispathvalid_startup([filenameDownload, '.zip'])
    fprintf('Removing %s\n', [filenameDownload, '.zip']);
    try
        delete([filenameDownload, '.zip']);        
    catch
    end
end
if ispathvalid_startup(filenameDownload)
    fprintf('Removing %s\n', filenameDownload);
    try
        rmdir(filenameDownload, 's');
    catch
    end
end
