function val = h5read_safe(fname, name, val)

if h5exist(h5info(fname), name)
    val = h5read(fname, name);
elseif h5exist(h5info(fname), [name, '_0'])
    switch(class(val))
        case 'char'
            val = '';
        case 'cell'
            val = {};
        otherwise            
            val = [];
    end
end

