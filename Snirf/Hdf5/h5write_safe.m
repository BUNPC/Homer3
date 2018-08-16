function h5write_safe(fname, name, val)

if ~isempty(val)
    h5write(fname, name, val);
else
    try 
        h5write(fname, [name,'_0'], 0);
    catch
        h5create(fname, [name,'_0'], [1,1]);
        h5write(fname, [name,'_0'], 0);
    end
    
end
