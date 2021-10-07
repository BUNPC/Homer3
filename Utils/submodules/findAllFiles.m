function files = findAllFiles(subdir)
files = {};
if ~exist('subdir','var')
    subdir = pwd;
end
if ~ispathvalid_startup(subdir, 'dir')
    fprintf('Warning: folder %s doesn''t exist under %s\n', subdir, pwd);
    return;
end
if strcmp(subdir, '.')
    return
end
if strcmp(subdir, '..')
    return
end
if strcmp(subdir, '.git')
    return
end

% If current subjdir is in the exclList then go back to curr dir and exit
subdirFullpath = filesepStandard_startup(subdir,'full');
f = dir([subdirFullpath, '*']);
for ii = 1:length(f)
    if strcmp(f(ii).name, '.')
        continue
    end
    if strcmp(f(ii).name, '..')
        continue
    end
    if strcmp(f(ii).name, '.git')
        continue
    end
    if strcmp(f(ii).name, '.numberfiles')
        continue
    end
    
    if ~f(ii).isdir
        files{end+1,1} = filesepStandard_startup(sprintf('%s%s%s', subdirFullpath, f(ii).name), 'nameonly');        
    else
        files = [files; findAllFiles([subdirFullpath, f(ii).name])];
    end
end

