function dt = GetLastCheckForUpdates()
if ~ispathvalid([getAppDir, 'LastCheckForUpdates.dat'])
    dt = datetime - duration(200,0,0);
else
    fd = fopen([getAppDir, 'LastCheckForUpdates.dat'],'rt');
    dt = fgetl(fd);
    fclose(fd);
end

