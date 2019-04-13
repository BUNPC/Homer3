function dirname = getAppDir(isdeployed_override)

if ~exist('isdeployed_override','var')
    isdeployed_override = 'notdeployed';
end

if isdeployed() || strcmp(isdeployed_override, 'isdeployed')
    if ispc()
        dirname = 'c:/users/public/homer3/';
    else
        currdir = pwd;
        cd ~/;
        dirnameHome = pwd;
        dirname = [dirnameHome, '/homer3/'];
        cd(currdir);
    end
else
    dirname = fileparts(which('Homer3.m'));
end

dirname(dirname=='\') = '/';
if dirname(end) ~= '/'
    dirname(end+1) = '/';
end


