function cd_safe(dirname)

if exist(dirname, 'dir') == 7
    try
        cd(dirname);
    catch
        ;
    end
end