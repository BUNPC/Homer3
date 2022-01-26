function v = getVernum(appname)
v = '';
if ~exist('appname','var')
    [~,f,e] = fileparts(pwd);
    appname = [f,e];
end
appdir = getAppDir();
if isdeployed()
    [~,f,e] = fileparts(appdir);
    if strcmp([f,e], appname)
        p = appdir;
    elseif ispathvalid([appdir, appname, '/Shared/Version.txt'])
        p = [appdir, appname, '/Shared'];
    elseif ispathvalid([appdir, appname, '/Version.txt'])
        p = [appdir, appname];
    end
else
    p = which(appname);
    p = fileparts(p);
    if ispathvalid([appdir, appname, '/Shared/Version.txt'])
        p = [appdir, appname, '/Shared'];
    elseif ispathvalid([appdir, '../', appname, '/Shared/Version.txt'])
        p = [appdir, '../', appname, '/Shared'];
    elseif ispathvalid([appdir, appname, '/Version.txt'])
        p = [appdir, appname];
    end
end
verfile = [p, '/Version.txt'];
if ~ispathvalid(verfile)
    return;
end
fd = fopen(verfile,'rt');
v = fgetl(fd);
fclose(fd);
