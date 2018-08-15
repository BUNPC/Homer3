function val = hdf5read_safe(fname, name)

info = h5info(fname);
if h5exist(info, name)
    val = h5read(fname, name);
elseif h5exist(info, name)
    val = '';
end

