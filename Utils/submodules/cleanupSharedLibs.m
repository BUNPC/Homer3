function cleanupSharedLibs()
submodules = parseGitSubmodulesFile();
for ii = 1:size(submodules,1)
    submodulepath   = submodules{ii,3};
    [~, submodulename] = fileparts(submodules{ii,1});    
    if ispathvalid_startup(submodulepath)
        if ispathvalid_startup([submodulename, '.old/'])
            fprintf('Deleteing folder %s\n', [submodulename, '.old/']);
            rmdir([submodulename, '.old/'],'s')
        end
        fprintf('Moving %s  to  %s\n', submodulepath, [submodulename, '.old']);
        copyFolderContents(submodulepath, [submodulename, '.old/']);
        fprintf('Removing contents of %s\n', submodulepath);
        removeFolderContents(submodulepath);
    end    
    fprintf('\n');
end
