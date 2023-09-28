function val = hdf5read_safe(fname, name, val)

try
    val = hdf5read(fname, name);
catch
    switch(class(val))
        case 'char'
            val = '';
        case 'cell'
            val = {};
        otherwise            
            val = [];
    end
end