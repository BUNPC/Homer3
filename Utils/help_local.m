function s = help_local(fname)
s = '';
fd = fopen(fname, 'r');
if fd<0
    return
end
formaldeclfound = false;
while 1
    line = strtrim(fgetl(fd));
    if isempty(line) && ~formaldeclfound
        continue
    end
    if line==-1
        break;
    end
    if ~isempty(line) && line(1) == '%'
        s = sprintf('%s %s\n', s, line(2:end));
    elseif ~formaldeclfound && strncmp(line, 'function', 8)
        formaldeclfound = true;
    else
        break
    end
end
fclose(fd);
