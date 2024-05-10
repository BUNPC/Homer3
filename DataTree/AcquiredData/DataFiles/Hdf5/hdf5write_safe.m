function err = hdf5write_safe(fileobj, name, val, options)
err = -1;
if ~exist('val','var')
    return;
end
if ~exist('options','var')
    options = '';
end

force_array = false;
force_vector = false;
if any(strcmp(options, 'array'))
    force_array = true;
elseif any(strcmp(options, 'vector'))
    force_vector = true;
end

% Identify type of val and use SNIRF v1.1-compliant write function
fid = HDF5_GetFileDescriptor(fileobj);
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

% Create dataset
if iscell(val) || isstring(val)
    if (length(val) > 1) || force_array  % Returns true for single strings, believe it or not
        write_string_array(fid, name, val);
    else
        write_string(fid, name, val);
    end
elseif ischar(val)
    write_string(fid, name, val);
elseif isfloat(val) || isinteger(val)
    if force_vector
        write_numeric_vector(fid, name, val);
    elseif (length(val) > 1) || force_array
        write_numeric_array(fid, name, val);
    else
        write_numeric(fid, name, val);
    end
else
    warning(['An unrecognized variable was saved to ', name])
end



% -----------------------------------------------------------------
function err = write_string(fid, name, val)
sid = H5S.create('H5S_SCALAR');
tid = H5T.copy('H5T_C_S1');
H5T.set_size(tid, 'H5T_VARIABLE');
did = H5D.create(fid, name, tid, sid, 'H5P_DEFAULT');
H5D.write(did, tid, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', {val});
err = 0;



% -----------------------------------------------------------------
function err = write_string_array(fid, name, val)
val = HDF5_Transpose(val);
sid = H5S.create_simple(1, numel(val), H5ML.get_constant_value('H5S_UNLIMITED'));
tid = H5T.copy('H5T_C_S1');
H5T.set_size(tid, 'H5T_VARIABLE');
pid = H5P.create('H5P_DATASET_CREATE');
H5P.set_chunk(pid, 2);
dsid = H5D.create(fid, name, tid, sid, pid);
H5D.write(dsid, tid, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', val);
err = 0;




% -----------------------------------------------------------------
function err = write_numeric(fid, name, val)
warning off;  % Suppress the int truncation warning
hdftype = convert_to_hdf5_type(val);
tid = H5T.copy(hdftype);
sid = H5S.create('H5S_SCALAR');
dsid = H5D.create(fid, name, tid, sid, 'H5P_DEFAULT');
H5D.write(dsid, tid, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', val);
err = 0;
warning on;




% -----------------------------------------------------------------
function err = write_numeric_array(fid, name, data)
err = 0;
data = HDF5_Transpose(data, '2D');
sizedata = size(data);
n = sizedata;

tid = -1;
sid = -1;
gid = -1;
dsid = -1;

maxdims = n;

hdftype = convert_to_hdf5_type(data);

try
    
    sid = H5S.create_simple(numel(n), fliplr(n), fliplr(maxdims));
    gid = HDF5_CreateGroup(fid, fileparts(name));
    dsid = H5D.create(gid, name, hdftype, sid, 'H5P_DEFAULT');
    H5D.write(dsid, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
    
catch
    
    % Clean up; Close everything
    cleanUp(tid, sid, gid, dsid);
    err = -1;
    return;
    
end
cleanUp(tid, sid, gid, dsid);




% -----------------------------------------------------------------
function err = write_numeric_vector(fid, name, data)
err = 0;
data = HDF5_Transpose(data, '2D');
sizedata = length(data);
n = sizedata;

tid = -1;
sid = -1;
gid = -1;
dsid = -1;

maxdims = n;
hdftype = convert_to_hdf5_type(data);
try
    
    sid = H5S.create_simple(numel(n), fliplr(n), fliplr(maxdims));
    gid = HDF5_CreateGroup(fid, fileparts(name));
    dsid = H5D.create(gid, name, hdftype, sid, 'H5P_DEFAULT');
    H5D.write(dsid, 'H5ML_DEFAULT', 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', data);
    
catch
    
    % Clean up; Close everything
    cleanUp(tid, sid, gid, dsid);
    err = -1;
    return;
    
end
cleanUp(tid, sid, gid, dsid);




% ------------------------------------------------------
function cleanUp(tid, sid, gid, dsid)
if ~isnumeric(tid)
    H5T.close(tid);
end
if ~isnumeric(sid)
    H5S.close(sid);
end
if ~isnumeric(gid)
    H5G.close(gid);
end
if ~isnumeric(dsid)
    H5D.close(dsid);
end




% -------------------------------------------------------
function hdftype = convert_to_hdf5_type(val)
hdftype = '';
switch class(val)
    case 'int8'
        hdftype = 'H5T_STD_I8LE';
    case 'uint8'
        hdftype = 'H5T_STD_U8LE';
    case 'int16'
        hdftype = 'H5T_STD_I16LE';
    case 'uint16'
        hdftype = 'H5T_STD_U16LE';
    case 'int32'
        hdftype = 'H5T_STD_I32LE';
    case 'uint32'
        hdftype = 'H5T_STD_U32LE';
    case 'int64'
        hdftype = 'H5T_STD_I64LE';
    case 'uint64'
        hdftype = 'H5T_STD_U64LE';
    case 'double'
        hdftype = 'H5T_NATIVE_DOUBLE';
end


