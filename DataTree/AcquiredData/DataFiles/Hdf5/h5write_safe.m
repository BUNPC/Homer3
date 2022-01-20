function h5write_safe(fname, name, val)

if ~isempty(val)
    h5create(fname, name, [size(val,1), size(val,2)]);
    h5write(fname, name, val);
end
