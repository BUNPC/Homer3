function dt = GetLastCheckForUpdates()
if ~ispathvalid([getAppDir, 'LastCheckForUpdates.dat'])
    try
        dt = datetime - duration(200,0,0);
    catch
        dt = -1;
    end
else
    fd = fopen([getAppDir, 'LastCheckForUpdates.dat'],'rt');
    dt = fgetl(fd);
    fclose(fd);
end

