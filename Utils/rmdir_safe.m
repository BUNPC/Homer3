function status = rmdir_safe(pname)
status = 0;

try 
    if exist(pname,'dir')
        rmdir(pname, 's');
    end
catch
    status = -1;
end

