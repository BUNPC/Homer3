function userfuncdir = FindUserFuncDir(obj)
userfuncdir = {};
dirnameApp = getAppDir();

userfuncdir{1} = [dirnameApp, 'FuncRegistry/UserFunctions/'];
if strcmp(obj.config.InclArchivedFunctions, 'Yes')
    userfuncdir{2} = fullpath([userfuncdir{1}, 'Archive/']);
end
