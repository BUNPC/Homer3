function userfuncdir = FindUserFuncDir(obj)
global cfg

cfg = InitConfig(cfg);

userfuncdir = {};
dirnameApp = getAppDir();

rootdirRegsitry = [dirnameApp, 'FuncRegistry/UserFunctions/'];
if ~ispathvalid(rootdirRegsitry)
    rootdirRegsitry = filesepStandard([dirnameApp, '../FuncRegistry/UserFunctions/']);
    if ~ispathvalid(rootdirRegsitry)
    	return;
	end
end
userfuncdir{1} = rootdirRegsitry;
dirs = dir([userfuncdir{1}, '*']);
for ii = 1:length(dirs)
    if ~dirs(ii).isdir
        continue
    elseif strcmp(dirs(ii).name, '..') || strcmp(dirs(ii).name, '.')
        continue
    elseif strcmp(dirs(ii).name, 'Archive')
        obj.config = struct('InclArchivedFunctions','');
        obj.config.InclArchivedFunctions = cfg.GetValue('Include Archived User Functions');        
        if strcmp(obj.config.InclArchivedFunctions, 'Yes')
            userfuncdir{end+1} = fullpath([userfuncdir{1}, 'Archive/']); %#ok<*AGROW>
        end
    else
        userfuncdir{end+1} = filesepStandard(fullpath([userfuncdir{1}, dirs(ii).name]));
    end
end

