function nbytes = sizeof(x)

nbytes = [];

if nargin==0
    return
end
if isempty(x)
    nbytes = 0;
    return;
end

if isobject(x)
    type = 'object';
else
    type = class(x);
end

nbytes = 0;
switch(type)
    case 'double'
        nbytes = 8 * length(x(:));
    case 'single'
        nbytes = 4 * length(x(:));
    case 'int8'
        nbytes = 1 * length(x(:));
    case 'int16'
        nbytes = 2 * length(x(:));
    case 'int32'
        nbytes = 4 * length(x(:));
    case 'int64'
        nbytes = 8 * length(x(:));
    case 'uint8'
        nbytes = 1 * length(x(:));
    case 'uint16'
        nbytes = 2 * length(x(:));
    case 'uint32'
        nbytes = 4 * length(x(:));
    case 'uint64'
        nbytes = 8 * length(x(:));
    case 'char'
        nbytes = 2 * length(x(:));
    case 'cell'
        for ii = 1:length(x(:))
            nbytes = nbytes + sizeof(x{ii}) + 112;
        end
    case 'struct'
        fields = fieldnames(x);
        for jj = 1:length(x(:))
            for ii=1:length(fields)
                eval(sprintf('nbytes = nbytes + sizeof(x(jj).%s) + 176;', fields{ii}));
            end
        end
    case 'object'
        fields = properties(x);
        for jj = 1:length(x(:))
            for ii=1:length(fields)
                eval(sprintf('nbytes = nbytes + sizeof(x(jj).%s);', fields{ii}));
            end
        end
end


