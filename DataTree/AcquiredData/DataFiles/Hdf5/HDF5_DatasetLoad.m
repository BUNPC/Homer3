function val = HDF5_DatasetLoad(gid, name, val)

if nargin==2
    val = []; 
end

try
    dsetid = H5D.open(gid, name);
    val = H5D.read(dsetid);
    H5D.close(dsetid);    
catch ME
    switch(class(val))
        case 'char'
            val = '';
        case 'cell'
            val = {};
        otherwise            
            val = [];
    end
end
