function [appname, exename] = getAppname()
global platform

if isempty(platform) || ~isstruct(platform)
    platform = setplatformparams();
end
[~, exename] = fileparts(platform.exename{1});
appname = exename;
k = findstr('gui',lower(appname));
appname(k:k+2) = '';

