function files = findAllFiles(subdir)
files = {};
if ~exist('subdir','var')
    subdir = pwd;
end
if ~ispathvalid_startup(subdir, 'dir')
    fprintf('Warning: folder %s doesn''t exist under %s\n', subdir, pwd);
    return;
end
if subdir(1) == '.'
    return
end

% If current subjdir is in the exclList then go back to curr dir and exit
subdirFullpath = filesepStandard_startup(subdir,'full');
f = dir([subdirFullpath, '*']);
for ii = 1:length(f)
    if f(ii).name(1) == '.'
        continue
    end
    
    if ~f(ii).isdir
        files{end+1,1} = filesepStandard_startup(sprintf('%s%s%s', subdirFullpath, f(ii).name), 'nameonly');         %#ok<*AGROW>
    else
        files = [files; findAllFiles([subdirFullpath, f(ii).name])];
    end
end

