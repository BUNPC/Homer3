function userfuncdir = FindUserFuncDir(obj)
userfuncdir = {};
dirnameApp = getAppDir();

userfuncdir{1} = [dirnameApp, 'FuncRegistry/UserFunctions/'];
dirs = dir([userfuncdir{1}, '*']);
for ii = 1:length(dirs)
    if ~dirs(ii).isdir()
        continue
    elseif strcmp(dirs(ii).name, '..') || strcmp(dirs(ii).name, '.')
        continue
    elseif strcmp(dirs(ii).name, 'Archive')    
        if strcmp(obj.config.InclArchivedFunctions, 'Yes')
            userfuncdir{end+1} = fullpath([userfuncdir{1}, 'Archive/']);
        end
    else
        userfuncdir{end+1} = fullpath([userfuncdir{1}, dirs(ii).name]);
    end
end

