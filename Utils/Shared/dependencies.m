function [apps, vers, appdirs] = dependencies()
apps = {};
vers = {};
appdirs = {};
submodules = parseGitSubmodulesFile(getAppDir());
temp = submodules(:,1);
for ii = 1:length(temp)
    [~, apps{ii,1}] = fileparts(temp{ii});
    vers{ii,1} = getVernum(apps{ii,1});
    appdirs{ii,1} = submodules{ii,2};
end

