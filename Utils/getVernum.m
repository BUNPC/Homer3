function v = getVernum(appname, appdir)
v = '';
if ~exist('appname','var') || isempty(appname)
    [~,f,e] = fileparts(pwd);
    appname = [f,e];
end
if ~exist('appdir','var') || isempty(appdir)
    appdir = getAppDir();
end
libdir = '/Shared';
if isdeployed()
    p = appdir;    
elseif length(appdir) > length(libdir)  &&  strcmp( appdir( end-length(libdir)+1 : end ), libdir )
    p = appdir;
elseif ispathvalid_startup([appdir, libdir])
    p = [appdir, libdir];
elseif ispathvalid_startup([appdir, appname, libdir])
    p = [appdir, appname, libdir];
elseif ispathvalid_startup([appdir, appname, '.m'])
    p = appdir;
else
    p = findFolder(appdir, appname);
end
verfile = [p, '/Version.txt'];
if ~ispathvalid(verfile)
    [~, v] = getLastRevisionDate(appdir, p);
    return;
end
fd = fopen(verfile,'rt');
v = fgetl(fd);
fclose(fd);

