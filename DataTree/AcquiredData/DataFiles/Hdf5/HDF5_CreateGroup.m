function gid = HDF5_CreateGroup(fid, group)
if strcmp(group, '/') || strcmp(group, '\')
    gid = H5G.open(fid, '/');
    return
end
try
    gid = H5G.open(fid, group);
catch
    rootgroup = fileparts(group);
    gid = HDF5_CreateGroup(fid, rootgroup);
    gid = H5G.create(gid, group, 'H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
end
