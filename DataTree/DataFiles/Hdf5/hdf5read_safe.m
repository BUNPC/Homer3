function val = hdf5read_safe(fname, name, default)

try
    val = hdf5read(fname, name);
catch
    switch(class(default))
        case 'char'
            val = '';
        case 'cell'
            val = {};
	case 'struct'
	    val=struct;
        otherwise            
            val = [];
    end
end