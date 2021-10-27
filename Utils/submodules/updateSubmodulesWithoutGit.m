function updateSubmodulesWithoutGit(submodules, branch)
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

    if ~isemptyFolder(submodulepath)
        if ispathvalid_startup([submodulename, '.old/'])
            fprintf('Deleteing folder %s\n', [submodulename, '.old/']);
            rmdir([submodulename, '.old/'],'s')
        end
        fprintf('Moving %s  to  %s\n', submodulepath, [submodulename, '.old']);
        copyFolderContents(submodulepath, [submodulename, '.old/']);
        fprintf('Removing contents of %s\n', submodulepath);
        removeFolderContents(submodulepath);
    end
    
    if ispathvalid_startup([filenameDownload, '.zip'])    
        fprintf('Deleteing old zip file %s\n', [filenameDownload, '.zip']);
        delete([filenameDownload, '.zip']);
    end
    
    fprintf('Downloading %s/archive/refs/heads/%s.zip  to  %s\n', url, branch, [filenameDownload, '.zip']);
    urlwrite(sprintf('%s/archive/refs/heads/%s.zip', url, branch), [filenameDownload, '.zip']); %#ok<URLWR>
    
    if ispathvalid_startup([filenameDownload, '.zip'])    
        fprintf('Unzipping %s\n', [filenameDownload, '.zip']);
        unzip([filenameDownload, '.zip']);
    end
    
    if ispathvalid_startup(filenameDownload)
        fprintf('Copying %s/*  to  %s\n', filenameDownload, submodulepath);
        copyFolderContents(filenameDownload, submodulepath);
    else
        fprintf('Moving %s  to  %s\n', [submodulename, '.old'], submodulepath);
        movefile([submodulename, '.old'], submodulepath);
        msgbox('Was not able download new version of "%s" and update it. Please download and updated manually.\n')
    end 
    
    fprintf('\n');
end

