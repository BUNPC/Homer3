function fid = HDF5_GetFileDescriptor(fileobj)

% Either fileobj is a name of a file or a HDF5 file descriptor
if ischar(fileobj)
    if ispathvalid(fileobj,'file')
        fid = H5F.open(fileobj, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    else
        fid = H5F.create(fileobj, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
    end
    if fid < 0
        return;
    end
else
    fid = fileobj;
end
