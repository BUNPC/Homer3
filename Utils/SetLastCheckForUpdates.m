function SetLastCheckForUpdates(dt)
if ~exist('dt','var') && ispathvalid([getAppDir, 'LastCheckForUpdates.dat'])
    return;
end
if ~exist('dt','var')
    try
        dt = datetime;
    catch
        dt = -1;
    end
end
fd = fopen([getAppDir, 'LastCheckForUpdates.dat'],'wt');
fprintf(fd, '%s\n', dt);
fclose(fd);

