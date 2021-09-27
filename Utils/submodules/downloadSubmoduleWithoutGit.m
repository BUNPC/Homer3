function downloadSubmoduleWithoutGit(submodules, branch)
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

    fprintf('Downloading %s/archive/refs/heads/%s.zip  to  %s\n', url, branch, [filenameDownload, '.zip']);    
    urlwrite(sprintf('%s/archive/refs/heads/%s.zip', url, branch), [filenameDownload, '.zip']); %#ok<URLWR>
    
    fprintf('Unzipping %s\n', [filenameDownload, '.zip']);
    unzip([filenameDownload, '.zip']);
    
    if ispathvalid_startup(filenameDownload)
        fprintf('Copying %s/*  to  %s\n', filenameDownload, submodulepath);
        copyfile([filenameDownload, '/*'], submodulepath);
    end 
    fprintf('\n');
end

