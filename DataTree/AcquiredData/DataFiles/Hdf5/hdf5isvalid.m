function b = hdf5isvalid(fname)

val = H5F.is_hdf5(fname);
if val > 0
    b = true;
else
    b = false;
    fprintf('File %s is not an HDF5 file.\n', fname);
end