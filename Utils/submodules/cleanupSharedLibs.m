function cleanupSharedLibs()
submodules = parseGitSubmodulesFile();
for ii = 1:size(submodules,1)
    submodulepath   = submodules{ii,3};
    if ispathvalid_startup(submodulepath)
        if ispathvalid_startup([submodulepath, '.old/'])
            fprintf('Deleteing folder %s\n', [submodulepath, '.old/']);
            rmdir([submodulepath, '.old/'],'s')
        end
        fprintf('Moving %s  to  %s\n', submodulepath, [submodulepath, '.old']);
        copyfile([submodulepath, '/*'], [submodulepath, '.old/']);
        fprintf('Removing contents of %s\n', submodulepath);
        removeFolderContents(submodulepath);
    end    
    fprintf('\n');
end