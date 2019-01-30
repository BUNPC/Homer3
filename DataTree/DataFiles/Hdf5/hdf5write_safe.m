function hdf5write_safe(fname, name, val)

if ~isempty(val)
    hdf5write(fname, name, val, 'WriteMode','append');
else
    hdf5write(fname, [name,'_0'], 0, 'WriteMode','append');
end

