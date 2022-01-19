function filesize = GetFileSize(fileobject)

if ischar(fileobject)
    if exist(fileobject, 'file') == 2
        fd = fopen(fileobject);
    else
        filesize = -1;
        return;
    end
else
    fd = fileobject;
end

% Since we're changing file position, save the initial one, then restore
% it before exiting
p0 = ftell(fd);

fseek(fd, 0, 'eof');     % move the cursor to the end of the file
filesize = ftell(fd);

% Restore original file position
fseek(fd, p0, 'bof');

if ischar(fileobject)
    fclose(fd);
end


