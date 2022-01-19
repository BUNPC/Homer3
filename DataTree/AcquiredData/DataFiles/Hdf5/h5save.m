function h5save(fname, varval, varname)

if nargin==1
    varname = '';
end
if exist(fname, 'file')
    delete(fname);
end
fid = H5F.create(fname, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
H5F.close(fid);

h5savevar(fname, varval, varname);



% ---------------------------------------------------------------------------
function h5savevar(fname, varval, varname)

% Simple matrices: uint, int, double, char, etc
if ~isstruct(varval) && ~isobject(varval)
    
    % Create new leaf variable if it doesn't exist. 
    if ~exist(fname, 'file') || ~h5exist(h5info(fname), varname)
        % Since HDF5 does not support empty or null variable, if varval is null 
        % add a _0 suffix to the var name and then don't write to it.          
        if ~isempty(varval)
            hdf5write(fname, varname, varval, 'WriteMode','append');
        else
            varname_0 = eval( sprintf('''%s_0'';', varname) );
            hdf5write(fname, varname_0, 0, 'WriteMode','append');
        end
    end
  
% Structs and Classes
else
    
    for jj=1:length(varval)
        props = propnames(varval(jj));
        for ii=1:length(props)
            if isempty(varname) || varname(1)=='/'
                subvarname = sprintf('%s_%d/%s', varname, jj, props{ii});
            else
                subvarname = sprintf('/%s_%d/%s', varname, jj, props{ii});
            end
            subvar = eval( sprintf('varval(jj).%s', props{ii}) );
            h5savevar(fname, subvar, subvarname);
        end
    end
    
end

