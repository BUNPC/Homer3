function desktopPath = generateDesktopPath(dirnameSrc)
if ~exist('dirnameSrc','var')
    dirnameSrc = filesepStandard(pwd);
end

if ispc()
    if ~exist([dirnameSrc, 'desktopPath.txt'],'file')
        system(sprintf('call "%sgenerateDesktopPath.bat"', dirnameSrc));
    end
    
    if exist([dirnameSrc, 'desktopPath.txt'],'file')
        fid = fopen([dirnameSrc, 'desktopPath.txt'],'rt');
        line = fgetl(fid);
        line(line=='"')='';
        desktopPath = strtrim(line);
        fclose(fid);
    else
        desktopPath = sprintf('%%userprofile%%');
    end    
else
    desktopPath = fullpath('~/Desktop');
end
try
    fprintf('Desktop path:  %s\n', desktopPath);
    desktopPath = filesepStandard(desktopPath); 
    desktopPath = desktopPath(1:end-1);
catch
    fprintf('ERROR: Desktop path not found\n');
    desktopPath = '';
end

