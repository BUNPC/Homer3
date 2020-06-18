function err = hdf5write_safe(fname, name, val, options)

err = -1;
if  isempty(val)
    return;
end
if ~exist('options','var')
    options = '';
end

if iscell(val)
    HDF5_WriteStrings(fname, name, val)
else
    val = HDF5_Transpose(val, options);
    try
        if ~isempty(findstr('rw', options))
            try
                % For datasets that are writeable AFTER they are created
                % there's we need to have a separte create step where we can provide the
                % dimensions and chunk size. Since there's no way to test to see if dataset
                % already exists, we use try/catch by attempting to create the data set
                % and no harm done if it exists and we catch the exception.
                dims = size(val);
                h5create(fname, name, [dims(1), Inf], 'ChunkSize',[dims(1), 64]);
            catch
                % Dataset already exists. move on...
            end
            h5write(fname, name, val, [1,1], dims);
        else
            hdf5write(fname, name, val, 'WriteMode','append');
        end
    catch
        return;
    end
end
err = 0;