function err = hdf5write_safe(fname, name, val, options)
    

    err = -1;
    if isempty(val)
        return;
    end
    if ~exist('options','var')
        options = '';
    end
    
    force_scalar = false;
    force_array = false;
    if any(strcmp(options, 'array'))
       force_array = true;
    elseif any(strcmp(options, 'scalar'))
        force_scalar = true;
    end
    % Identify type of val and use SNIRF v1.1-compliant write function
    
    if exist(fname,'file')
        fid = H5F.open(fname, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    else
        fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
    end
    if fid < 0
        err = -1;
        return;
    end

    % Create group where dataset is located
    group = filesepStandard(fileparts(name), 'nameonly');
    gid = HDF5_CreateGroup(fid, group);
    if gid < 0
        err = -1;
        return;
    end
    
    if iscell(val) || isstring(val)
        if length(val) > 1 && ~force_scalar || force_array  % Returns true for single strings, believe it or not
            write_string_array(fid, fname, name, val);
        else
            write_string(fid, fname, name, val);
        end
        return
    elseif ischar(val)
        write_string(fid, fname, name, val);
        return
    elseif isfloat(val)
        if length(val) > 1 && ~force_scalar || force_array
            write_numeric_array(fname, name, val);
        else
            write_numeric(fid, fname, name, val);
        end
        return
    elseif isinteger(val)
        if length(val) > 1 && ~force_scalar || force_array
            write_numeric_array(fid, fname, name, val);  % As of now, no integer arrays exist
        else
            write_integer(fid, fname, name, val);
        end
        return
    else
        warning(['An unrecognized variable was saved to ', name, ' in ', fname])
    end
    
    H5F.close(fid);

end

function err = write_string(fid, fname, name, val)
    sid = H5S.create('H5S_SCALAR');
    tid = H5T.copy('H5T_C_S1');
    H5T.set_size(tid, 'H5T_VARIABLE');
    did = H5D.create(fid, name, tid, sid, 'H5P_DEFAULT');
    H5D.write(did, tid, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', {val});
    err = 0;
end

function err = write_string_array(fid, fname, name, val)
    val = HDF5_Transpose(val);
    sid = H5S.create_simple(1, numel(val), H5ML.get_constant_value('H5S_UNLIMITED'));
    tid = H5T.copy('H5T_C_S1');
    H5T.set_size(tid, 'H5T_VARIABLE');
    pid = H5P.create('H5P_DATASET_CREATE');
    H5P.set_chunk(pid, 2);
    did = H5D.create(fid, name, tid, sid, pid);
    H5D.write(did, tid, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', val);
    err = 0;
end

function err = write_numeric(fid, fname, name, val)
    fid = H5F.open(fname, 'H5F_ACC_RDWR', 'H5P_DEFAULT');
    tid = H5T.copy('H5T_NATIVE_DOUBLE');
    sid = H5S.create('H5S_SCALAR');
    H5D.create(fid, name, tid, sid, 'H5P_DEFAULT');
    h5write(fname, name, val);
    err = 0;
end

function err = write_numeric_array(fname, name, val)
    val = HDF5_Transpose(val);
    sizeval = size(val);
    if sizeval(1) == 1 || sizeval(2) == 1
        n = length(val);
    else
        n = sizeval;
    end
    h5create(fname, name, n, 'Datatype', 'double');
    h5write(fname, name, val);
    err = 0;
end

function err = write_integer(fid, fname, name, val)
    warning off;  % Suppress the int truncation warning
    tid = H5T.copy('H5T_NATIVE_INT');
    sid = H5S.create('H5S_SCALAR');
    H5D.create(fid, name, tid, sid, 'H5P_DEFAULT');
    h5write(fname, name, val);
    err = 0;
    warning on;
end
