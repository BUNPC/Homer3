function status = rmdir_safe(pname)
status = 0;

try 
    rmdir(pname, 's');
catch
    status = -1;
end

