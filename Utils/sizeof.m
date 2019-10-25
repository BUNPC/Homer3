function nbytes = sizeof(type)

nbytes = [];

if nargin==0
    return
end
if ischar(type)
    switch(type)
        case 'double'
            x = double(0);
        case 'single'
            x = single(0);
        case 'int8'
            x = int8(0);
        case 'int16'
            x = int16(0);
        case 'int32'
            x = int32(0);
        case 'int64'
            x = int64(0);
        case 'uint8'
            x = uint8(0);
        case 'uint16'
            x = uint16(0);
        case 'uint32'
            x = uint32(0);
        case 'uint64'
            x = uint64(0);
        case 'char'
            x = char(0);
        otherwise
            x = type;
    end
else
    x = type;
end    

a = whos('x');
nbytes = a.bytes;

