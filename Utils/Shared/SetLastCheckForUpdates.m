function SetLastCheckForUpdates()
try
    dt = datetime;
catch
    dt = -1;
end
fd = fopen([getAppDir, 'LastCheckForUpdates.dat'],'wt');
fprintf(fd, '%s\n', dt);
fclose(fd);

